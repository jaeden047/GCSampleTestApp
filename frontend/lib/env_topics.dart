import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; //supabase flutter sdk
import 'package:flutter_svg/flutter_svg.dart';
import 'quiz.dart';
import 'main.dart';

// EnvTopics page
// Showcase all environmental quiz topics for the users to select

class EnvTopics extends StatefulWidget {
  const EnvTopics({super.key});

  @override
  State<EnvTopics> createState() => _EnvTopicsState();
}

class _EnvTopicsState extends State<EnvTopics> {
  final supabase = Supabase.instance.client;
  Set<int> takenTopicIds = {}; // Track which topic IDs have been taken
  bool isLoading = true;
  Map<String, int> topicNameToId = {}; // Map topic names to their IDs

  @override
  void initState() {
    super.initState();
    _fetchTakenQuizzes();
    _fetchTopicIds();
  }

  // Fetch topic IDs for all topics
  Future<void> _fetchTopicIds() async {
    try {
      final topicData = await supabase.from('topics').select('topic_id, topic_name');
      final Map<String, int> tempMap = {};
      for (var topic in topicData) {
        tempMap[topic['topic_name']] = topic['topic_id'];
      }
      setState(() {
        topicNameToId = tempMap;
      });
    } catch (e) {
      // Handle error
    }
  }

  // Fetch which quizzes have been taken by the user
  Future<void> _fetchTakenQuizzes() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final testAttempts = await supabase
          .from('test_attempts')
          .select('topic_id')
          .eq('user_id', user.id);

      setState(() {
        takenTopicIds = testAttempts.map((attempt) => attempt['topic_id'] as int).toSet();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Check if a quiz is taken
  bool _isQuizTaken(String topicName) {
    final topicId = topicNameToId[topicName];
    if (topicId == null) return false;
    return takenTopicIds.contains(topicId);
  }

  // Start a new quiz: create an attempt and fetch questions
  Future<void> _startQuiz(BuildContext context, String topicName) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    final topicResponse = await supabase
        .from('topics')
        .select('topic_id')
        .eq('topic_name', topicName)
        .single();

    final topicId = topicResponse['topic_id'];

    // List of quizzes that are restricted to a single attempt only
    List<String> oneTryTopics = ['Plastic Pollution Focus'];

    // Check if the user has already attempted the specific quizzes
    if (oneTryTopics.contains(topicName)) {
      try {
        final response = await supabase.rpc('check_user_attempt', params: {
          'p_user_id': user.id,  // Current user ID
          'p_topic_id': topicId,  // Topic ID for the quiz
        });
        // If the response is true, user has already attempted the quiz
        if (response == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have already attempted this quiz.')),
          );
          return;
        }
        // Proceed with starting the quiz
      } catch (e) {
        // Handle any errors (e.g., network, function error)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking previous attempts: $e')),
        );
      }
    }

    try {
      // 1. Generate 10 question IDs for the quiz
      final questions = await supabase.rpc('generate_questions', params: {
        'topic_input': topicName,
      });

      if (questions is List) {
        final questionIds = questions.cast<int>();

        // 2. Create the quiz and generate an ID
        final quizAttempt = await supabase.rpc('create_new_quiz', params: {
          'p_user_id': user.id,
          'p_question_list': questionIds,
          'p_topic_id': topicId
        });

        if (quizAttempt is int) {
          // 3. Retrive the questions
          final quizQuestions = await supabase.rpc('retrieve_questions', params: {
            'input_attempt_id': quizAttempt,  // Pass the attempt_id
          });

          if (quizQuestions is List) {
            final questionsWithAnswers = quizQuestions.cast<Map<String, dynamic>>();
            // 4. Navigate to quiz page if the attempt ID is returned
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizPage(
                  attemptId: quizAttempt,
                  questions: questionsWithAnswers,
                  topicName: topicName,
                  onRedoQuiz: () => _startQuiz(context, topicName),
                ),
              ),
            ).then((_) {
              // Refresh taken quizzes after returning from quiz
              _fetchTakenQuizzes();
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting quiz: $e')),
      );
    }
  }

  // Check if screen is mobile
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);

    final topics = [
      {'title': 'Plastic Pollution Focus', 'description': 'The quiz consists of 15 questions and must be completed within 30 minutes. Each student is allowed only ONE attempt.'}
    ];

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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                return SingleChildScrollView(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Decorative elements - positioned around centered content
                      ..._buildDecorativeElements(screenWidth, screenHeight, isMobile),
                      // Main content
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16.0 : 24.0,
                          vertical: isMobile ? 16.0 : 24.0,
                        ),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Header card - Global Competition and Challenge
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
                                      "Environment Series 2025",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isMobile ? 15 : 18,
                                        color: MyApp.homeWhite,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "In partnership with the Moore Institute for Plastic Pollution Research, California, USA",
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
                                          'assets/images/mooreInstitute.png',
                                          height: isMobile ? 45 : 50,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Main container with teal background
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
                                    // Title: Environmental Problems
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
                                        'Environmental Problems',
                                        style: TextStyle(
                                          fontSize: isMobile ? 24 : 32,
                                          fontWeight: FontWeight.bold,
                                          color: MyApp.homeDarkGreyText,
                                          fontFamily: 'serif',
                                        ),
                                      ),
                                    ),

                                    // Quiz cards - pink blocks
                                    ...topics.map((topic) {
                                      final isTaken = _isQuizTaken(topic['title']!);
                                      return _HoverableQuizCard(
                                        topic: topic,
                                        isTaken: isTaken,
                                        isMobile: isMobile,
                                        onTap: () => _startQuiz(context, topic['title']!),
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
            ),
    );
  }

  // Build decorative clouds and stars around centered content
  List<Widget> _buildDecorativeElements(double screenWidth, double screenHeight, bool isMobile) {
    final elements = <Widget>[];
    final centerX = screenWidth / 2;
    final containerHalfWidth = 400; // Half of maxWidth 800
    final leftBoundary = centerX - containerHalfWidth;
    final rightBoundary = centerX + containerHalfWidth;
    
    // Calculate safe zones for decorations (outside the centered container)
    final leftZone = leftBoundary - 100; // Space on the left
    final rightZone = screenWidth - rightBoundary - 100; // Space on the right
    
    // Left side decorations (only if there's space) - more evenly distributed vertically
    if (leftZone > 50) {
      // Top section
      elements.add(
        Positioned(
          left: screenWidth * 0.05,
          top: screenHeight * 0.10,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 12.0 : 18.0,
            height: isMobile ? 11.3 : 17.0,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          left: screenWidth * 0.08,
          top: screenHeight * 0.18,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 10.0 : 15.0,
            height: isMobile ? 9.4 : 14.2,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          left: screenWidth * 0.03,
          top: screenHeight * 0.25,
          child: SvgPicture.asset(
            'assets/images/cloud.svg',
            width: isMobile ? 40 : 55,
            height: isMobile ? 28 : 38,
          ),
        ),
      );
      
      // Middle-top section
      elements.add(
        Positioned(
          left: screenWidth * 0.06,
          top: screenHeight * 0.35,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 14.0 : 20.0,
            height: isMobile ? 13.2 : 18.9,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          left: screenWidth * 0.04,
          top: screenHeight * 0.42,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 11.0 : 16.0,
            height: isMobile ? 10.4 : 15.1,
          ),
        ),
      );
      
      // Middle section
      elements.add(
        Positioned(
          left: screenWidth * 0.07,
          top: screenHeight * 0.50,
          child: SvgPicture.asset(
            'assets/images/cloud.svg',
            width: isMobile ? 35 : 48,
            height: isMobile ? 24 : 33,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          left: screenWidth * 0.05,
          top: screenHeight * 0.58,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 13.0 : 19.0,
            height: isMobile ? 12.3 : 17.9,
          ),
        ),
      );
      
      // Middle-bottom section
      elements.add(
        Positioned(
          left: screenWidth * 0.08,
          top: screenHeight * 0.65,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 10.0 : 15.0,
            height: isMobile ? 9.4 : 14.2,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          left: screenWidth * 0.04,
          top: screenHeight * 0.72,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 12.0 : 17.0,
            height: isMobile ? 11.3 : 16.0,
          ),
        ),
      );
      
      // Bottom section
      elements.add(
        Positioned(
          left: screenWidth * 0.06,
          top: screenHeight * 0.80,
          child: SvgPicture.asset(
            'assets/images/cloud.svg',
            width: isMobile ? 32 : 45,
            height: isMobile ? 22 : 31,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          left: screenWidth * 0.03,
          top: screenHeight * 0.88,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 11.0 : 16.0,
            height: isMobile ? 10.4 : 15.1,
          ),
        ),
      );
    }
    
    // Right side decorations (only if there's space) - more evenly distributed vertically
    if (rightZone > 50) {
      // Top section
      elements.add(
        Positioned(
          right: screenWidth * 0.05,
          top: screenHeight * 0.12,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 13.0 : 19.0,
            height: isMobile ? 12.3 : 17.9,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          right: screenWidth * 0.08,
          top: screenHeight * 0.20,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 9.0 : 14.0,
            height: isMobile ? 8.5 : 13.2,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          right: screenWidth * 0.03,
          top: screenHeight * 0.28,
          child: SvgPicture.asset(
            'assets/images/cloud.svg',
            width: isMobile ? 35 : 48,
            height: isMobile ? 24 : 33,
          ),
        ),
      );
      
      // Middle-top section
      elements.add(
        Positioned(
          right: screenWidth * 0.07,
          top: screenHeight * 0.38,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 12.0 : 17.0,
            height: isMobile ? 11.3 : 16.0,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          right: screenWidth * 0.04,
          top: screenHeight * 0.45,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 10.0 : 15.0,
            height: isMobile ? 9.4 : 14.2,
          ),
        ),
      );
      
      // Middle section
      elements.add(
        Positioned(
          right: screenWidth * 0.06,
          top: screenHeight * 0.53,
          child: SvgPicture.asset(
            'assets/images/cloud.svg',
            width: isMobile ? 38 : 52,
            height: isMobile ? 26 : 36,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          right: screenWidth * 0.08,
          top: screenHeight * 0.60,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 14.0 : 20.0,
            height: isMobile ? 13.2 : 18.9,
          ),
        ),
      );
      
      // Middle-bottom section
      elements.add(
        Positioned(
          right: screenWidth * 0.05,
          top: screenHeight * 0.68,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 11.0 : 16.0,
            height: isMobile ? 10.4 : 15.1,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          right: screenWidth * 0.07,
          top: screenHeight * 0.75,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 13.0 : 18.0,
            height: isMobile ? 12.3 : 17.0,
          ),
        ),
      );
      
      // Bottom section
      elements.add(
        Positioned(
          right: screenWidth * 0.04,
          top: screenHeight * 0.83,
          child: SvgPicture.asset(
            'assets/images/cloud.svg',
            width: isMobile ? 30 : 42,
            height: isMobile ? 20 : 28,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          right: screenWidth * 0.06,
          top: screenHeight * 0.90,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 10.0 : 15.0,
            height: isMobile ? 9.4 : 14.2,
          ),
        ),
      );
    }
    
    // Top decorations (above content)
    elements.add(
      Positioned(
        left: centerX - 100,
        top: screenHeight * 0.05,
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
        top: screenHeight * 0.08,
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
        top: screenHeight * 0.03,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 9.0 : 14.0,
          height: isMobile ? 8.5 : 13.2,
        ),
      ),
    );
    
    // Bottom decorations (below content, more evenly distributed)
    if (screenHeight > 600) {
      elements.add(
        Positioned(
          left: centerX - 80,
          top: screenHeight * 0.92,
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
          top: screenHeight * 0.95,
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
          top: screenHeight * 0.88,
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

// Hoverable quiz card widget (shared with math_grades.dart)
class _HoverableQuizCard extends StatefulWidget {
  final Map<String, String> topic;
  final bool isTaken;
  final bool isMobile;
  final VoidCallback onTap;

  const _HoverableQuizCard({
    required this.topic,
    required this.isTaken,
    required this.isMobile,
    required this.onTap,
  });

  @override
  State<_HoverableQuizCard> createState() => _HoverableQuizCardState();
}

class _HoverableQuizCardState extends State<_HoverableQuizCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.02 : 1.0),
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
                      // Title with "taken" indicator
                      Row(
                        children: [
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
                      // Description
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
