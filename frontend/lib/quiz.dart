import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
import 'dart:async'; // Importing for Timer
import 'post_quiz.dart';
import 'results.dart';
import 'main.dart';
import 'math_text.dart';

class QuizPage extends StatefulWidget {
  final int attemptId;
  final List<dynamic> questions;
  final String topicName;
  final VoidCallback onRedoQuiz;

  const QuizPage({
    super.key,
    required this.attemptId,
    required this.questions,
    required this.topicName,
    required this.onRedoQuiz,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<dynamic> _questions = [];
  final Map<String, int> _selectedAnswers = {}; // question_id -> answer_id (as String keys)
  int? _attemptId;
  bool _loading = true;
  int _currentQuestionIndex = 0; // Track current question

  int _timeLeft = 1800; // set 30 mins (1800 seconds)
  late Timer _timer; // Timer instance

  @override
  void initState() {
    super.initState();
    _attemptId = widget.attemptId;
    _questions = widget.questions;
    _loading = false;

    // Start the timer
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer.cancel(); // Stop the timer when time is up
        // Handle time out logic here, such as submitting the quiz
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Make sure to cancel the timer when the page is disposed
    super.dispose();
  }

  // Move to next question
  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  // Check if current question has an answer selected
  bool _hasAnswerSelected() {
    if (_currentQuestionIndex >= _questions.length) return false;
    final question = _questions[_currentQuestionIndex];
    return _selectedAnswers.containsKey(question['question_id'].toString());
  }

  Future<void> _submitQuiz() async {
    final supabase = Supabase.instance.client;
    int timePast = 1800 - _timeLeft; // calculate how many seconds it took to finish the quiz
    try {
      final scoreRaw = await supabase.rpc('calculate_score', params: {
        'input_time': timePast,
        'selected_answers': _selectedAnswers,
        'input_attempt_id': _attemptId,
      });
      print(scoreRaw);
      final double score = (scoreRaw as num).toDouble();
      print(score);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostQuiz(
              score: score,
              onRedoQuiz: widget.onRedoQuiz,
              topicName: widget.topicName,
              onViewAnswers: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Results(),
                ),
              ),
              attemptId: _attemptId!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit quiz: $e')),
        );
      }
    }
  }

  // Check if screen is mobile
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isMobile = _isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Convert time left to minutes and seconds
    String minutes = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    String seconds = (_timeLeft % 60).toString().padLeft(2, '0');
    String timerText = '$minutes:$seconds';

    final currentQuestion = _questions[_currentQuestionIndex];
    final answers = currentQuestion['answers'] as List;
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: MyApp.homeLightPink, // Light pink background like design
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative elements - white clouds and stars
          ..._buildDecorativeElements(screenWidth, screenHeight, isMobile),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar with back button, progress, and timer
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 24.0,
                    vertical: isMobile ? 12.0 : 16.0,
                  ),
                  child: Row(
                    children: [
                      // Back button
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: MyApp.homeDarkGreyText),
                        onPressed: () => Navigator.pop(context),
                      ),
                      
                      // Progress bar
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 16.0),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: MyApp.homeTealGreen,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Timer badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: MyApp.homeWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: MyApp.homeTealGreen,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: isMobile ? 16 : 18,
                              color: MyApp.homeTealGreen,
                            ),
                            SizedBox(width: 6),
                            Text(
                              timerText,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: MyApp.homeTealGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Question area with decorations
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 20.0 : 40.0,
                        vertical: isMobile ? 20.0 : 30.0,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isMobile ? double.infinity : 600,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Question card
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isMobile ? 20 : 24),
                              decoration: BoxDecoration(
                                color: MyApp.homeWhite,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Question number and text (supports LaTeX when stored in DB)
                                  MathText(
                                    '${_currentQuestionIndex + 1}. ${currentQuestion['question_text']}',
                                    textStyle: TextStyle(
                                      fontSize: isMobile ? 18 : 22,
                                      fontWeight: FontWeight.bold,
                                      color: MyApp.homeDarkGreyText,
                                      fontFamily: 'serif',
                                    ),
                                  ),
                                  
                                  SizedBox(height: isMobile ? 20 : 24),
                                  
                                  // Answer options
                                  ...answers.map((ans) {
                                    final isSelected = _selectedAnswers[currentQuestion['question_id'].toString()] == ans['answer_id'];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _selectedAnswers[currentQuestion['question_id'].toString()] = ans['answer_id'];
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: EdgeInsets.all(isMobile ? 16 : 20),
                                          decoration: BoxDecoration(
                                            color: isSelected 
                                                ? MyApp.homeTealGreen.withOpacity(0.1)
                                                : Colors.grey[100],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected 
                                                  ? MyApp.homeTealGreen
                                                  : Colors.grey[300]!,
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              // Radio button indicator
                                              Container(
                                                width: isMobile ? 20 : 24,
                                                height: isMobile ? 20 : 24,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isSelected 
                                                        ? MyApp.homeTealGreen
                                                        : Colors.grey[400]!,
                                                    width: 2,
                                                  ),
                                                  color: isSelected 
                                                      ? MyApp.homeTealGreen
                                                      : Colors.transparent,
                                                ),
                                                child: isSelected
                                                    ? Icon(
                                                        Icons.check,
                                                        size: isMobile ? 14 : 16,
                                                        color: MyApp.homeWhite,
                                                      )
                                                    : null,
                                              ),
                                              SizedBox(width: 12),
                                              // Answer text (supports LaTeX when stored in DB)
                                              Expanded(
                                                child: MathText(
                                                  ans['answer_text'] ?? '',
                                                  textStyle: TextStyle(
                                                    fontSize: isMobile ? 15 : 17,
                                                    color: MyApp.homeDarkGreyText,
                                                    fontFamily: 'serif',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Bottom button (Next or Submit)
                Padding(
                  padding: EdgeInsets.all(isMobile ? 20.0 : 24.0),
                  child: Center(
                    child: GestureDetector(
                      onTap: _hasAnswerSelected()
                          ? (isLastQuestion ? _submitQuiz : _nextQuestion)
                          : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 40 : 60,
                          vertical: isMobile ? 14 : 18,
                        ),
                        decoration: BoxDecoration(
                          color: _hasAnswerSelected()
                              ? MyApp.homeTealGreen
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: _hasAnswerSelected()
                              ? [
                                  BoxShadow(
                                    color: MyApp.homeTealGreen.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLastQuestion ? 'Submit' : 'Next',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: MyApp.homeWhite,
                                fontFamily: 'serif',
                              ),
                            ),
                            if (isLastQuestion) ...[
                              SizedBox(width: 8),
                              Icon(
                                Icons.check,
                                color: MyApp.homeWhite,
                                size: isMobile ? 20 : 24,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build decorative white clouds and stars around question area
  List<Widget> _buildDecorativeElements(double screenWidth, double screenHeight, bool isMobile) {
    final elements = <Widget>[];
    final centerX = screenWidth / 2;
    final questionAreaTop = screenHeight * 0.15; // Approximate top of question area
    final questionAreaBottom = screenHeight * 0.75; // Approximate bottom of question area
    
    // Left side decorations
    elements.add(
      Positioned(
        left: screenWidth * 0.05,
        top: questionAreaTop + 50,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 12.0 : 18.0,
          height: isMobile ? 11.3 : 17.0,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.08,
        top: questionAreaTop + 150,
        child: SvgPicture.asset(
          'assets/images/white_cloud.svg',
          width: isMobile ? 40 : 55,
          height: isMobile ? 28 : 38,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.03,
        top: questionAreaTop + 250,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 14.0 : 20.0,
          height: isMobile ? 13.2 : 18.9,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.06,
        top: questionAreaTop + 350,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 10.0 : 15.0,
          height: isMobile ? 9.4 : 14.2,
        ),
      ),
    );
    
    // Right side decorations
    elements.add(
      Positioned(
        right: screenWidth * 0.05,
        top: questionAreaTop + 80,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 13.0 : 19.0,
          height: isMobile ? 12.3 : 17.9,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.08,
        top: questionAreaTop + 180,
        child: SvgPicture.asset(
          'assets/images/white_cloud.svg',
          width: isMobile ? 35 : 48,
          height: isMobile ? 24 : 33,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.03,
        top: questionAreaTop + 280,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 11.0 : 16.0,
          height: isMobile ? 10.4 : 15.1,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.06,
        top: questionAreaTop + 380,
        child: SvgPicture.asset(
          'assets/images/white_cloud.svg',
          width: isMobile ? 32 : 45,
          height: isMobile ? 22 : 31,
        ),
      ),
    );
    
    // Top decorations
    elements.add(
      Positioned(
        left: centerX - 100,
        top: questionAreaTop - 20,
        child: SvgPicture.asset(
          'assets/images/white_star.svg',
          width: isMobile ? 11.0 : 16.0,
          height: isMobile ? 10.4 : 15.1,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: centerX + 50,
        top: questionAreaTop - 10,
        child: SvgPicture.asset(
          'assets/images/white_cloud.svg',
          width: isMobile ? 30 : 42,
          height: isMobile ? 20 : 28,
        ),
      ),
    );
    
    // Bottom decorations
    if (questionAreaBottom < screenHeight - 100) {
      elements.add(
        Positioned(
          left: centerX - 80,
          top: questionAreaBottom + 20,
          child: SvgPicture.asset(
            'assets/images/white_star.svg',
            width: isMobile ? 13.0 : 18.0,
            height: isMobile ? 12.3 : 17.0,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          right: centerX - 120,
          top: questionAreaBottom + 30,
          child: SvgPicture.asset(
            'assets/images/white_cloud.svg',
            width: isMobile ? 28 : 40,
            height: isMobile ? 19 : 27,
          ),
        ),
      );
    }
    
    return elements;
  }
}