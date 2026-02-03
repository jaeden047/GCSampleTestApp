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
          _canShowResults = row != null && (row['is_sample_quiz'] == true || row['results_released'] == true);
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

  // Build decorative white clouds and stars around content
  List<Widget> _buildDecorativeElements(double screenWidth, double screenHeight, bool isMobile) {
    final elements = <Widget>[];
    
    // Top area decorations (around clipboard)
    elements.add(
      Positioned(
        left: screenWidth * 0.05,
        top: 50,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 12.0 : 18.0,
          height: isMobile ? 11.3 : 17.0,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.05,
        top: 60,
        child: SvgPicture.asset(
          'assets/images/white_cloud.svg',
          width: isMobile ? 35 : 48,
          height: isMobile ? 24 : 33,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.08,
        top: 120,
        child: SvgPicture.asset(
          'assets/images/white_cloud.svg',
          width: isMobile ? 40 : 55,
          height: isMobile ? 28 : 38,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.08,
        top: 140,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 14.0 : 20.0,
          height: isMobile ? 13.2 : 18.9,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.02,
        top: 200,
        child: SvgPicture.asset(
          'assets/images/white_cloud.svg',
          width: isMobile ? 28 : 40,
          height: isMobile ? 19 : 27,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.04,
        top: 280,
        child: SvgPicture.asset(
          'assets/images/white_cloud.svg',
          width: isMobile ? 32 : 45,
          height: isMobile ? 22 : 31,
        ),
      ),
    );
    
    // Middle area decorations (around text)
    elements.add(
      Positioned(
        left: screenWidth * 0.03,
        top: screenHeight * 0.45,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 11.0 : 16.0,
          height: isMobile ? 10.4 : 15.1,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.12,
        top: screenHeight * 0.42,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 10.0 : 14.0,
          height: isMobile ? 9.5 : 13.2,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.03,
        top: screenHeight * 0.48,
        child: SvgPicture.asset(
          'assets/images/white_cloud.svg',
          width: isMobile ? 32 : 45,
          height: isMobile ? 22 : 31,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.12,
        top: screenHeight * 0.50,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 12.0 : 17.0,
          height: isMobile ? 11.3 : 16.1,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.15,
        top: screenHeight * 0.55,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 9.0 : 13.0,
          height: isMobile ? 8.5 : 12.3,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.15,
        top: screenHeight * 0.58,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 11.0 : 15.0,
          height: isMobile ? 10.4 : 14.2,
        ),
      ),
    );
    
    // Bottom area decorations (above navigation) 
    elements.add(
      Positioned(
        left: screenWidth * 0.06,
        top: screenHeight * 0.75,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 13.0 : 18.0,
          height: isMobile ? 12.3 : 17.0,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.06,
        top: screenHeight * 0.77,
        child: SvgPicture.asset(
          'assets/images/white_cloud.svg',
          width: isMobile ? 30 : 42,
          height: isMobile ? 20 : 28,
        ),
      ),
    );
    
    // Additional star near bottom left
    elements.add(
      Positioned(
        left: screenWidth * 0.10,
        top: screenHeight * 0.80,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 10.0 : 14.0,
          height: isMobile ? 9.5 : 13.2,
        ),
      ),
    );
    
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
                        
                        SizedBox(width: isMobile ? 24 : 32),
                        
                        // Share button
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Share functionality - do nothing for now
                              },
                              child: SizedBox(
                                width: isMobile ? 60 : 80,
                                height: isMobile ? 60 : 80,
                                child: SvgPicture.asset(
                                  'assets/images/share_icon.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 8 : 12),
                            Text(
                              'Share',
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
