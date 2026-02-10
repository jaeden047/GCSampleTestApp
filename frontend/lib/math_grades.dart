import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; //supabase flutter sdk
import 'quiz.dart';
import 'main.dart';
import 'quiz_rules.dart';
import 'math_round_selection.dart';

class MathGrades extends StatelessWidget {
  const MathGrades({super.key});

  String? allowedTopicFromGrade(String? grade) {
    if (grade == null) return null;
    if (grade == '5' || grade == '6') return 'Grade 5 and 6';
    if (grade == '7' || grade == '8') return 'Grade 7 and 8';
    if (grade == '9' || grade == '10') return 'Grade 9 and 10';
    if (grade == '11' || grade == '12') return 'Grade 11 and 12';
    return null;
  }

  /// Math categories that use round selection (Sample / Local / Final).
  static const _mathRoundTopicNames = [
    'Grade 5 and 6',
    'Grade 7 and 8',
    'Grade 9 and 10',
    'Grade 11 and 12',
  ];

  /// Starts a quiz for the given topic and round. For 'sample' uses question_sets; for local/final uses generate_questions when unlocked.
  /// [roundSelectionContext] if set is popped before pushing quiz rules.
  Future<void> _startQuiz(BuildContext context, String topicName,
      [String round = 'sample', BuildContext? roundSelectionContext]) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
      }
      return;
    }

    int topicId;
    try {
      final topicResponse = await supabase
          .from('topics')
          .select('topic_id') // collects ID of grade topic chosen
          .eq('topic_name', topicName)
          .single();
      topicId = topicResponse['topic_id'] as int; // converts map to int
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load topic. Please try again.')),
        );
      }
      return;
    }

    List<int> questionIds;
    int? questionSetId;

    if (round == 'sample') {
      try {
        final setRow = await supabase
            .from('question_sets')
            .select('set_id')
            .eq('topic_id', topicId) // find the topic id // "Sample Quiz" id
            .eq('round', 'sample') // give us the sample
            .eq('set_number', 1) // give us the first set 
            .maybeSingle();
        if (setRow == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No questions found, come back later.')),
            );
          }
          return;
        }
        final setId = setRow['set_id'] as int; // convert the set's id to int
        questionSetId = setId; // copy
        final qRows = await supabase
            .from('questions')
            .select('question_id')
            .eq('question_set_id', setId);
        questionIds = (qRows as List).map<int>((r) => r['question_id'] as int).toList();
        questionIds.shuffle(Random());
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions found, come back later.')),
          );
        }
        return;
      }
      if (questionIds.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions found, come back later.')),
          );
        }
        return;
      }
    } else {
      try { // if round not sample, generate questions based on the grade chosen
        final questions = await supabase.rpc('generate_questions', params: {
          'topic_input': topicName,
        });
        if (questions is! List || questions.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No questions found, come back later.')),
            );
          }
          return;
        }
        questionIds = questions.cast<int>();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error loading questions. Please try again.')),
          );
        }
        return;
      }
    }

    try {
      final quizAttempt = await supabase.rpc('create_new_quiz', params: {
        'p_user_id': user.id,
        'p_question_list': questionIds,
        'p_topic_id': topicId
      });

      if (quizAttempt is! int) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not start quiz. Please try again.')),
          );
        }
        return;
      }

      final updates = <String, dynamic>{'round': round};
      if (questionSetId != null) { // finds next questionset
        updates['question_set_id'] = questionSetId;
      }
      await supabase.from('test_attempts').update(updates).eq('attempt_id', quizAttempt);

      final quizQuestions = await supabase.rpc('retrieve_questions', params: {
        'input_attempt_id': quizAttempt,
      });

      if (quizQuestions is! List || quizQuestions.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not load questions. Please try again.')),
          );
        }
        return;
      }

      final questionsWithAnswers = quizQuestions.cast<Map<String, dynamic>>();
      if (!context.mounted) return;
      if (roundSelectionContext != null && roundSelectionContext.mounted) {
        Navigator.pop(roundSelectionContext);
      }
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizRulesScreen(
            onAgree: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPage(
                    attemptId: quizAttempt,
                    questions: questionsWithAnswers,
                    topicName: topicName,
                    onRedoQuiz: () => _startQuiz(context, topicName, round),
                    timeLimitSeconds: round == 'sample' ? 15 * 60 : 60 * 60, // sample 15 min, local/final 60 min
                  ),
                ),
              );
            },
            onClose: () {
              Navigator.pop(context);
            },
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error starting quiz. Please try again.')),
        );
      }
    }
  }

  // Check if screen is mobile
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  // Placeholder to avoid compile error; replace with your real implementation.
  bool _isQuizTaken(String topicName) {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final topics = [
      {
        'title': 'Grade 5 and 6',
        'description':
            'Sample quiz, local round, and final round. Complete the sample quiz to practice.'
      },
      {
        'title': 'Grade 7 and 8',
        'description':
            'Sample quiz, local round, and final round. Complete the sample quiz to practice.'
      },
      {
        'title': 'Grade 9 and 10',
        'description':
            'Sample quiz, local round, and final round. Complete the sample quiz to practice.'
      },
      {
        'title': 'Grade 11 and 12',
        'description':
            'Sample quiz, local round, and final round. Complete the sample quiz to practice.'
      }
    ];

    final isMobile = _isMobile(context);

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
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.instance.getProfile(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final grade = snap.data!['user']?['grade']?.toString();
          final allowedTopic = allowedTopicFromGrade(grade);

          return LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              final numTopics = 4;
              final estimatedContentHeight = 200.0 + 80.0 + (numTopics * 140.0);
              final actualContentHeight = estimatedContentHeight > screenHeight
                  ? estimatedContentHeight
                  : screenHeight;

              return SingleChildScrollView(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ..._buildDecorativeElements(screenWidth, actualContentHeight, isMobile, numTopics),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16.0 : 24.0,
                        vertical: isMobile ? 16.0 : 24.0,
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Header card - Global Competition and Challenge (teal, dl_android style)
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: isMobile ? double.infinity : 800,
                              ),
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
                                    'Global Competition and Challenge',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 18 : 22,
                                      color: MyApp.homeWhite,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Math Series 2025',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 15 : 18,
                                      color: MyApp.homeWhite,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'In partnership with Saddle River Day School, New Jersey, USA',
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
                                      Image.asset(
                                        'assets/images/gc_logo.jpg',
                                        height: isMobile ? 45 : 50,
                                      ),
                                      SizedBox(width: 16),
                                      Image.asset(
                                        'assets/images/school_logo.png',
                                        height: isMobile ? 45 : 50,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Main container with teal background (Math Problems + quiz cards)
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: isMobile ? double.infinity : 800,
                              ),
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
                                      'Math Problems',
                                      style: TextStyle(
                                        fontSize: isMobile ? 24 : 32,
                                        fontWeight: FontWeight.bold,
                                        color: MyApp.homeDarkGreyText,
                                        fontFamily: 'serif',
                                      ),
                                    ),
                                  ),
                                  ...topics.map((topic) {
                                    final topicName = topic['title']!;
                                    final isTaken = _isQuizTaken(topicName);
                                    final useRoundSelection = _mathRoundTopicNames.contains(topicName);
                                    final isLocked = topicName != allowedTopic;

                                    return _HoverableQuizCard(
                                      topic: topic,
                                      isTaken: isTaken,
                                      isMobile: isMobile,
                                      isLocked: isLocked,
                                      onTap: () {
                                        if (isLocked) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Locked. Your grade allows: $allowedTopic')),
                                          );
                                          return;
                                        }
                                        if (useRoundSelection) {
                                          final mathGradesContext = context;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MathRoundSelection(
                                                topicName: topicName,
                                                onStartSampleQuiz: (roundSelectionContext) =>
                                                    _startQuiz(
                                                  mathGradesContext,
                                                  topicName,
                                                  'sample',
                                                  roundSelectionContext,
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          _startQuiz(context, topicName);
                                        }
                                      },
                                    );
                                  }),
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
          );
        },
      ),
    );
  }

  // Build decorative clouds and stars dynamically distributed along content height
  List<Widget> _buildDecorativeElements(
    double screenWidth,
    double contentHeight,
    bool isMobile,
    int numItems,
  ) {
    final elements = <Widget>[];
    final centerX = screenWidth / 2;
    final containerHalfWidth = 400; // Half of maxWidth 800
    final leftBoundary = centerX - containerHalfWidth;
    final rightBoundary = centerX + containerHalfWidth;

    // Calculate safe zones for decorations (outside the centered container)
    final leftZone = leftBoundary - 100; // Space on the left
    final rightZone = screenWidth - rightBoundary - 100; // Space on the right

    // Calculate spacing between decorations
    final minSpacing = isMobile ? 60.0 : 80.0;

    // Calculate number of decoration rows needed
    final numDecorationRows = (contentHeight / minSpacing).ceil();

    // Top padding to start decorations below the header
    final topPadding = 100.0;
    final bottomPadding = 50.0;
    final usableHeight = contentHeight - topPadding - bottomPadding;
    final adjustedSpacing = usableHeight / (numDecorationRows + 1);

    // Star sizes (varied for visual interest)
    final starSizes = [
      {'w': isMobile ? 9.0 : 14.0, 'h': isMobile ? 8.5 : 13.2},
      {'w': isMobile ? 10.0 : 15.0, 'h': isMobile ? 9.4 : 14.2},
      {'w': isMobile ? 11.0 : 16.0, 'h': isMobile ? 10.4 : 15.1},
      {'w': isMobile ? 12.0 : 17.0, 'h': isMobile ? 11.3 : 16.0},
      {'w': isMobile ? 13.0 : 18.0, 'h': isMobile ? 12.3 : 17.0},
      {'w': isMobile ? 14.0 : 20.0, 'h': isMobile ? 13.2 : 18.9},
    ];

    // Cloud sizes (varied)
    final cloudSizes = [
      {'w': isMobile ? 28 : 40, 'h': isMobile ? 19 : 27},
      {'w': isMobile ? 30 : 42, 'h': isMobile ? 20 : 28},
      {'w': isMobile ? 32 : 45, 'h': isMobile ? 22 : 31},
      {'w': isMobile ? 35 : 48, 'h': isMobile ? 24 : 33},
      {'w': isMobile ? 38 : 52, 'h': isMobile ? 26 : 36},
      {'w': isMobile ? 40 : 55, 'h': isMobile ? 28 : 38},
    ];

    // Left side positions (varied for natural look)
    final leftPositions = [0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08];
    // Right side positions
    final rightPositions = [0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08];

    // Track used positions separately for left and right to ensure even distribution
    final usedPositionsLeft = <double>[];
    final usedPositionsRight = <double>[];
    final minDistanceBetween = 40.0; // Further reduced for higher density

    // NOTE: This method references SvgPicture but you did not import flutter_svg here.
    // Keeping your code as-is structurally; add:
    // import 'package:flutter_svg/flutter_svg.dart';
    // if you use this method.

    for (int i = 0; i < numDecorationRows; i++) {
      final baseY = topPadding + (adjustedSpacing * (i + 1));

      final randomOffset = (i % 3 - 1) * 12.0; // -12, 0, or 12
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
}

// Hoverable quiz card widget
class _HoverableQuizCard extends StatefulWidget {
  final Map<String, String> topic;
  final bool isTaken;
  final bool isMobile;
  final bool isLocked;
  final VoidCallback onTap;

  const _HoverableQuizCard({
    required this.topic,
    required this.isTaken,
    required this.isMobile,
    required this.onTap,
    this.isLocked = false, //
  });

  @override
  State<_HoverableQuizCard> createState() => _HoverableQuizCardState();
}

class _HoverableQuizCardState extends State<_HoverableQuizCard> {
  bool _isHovered = false;

  /*
  MouseRegion = hover detection wrapper
  GestureDetector = tap/click wrapper
  AnimatedContainer = the actual “card body” (the styled rectangle)
  Opacity/Row/Column/Text = the content inside the card
  */

  @override
  Widget build(BuildContext context) { // builds card
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false), // mouse hover
      child: GestureDetector( // makes card clickable/tappable
        onTap: widget.onTap, // cals function on tap
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          margin: EdgeInsets.only(bottom: widget.isMobile ? 20 : 24),
          padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: MyApp.homeLightPink,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.1),
                blurRadius: _isHovered ? 6 : 4,
                offset: Offset(0, _isHovered ? 4 : 2),
              ),
            ],
          ),
          child: Opacity(
            opacity: _isHovered ? 0.95 : 1.0,
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
                              widget.topic['title']!,
                              style: TextStyle(
                                fontSize: widget.isMobile ? 18 : 22,
                                fontWeight: FontWeight.bold,
                                color: MyApp.homeDarkGreyText,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                          if (widget.isTaken)
                            Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: widget.isMobile ? 14 : 16,
                                color: MyApp.homeGreyText,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'sans-serif',
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.topic['description']!,
                        style: TextStyle(
                          fontSize: widget.isMobile ? 13 : 15,
                          color: MyApp.homeDarkGreyText,
                          fontFamily: 'sans-serif',
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
