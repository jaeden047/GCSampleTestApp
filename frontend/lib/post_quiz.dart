import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';
import 'main.dart';
import 'leaderboard.dart';
import 'quiz_answers.dart';

class PostQuiz extends StatefulWidget {
  final double score;
  final VoidCallback onRedoQuiz;
  final String topicName;
  final VoidCallback onViewAnswers;
  final int attemptId;

  const PostQuiz({
    super.key,
    required this.score,
    required this.onRedoQuiz,
    required this.topicName,
    required this.onViewAnswers,
    required this.attemptId,
  });

  @override
  State<PostQuiz> createState() => _PostQuizState();
}

class _PostQuizState extends State<PostQuiz> {
  bool? _canShowResults;
  bool _loadingRelease = true;

  @override
  void initState() {
    super.initState();
    _fetchReleaseStatus();
  }

  static const _mathRoundTopicNames = ['Grade 5 and 6', 'Grade 7 and 8', 'Grade 9 and 10', 'Grade 11 and 12'];

  Future<void> _fetchReleaseStatus() async {
    try {
      final row = await Supabase.instance.client
          .from('topics')
          .select('results_released, is_sample_quiz')
          .eq('topic_name', widget.topicName)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _loadingRelease = false;
          // Sample quiz always unlocked for math grade topics; otherwise use topic flags
          _canShowResults = _mathRoundTopicNames.contains(widget.topicName) ||
              (row != null && (row['is_sample_quiz'] == true || row['results_released'] == true));
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingRelease = false;
          _canShowResults = false;
        });
      }
    }
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  /// Build decorative clouds and stars in safe zones only—never over content.
  /// Places decorations in left/right margins (0–4% and 96–100% width) and in
  /// top/bottom bands, avoiding the center content area (main text and icons).
  List<Widget> _buildDecorativeElements(double screenWidth, double screenHeight, bool isMobile) {
    final elements = <Widget>[];
    final starW = isMobile ? 12.0 : 18.0;
    final starH = isMobile ? 11.3 : 17.0;
    final cloudW = isMobile ? 28.0 : 40.0;
    final cloudH = isMobile ? 19.0 : 27.0;

    // Content exclusion: center 92% of width (4% margin each side), vertical band 28%-72% (main text)
    final leftMargin = screenWidth * 0.02;
    final rightMargin = screenWidth * 0.02;
    final topSafe = screenHeight * 0.12;
    final bottomSafe = screenHeight * 0.72;

    // Top-left (above content)
    elements.add(Positioned(left: leftMargin, top: topSafe * 0.3, child: SvgPicture.asset('assets/images/white_star.svg', width: starW, height: starH)));
    elements.add(Positioned(left: leftMargin, top: topSafe * 0.6, child: SvgPicture.asset('assets/images/white_cloud.svg', width: cloudW, height: cloudH)));

    // Top-right
    elements.add(Positioned(right: rightMargin, top: topSafe * 0.25, child: SvgPicture.asset('assets/images/white_cloud.svg', width: cloudW * 1.2, height: cloudH * 1.2)));
    elements.add(Positioned(right: rightMargin, top: topSafe * 0.55, child: SvgPicture.asset('assets/images/white_star.svg', width: starW * 1.1, height: starH * 1.1)));

    // Bottom-left (below main text, above nav)
    elements.add(Positioned(left: leftMargin, top: bottomSafe + screenHeight * 0.08, child: SvgPicture.asset('assets/images/white_star.svg', width: starW * 1.1, height: starH * 1.1)));
    elements.add(Positioned(left: leftMargin, top: bottomSafe + screenHeight * 0.18, child: SvgPicture.asset('assets/images/white_cloud.svg', width: cloudW * 0.9, height: cloudH * 0.9)));

    // Bottom-right
    elements.add(Positioned(right: rightMargin, top: bottomSafe + screenHeight * 0.05, child: SvgPicture.asset('assets/images/white_cloud.svg', width: cloudW, height: cloudH)));
    elements.add(Positioned(right: rightMargin, top: bottomSafe + screenHeight * 0.15, child: SvgPicture.asset('assets/images/white_star.svg', width: starW, height: starH)));

    return elements;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final canShow = _canShowResults == true;
    final stillLoading = _loadingRelease;

    return Scaffold(
      backgroundColor: MyApp.homeTealGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ..._buildDecorativeElements(screenWidth, screenHeight, isMobile),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16.0 : 24.0,
                  vertical: isMobile ? 16.0 : 24.0,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: isMobile ? 10 : 20),
                      SizedBox(
                        width: isMobile ? screenWidth * 0.4 : 200,
                        height: isMobile ? screenWidth * 0.4 : 200,
                        child: SvgPicture.asset(
                          'assets/images/quiz_congrats.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      // Score badge (or "Results when released" when locked)
                      if (stillLoading)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: MyApp.homeWhite, strokeWidth: 2),
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 24 : 32,
                            vertical: isMobile ? 8 : 12,
                          ),
                          decoration: BoxDecoration(
                            color: MyApp.homeTealGreen,
                            border: Border.all(color: MyApp.homeWhite, width: 2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (canShow) ...[
                                SvgPicture.asset(
                                  'assets/images/white_star.svg',
                                  width: isMobile ? 20 : 24,
                                  height: isMobile ? 18.9 : 22.7,
                                ),
                                SizedBox(width: isMobile ? 8 : 12),
                                Text(
                                  '${widget.score.toInt()} pts',
                                  style: TextStyle(
                                    fontSize: isMobile ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: MyApp.homeWhite,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ] else ...[
                                Icon(Icons.lock_outline, color: MyApp.homeWhite, size: isMobile ? 20 : 24),
                                SizedBox(width: isMobile ? 8 : 12),
                                Text(
                                  'Results to be released soon!',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    fontWeight: FontWeight.w600,
                                    color: MyApp.homeWhite,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                  
                  SizedBox(height: isMobile ? 20 : 24),
                  
                  // Congrats message
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 40),
                    child: Text(
                      'You have completed the quiz!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 32 : 42,
                        fontWeight: FontWeight.bold,
                        color: MyApp.homeWhite,
                        fontFamily: 'serif',
                        height: 1.2,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isMobile ? 12 : 16),
                  
                  // Instructions text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 32 : 48),
                    child: Text(
                      'You can now see the leaderboard or continue with another quiz to rank up in the leaderboard.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: MyApp.homeWhite.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isMobile ? 60 : 70),
                  
                  // Bottom navigation icons
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 40,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Home button
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const Home()),
                                  (route) => false,
                                );
                              },
                              child: SizedBox(
                                width: isMobile ? 60 : 80,
                                height: isMobile ? 60 : 80,
                                child: SvgPicture.asset(
                                  'assets/images/home_icon.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 8 : 12),
                            Text(
                              'Home',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: MyApp.homeDarkGreyText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(width: isMobile ? 24 : 32),
                        
                        // Leaderboard button
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Leaderboard(topicName: widget.topicName),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: isMobile ? 60 : 80,
                                height: isMobile ? 60 : 80,
                                child: SvgPicture.asset(
                                  'assets/images/leaderboard_icon.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 8 : 12),
                            Text(
                              'Leaderboard',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: MyApp.homeDarkGreyText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(width: isMobile ? 24 : 32),
                        
                        // Answers button (disabled until release unless sample)
                        Column(
                          children: [
                            GestureDetector(
                              onTap: canShow
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => QuizAnswers(attemptId: widget.attemptId),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Opacity(
                                opacity: canShow ? 1.0 : 0.5,
                                child: SizedBox(
                                  width: isMobile ? 60 : 80,
                                  height: isMobile ? 60 : 80,
                                  child: SvgPicture.asset(
                                    'assets/images/book.svg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 8 : 12),
                            Text(
                              canShow ? 'Answers' : 'After release',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: MyApp.homeDarkGreyText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isMobile ? 20 : 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
