import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; //supabase flutter sdk
import 'package:flutter_svg/flutter_svg.dart';
import 'quiz.dart';
import 'main.dart';
import 'quiz_rules.dart';
import 'math_round_selection.dart';

class MathGrades extends StatefulWidget {
  const MathGrades({super.key});

  @override
  State<MathGrades> createState() => _MathGradesState();
}

class _MathGradesState extends State<MathGrades> {
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

  /// Math categories that use round selection (Sample / Local / Final).
  static const _mathRoundTopicNames = [
    'Grade 5 and 6',
    'Grade 7 and 8',
    'Grade 9 and 10',
    'Grade 11 and 12',
  ];

  /// Starts a quiz for the given topic and round. For 'sample' uses question_sets; for local/final uses generate_questions when unlocked.
  /// [roundSelectionContext] if set is popped before pushing quiz rules.
  Future<void> _startQuiz(BuildContext context, String topicName, [String round = 'sample', BuildContext? roundSelectionContext]) async {
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
          .select('topic_id')
          .eq('topic_name', topicName)
          .single();
      topicId = topicResponse['topic_id'] as int;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load topic. Please try again.')),
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
            .eq('topic_id', topicId)
            .eq('round', 'sample')
            .eq('set_number', 1)
            .maybeSingle();
        if (setRow == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No questions found, come back later.')),
            );
          }
          return;
        }
        final setId = setRow['set_id'] as int;
        questionSetId = setId;
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
      try {
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
            SnackBar(content: Text('Error loading questions. Please try again.')),
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
      if (questionSetId != null) {
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
              ).then((_) {
                _fetchTakenQuizzes();
              });
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
          SnackBar(content: Text('Error starting quiz. Please try again.')),
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
    final isMobile = _isMobile(context);

    final topics = [
      {'title': 'Grade 5 and 6', 'description': 'Sample quiz, local round, and final round. Complete the sample quiz to practice.'},
      {'title': 'Grade 7 and 8', 'description': 'Sample quiz, local round, and final round. Complete the sample quiz to practice.'},
      {'title': 'Grade 9 and 10', 'description': 'Sample quiz, local round, and final round. Complete the sample quiz to practice.'},
      {'title': 'Grade 11 and 12', 'description': 'Sample quiz, local round, and final round. Complete the sample quiz to practice.'}
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
                
                // Calculate estimated content height based on number of topics
                // Header card: ~200px, Title: ~80px, Each quiz card: ~120px, spacing: ~20px
                final numTopics = topics.length;
                final estimatedContentHeight = 200.0 + 80.0 + (numTopics * 140.0);
                final actualContentHeight = estimatedContentHeight > screenHeight 
                    ? estimatedContentHeight 
                    : screenHeight;
                
                return SingleChildScrollView(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Decorative elements - dynamically distributed
                      ..._buildDecorativeElements(screenWidth, actualContentHeight, isMobile, numTopics),
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
                          // Title: Math Problems
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

                          // Quiz cards - pink blocks
                          ...topics.map((topic) {
                            final topicName = topic['title']!;
                            final isTaken = _isQuizTaken(topicName);
                            final useRoundSelection = _mathRoundTopicNames.contains(topicName);
                            return _HoverableQuizCard(
                              topic: topic,
                              isTaken: isTaken,
                              isMobile: isMobile,
                              onTap: () {
                                if (useRoundSelection) {
                                  final mathGradesContext = context;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MathRoundSelection(
                                        topicName: topicName,
                                        onStartSampleQuiz: (roundSelectionContext) => _startQuiz(mathGradesContext, topicName, 'sample', roundSelectionContext),
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
    // Further reduced spacing for even higher density - decorations every 60-80px vertically
    final minSpacing = isMobile ? 60.0 : 80.0;
    
    // Calculate number of decoration rows needed (increased for more density)
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
    
    // Generate decorations dynamically - ensuring BOTH sides get decorations evenly
    for (int i = 0; i < numDecorationRows; i++) {
      final baseY = topPadding + (adjustedSpacing * (i + 1));
      
      // Add some randomness to Y position (±12px) to make it look more natural
      final randomOffset = (i % 3 - 1) * 12.0; // -12, 0, or 12
      final y = baseY + randomOffset;
      
      // Determine decoration type ONCE per row - ensures both sides get the same type
      // Clouds appear less frequently: every 5th or 7th item for balance
      final useCloud = (i % 5 == 0 || i % 7 == 0);
      
      // Add decoration on LEFT side (if space available)
      if (leftZone > 50) {
        // Check if left position is not too close to other left decorations
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
      
      // Add decoration on RIGHT side (if space available) - use SAME type as left for balance
      if (rightZone > 50) {
        // Use slightly different Y position for right side to avoid exact mirroring
        final rightY = y + ((i % 2 == 0) ? 8.0 : -8.0);
        
        // Check if right side position is not too close to other right decorations
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
          
          // Use the SAME decoration type as left side to ensure perfect balance
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
    
    // Add top decorations (above content)
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
    
    // Add bottom decorations (below content)
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
