import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

/// Shown when the user taps a Math category (e.g. Grade 5 and 6).
/// Shows Sample quiz (open), Local round (locked), Final round (locked).
class MathRoundSelection extends StatefulWidget {
  final String topicName;
  /// Called when user taps Sample Quiz. Pass this widget's context so the caller can pop it before showing quiz rules.
  final Future<void> Function(BuildContext roundSelectionContext) onStartSampleQuiz;

  const MathRoundSelection({
    super.key,
    required this.topicName,
    required this.onStartSampleQuiz,
  });

  @override
  State<MathRoundSelection> createState() => _MathRoundSelectionState();
}

class _MathRoundSelectionState extends State<MathRoundSelection> {
  final supabase = Supabase.instance.client;
  bool _loadingEligibility = true;
  bool _eligibleForFinal = false;
  bool _loadingSample = false;

  @override
  void initState() {
    super.initState();
    _checkFinalRoundEligibility();
  }

  /// Top 20% of students by best score in local round for this topic are eligible for final round.
  Future<void> _checkFinalRoundEligibility() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _loadingEligibility = false);
      return;
    }
    try {
      final topicRow = await supabase
          .from('topics')
          .select('topic_id')
          .eq('topic_name', widget.topicName)
          .maybeSingle();
      if (topicRow == null) {
        setState(() => _loadingEligibility = false);
        return;
      }
      final topicId = topicRow['topic_id'] as int;

      final attempts = await supabase
          .from('test_attempts')
          .select('user_id, score')
          .eq('topic_id', topicId)
          .eq('round', 'local');

      if (attempts.isEmpty) {
        setState(() {
          _loadingEligibility = false;
          _eligibleForFinal = false;
        });
        return;
      }

      final Map<String, double> bestByUser = {};
      for (final row in attempts) {
        final uid = row['user_id'] as String;
        final score = (row['score'] ?? 0).toDouble();
        if (!bestByUser.containsKey(uid) || bestByUser[uid]! < score) {
          bestByUser[uid] = score;
        }
      }

      final sortedScores = bestByUser.values.toList()..sort((a, b) => b.compareTo(a));
      final n = sortedScores.length;
      final top20Count = (n * 0.2).ceil().clamp(1, n);
      final cutoff = top20Count > 0 ? sortedScores[top20Count - 1] : 0.0;
      final userBest = bestByUser[user.id] ?? -1.0;

      setState(() {
        _loadingEligibility = false;
        _eligibleForFinal = userBest >= cutoff && top20Count > 0;
      });
    } catch (_) {
      setState(() => _loadingEligibility = false);
    }
  }

  bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 768;

  Future<void> _onSampleQuizTap(BuildContext context) async {
    if (_loadingSample) return;
    setState(() => _loadingSample = true);
    try {
      await widget.onStartSampleQuiz(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingSample = false);
    }
  }

  // Same dynamic distribution as math_grades.dart
  List<Widget> _buildDecorativeElements(
    double screenWidth,
    double contentHeight,
    bool isMobile,
    int numItems,
  ) {
    final elements = <Widget>[];
    final centerX = screenWidth / 2;
    final containerHalfWidth = 400;
    final leftBoundary = centerX - containerHalfWidth;
    final rightBoundary = centerX + containerHalfWidth;
    final leftZone = leftBoundary - 100;
    final rightZone = screenWidth - rightBoundary - 100;
    final minSpacing = isMobile ? 60.0 : 80.0;
    final numDecorationRows = (contentHeight / minSpacing).ceil();
    final topPadding = 100.0;
    final bottomPadding = 50.0;
    final usableHeight = contentHeight - topPadding - bottomPadding;
    final adjustedSpacing = usableHeight / (numDecorationRows + 1).clamp(1, double.infinity);

    final starSizes = [
      {'w': isMobile ? 9.0 : 14.0, 'h': isMobile ? 8.5 : 13.2},
      {'w': isMobile ? 10.0 : 15.0, 'h': isMobile ? 9.4 : 14.2},
      {'w': isMobile ? 11.0 : 16.0, 'h': isMobile ? 10.4 : 15.1},
      {'w': isMobile ? 12.0 : 17.0, 'h': isMobile ? 11.3 : 16.0},
      {'w': isMobile ? 13.0 : 18.0, 'h': isMobile ? 12.3 : 17.0},
      {'w': isMobile ? 14.0 : 20.0, 'h': isMobile ? 13.2 : 18.9},
    ];
    final cloudSizes = [
      {'w': isMobile ? 28 : 40, 'h': isMobile ? 19 : 27},
      {'w': isMobile ? 30 : 42, 'h': isMobile ? 20 : 28},
      {'w': isMobile ? 32 : 45, 'h': isMobile ? 22 : 31},
      {'w': isMobile ? 35 : 48, 'h': isMobile ? 24 : 33},
      {'w': isMobile ? 38 : 52, 'h': isMobile ? 26 : 36},
      {'w': isMobile ? 40 : 55, 'h': isMobile ? 28 : 38},
    ];
    final leftPositions = [0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08];
    final rightPositions = [0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08];
    final usedPositionsLeft = <double>[];
    final usedPositionsRight = <double>[];
    const minDistanceBetween = 40.0;

    for (int i = 0; i < numDecorationRows; i++) {
      final baseY = topPadding + (adjustedSpacing * (i + 1));
      final randomOffset = (i % 3 - 1) * 12.0;
      final y = baseY + randomOffset;
      final useCloud = (i % 5 == 0 || i % 7 == 0);

      if (leftZone > 50) {
        bool leftTooClose = false;
        for (final usedY in usedPositionsLeft) {
          if ((y - usedY).abs() < minDistanceBetween) {
            leftTooClose = true;
            break;
          }
        }
        if (!leftTooClose) {
          usedPositionsLeft.add(y);
          final leftPos = leftPositions[i % leftPositions.length];
          if (useCloud) {
            final cloudSize = cloudSizes[i % cloudSizes.length];
            elements.add(
              Positioned(
                left: screenWidth * leftPos,
                top: y,
                child: SvgPicture.asset(
                  'assets/images/cloud.svg',
                  width: cloudSize['w']!.toDouble(),
                  height: cloudSize['h']!.toDouble(),
                ),
              ),
            );
          } else {
            final starSize = starSizes[i % starSizes.length];
            elements.add(
              Positioned(
                left: screenWidth * leftPos,
                top: y,
                child: SvgPicture.asset(
                  'assets/images/pinkstar.svg',
                  width: starSize['w']!,
                  height: starSize['h']!,
                ),
              ),
            );
          }
        }
      }

      if (rightZone > 50) {
        final rightY = y + ((i % 2 == 0) ? 8.0 : -8.0);
        bool rightTooClose = false;
        for (final usedY in usedPositionsRight) {
          if ((rightY - usedY).abs() < minDistanceBetween) {
            rightTooClose = true;
            break;
          }
        }
        if (!rightTooClose) {
          usedPositionsRight.add(rightY);
          final rightPos = rightPositions[i % rightPositions.length];
          if (useCloud) {
            final cloudSize = cloudSizes[(i + 1) % cloudSizes.length];
            elements.add(
              Positioned(
                right: screenWidth * rightPos,
                top: rightY,
                child: SvgPicture.asset(
                  'assets/images/cloud.svg',
                  width: cloudSize['w']!.toDouble(),
                  height: cloudSize['h']!.toDouble(),
                ),
              ),
            );
          } else {
            final starSize = starSizes[(i + 1) % starSizes.length];
            elements.add(
              Positioned(
                right: screenWidth * rightPos,
                top: rightY,
                child: SvgPicture.asset(
                  'assets/images/pinkstar.svg',
                  width: starSize['w']!,
                  height: starSize['h']!,
                ),
              ),
            );
          }
        }
      }
    }

    elements.add(
      Positioned(
        left: centerX - 100,
        top: 30,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 11.0 : 16.0,
          height: isMobile ? 10.4 : 15.1,
        ),
      ),
    );
    elements.add(
      Positioned(
        left: centerX + 50,
        top: 50,
        child: SvgPicture.asset(
          'assets/images/cloud.svg',
          width: isMobile ? 30 : 42,
          height: isMobile ? 20 : 28,
        ),
      ),
    );
    elements.add(
      Positioned(
        left: centerX - 50,
        top: 20,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 9.0 : 14.0,
          height: isMobile ? 8.5 : 13.2,
        ),
      ),
    );

    final bottomY = contentHeight - 30;
    if (bottomY > 0) {
      elements.add(
        Positioned(
          left: centerX - 80,
          top: bottomY - 20,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 13.0 : 18.0,
            height: isMobile ? 12.3 : 17.0,
          ),
        ),
      );
      elements.add(
        Positioned(
          right: centerX - 120,
          top: bottomY - 10,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 10.0 : 14.0,
            height: isMobile ? 9.4 : 13.2,
          ),
        ),
      );
      elements.add(
        Positioned(
          left: centerX + 30,
          top: bottomY - 30,
          child: SvgPicture.asset(
            'assets/images/cloud.svg',
            width: isMobile ? 28 : 40,
            height: isMobile ? 19 : 27,
          ),
        ),
      );
    }

    return elements;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const numCards = 3;
    final estimatedContentHeight = 200.0 + 80.0 + (numCards * 140.0);
    final actualContentHeight = estimatedContentHeight > screenHeight ? estimatedContentHeight : screenHeight;

    return Scaffold(
      backgroundColor: MyApp.homeLightGreyBackground,
      appBar: AppBar(
        backgroundColor: MyApp.homeLightGreyBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyApp.homeDarkGreyText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ..._buildDecorativeElements(screenWidth, actualContentHeight, isMobile, numCards),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 24.0,
                    vertical: isMobile ? 16.0 : 24.0,
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header card - Global Competition and Challenge (same as math_grades)
                        Container(
                          constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 800),
                          margin: EdgeInsets.only(bottom: isMobile ? 20 : 24),
                          padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
                          decoration: BoxDecoration(
                            color: MyApp.homeTealGreen,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Global Competition and Challenge",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 18 : 22,
                                  color: MyApp.homeWhite,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Math Series 2025",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 15 : 18,
                                  color: MyApp.homeWhite,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "In partnership with Saddle River Day School, New Jersey, USA",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 14,
                                  color: MyApp.homeWhite.withOpacity(0.9),
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/images/gc_logo.jpg', height: isMobile ? 45 : 50),
                                  SizedBox(width: 16),
                                  Image.asset('assets/images/school_logo.png', height: isMobile ? 45 : 50),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Main container with teal background (same structure as math_grades)
                        Container(
                          constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 800),
                          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                          decoration: BoxDecoration(
                            color: MyApp.homeTealGreen,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: category name (e.g. "Grade 5 and 6") instead of "Math Problems"
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 16 : 20,
                                  vertical: isMobile ? 12 : 16,
                                ),
                                margin: EdgeInsets.only(bottom: isMobile ? 16 : 20),
                                decoration: BoxDecoration(
                                  color: MyApp.homeLightPink,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.topicName,
                                  style: TextStyle(
                                    fontSize: isMobile ? 24 : 32,
                                    fontWeight: FontWeight.bold,
                                    color: MyApp.homeDarkGreyText,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ),
                              // Round cards: Sample (open), Local (locked), Final (locked)
                              _RoundCard(
                                title: 'Sample Quiz',
                                description: 'Practice with sample questions for this category. Unlimited attempts.',
                                isLocked: false,
                                isMobile: isMobile,
                                loading: _loadingSample,
                                onTap: _loadingSample ? null : () => _onSampleQuizTap(context),
                              ),
                              SizedBox(height: isMobile ? 20 : 24),
                              _RoundCard(
                                title: 'Local Round',
                                description: 'Take the quiz with the current question set. Your score will count toward final round eligibility.',
                                isLocked: true,
                                isMobile: isMobile,
                                onTap: null,
                              ),
                              SizedBox(height: isMobile ? 20 : 24),
                              _RoundCard(
                                title: 'Final Round',
                                description: 'Top 20% of students from local round will be eligible to write the final quiz.',
                                isLocked: true,
                                isMobile: isMobile,
                                eligible: _eligibleForFinal,
                                loading: _loadingEligibility,
                                onTap: null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Card styled like _HoverableQuizCard: pink background, title row (with optional Locked/Completed), description.
class _RoundCard extends StatefulWidget {
  final String title;
  final String description;
  final bool isLocked;
  final bool isMobile;
  final bool eligible;
  final bool loading;
  final VoidCallback? onTap;

  const _RoundCard({
    required this.title,
    required this.description,
    required this.isLocked,
    required this.isMobile,
    this.eligible = false,
    this.loading = false,
    this.onTap,
  });

  @override
  State<_RoundCard> createState() => _RoundCardState();
}

class _RoundCardState extends State<_RoundCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final canTap = widget.onTap != null && !widget.isLocked && !widget.loading;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: canTap ? widget.onTap : null,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()..scale(canTap && _isHovered ? 1.02 : 1.0),
          margin: EdgeInsets.only(bottom: 0),
          padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: MyApp.homeLightPink,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity((canTap && _isHovered) ? 0.15 : 0.1),
                blurRadius: (canTap && _isHovered) ? 6 : 4,
                offset: Offset(0, (canTap && _isHovered) ? 4 : 2),
              ),
            ],
          ),
          child: Opacity(
            opacity: (canTap && _isHovered) ? 0.95 : 1.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.isLocked) ...[
                            Icon(Icons.lock_outline, color: MyApp.homeDarkGreyText, size: widget.isMobile ? 20 : 24),
                            SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: widget.isMobile ? 18 : 22,
                                fontWeight: FontWeight.bold,
                                color: MyApp.homeDarkGreyText,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                          if (widget.isLocked)
                            Text(
                              'Locked',
                              style: TextStyle(
                                fontSize: widget.isMobile ? 14 : 16,
                                color: MyApp.homeGreyText,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'sans-serif',
                              ),
                            )
                          else
                            Icon(Icons.arrow_forward_ios, size: 14, color: MyApp.homeDarkGreyText),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: widget.isMobile ? 13 : 15,
                          color: MyApp.homeDarkGreyText,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                      if (widget.loading)
                        Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: MyApp.homeTealGreen),
                          ),
                        ),
                      if (widget.isLocked && widget.eligible && !widget.loading)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'You are in the top 20%. Final round will open when available.',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: MyApp.homeGreyText,
                              fontFamily: 'sans-serif',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
