import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'main.dart';

class Leaderboard extends StatefulWidget {
  final String topicName;

  const Leaderboard({
    super.key,
    required this.topicName,
  });

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  String? selectedTopic;
  List<Map<String, dynamic>> topicList = [];
  bool isLoadingTopics = true;

  @override
  void initState() {
    super.initState();
    selectedTopic = widget.topicName;
    _fetchTopics();
  }

  Future<void> _fetchTopics() async {
    try {
      final supabase = Supabase.instance.client;
      final topicsResponse = await supabase
          .from('topics')
          .select('topic_name')
          .order('topic_name');
      
      setState(() {
        topicList = List<Map<String, dynamic>>.from(topicsResponse);
        isLoadingTopics = false;
        // If the initial topic is not in the list, use the first available topic
        if (selectedTopic != null && !topicList.any((t) => t['topic_name'] == selectedTopic)) {
          if (topicList.isNotEmpty) {
            selectedTopic = topicList[0]['topic_name'] as String;
          }
        } else if (selectedTopic == null && topicList.isNotEmpty) {
          selectedTopic = topicList[0]['topic_name'] as String;
        }
      });
    } catch (e) {
      setState(() {
        isLoadingTopics = false;
      });
    }
  }
  
  // Check if screen is mobile
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }
  
  // Calculate number of stars based on percentage (score / totalQuestions * 100)
  int _getStarCount(double score, int totalQuestions) {
    if (totalQuestions == 0) return 0;
    final percentage = (score / totalQuestions) * 100;
    if (percentage >= 80) {
      return 3;
    } else if (percentage >= 60) {
      return 2;
    } else if (percentage >= 40) {
      return 1;
    } else {
      return 0;
    }
  }
  
  // Build decorative white clouds and stars dynamically distributed along content height
  List<Widget> _buildDecorativeElements(
    double screenWidth,
    double contentHeight,
    bool isMobile,
    int numItems,
  ) {
    final elements = <Widget>[];
    final centerX = screenWidth / 2;
    final containerHalfWidth = 300; // Half of maxWidth 600
    final leftBoundary = centerX - containerHalfWidth;
    final rightBoundary = centerX + containerHalfWidth;
    
    // Calculate safe zones for decorations (outside the centered container)
    final leftZone = leftBoundary - 100; // Space on the left
    final rightZone = screenWidth - rightBoundary - 100; // Space on the right
    
    // Calculate spacing between decorations
    // Reduced spacing for higher density - decorations every 60-80px vertically
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
    final minDistanceBetween = 40.0; // Reduced for higher density
    
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
                  'assets/images/white_cloud.svg',
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
                  'assets/images/white_star.svg',
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
                  'assets/images/white_cloud.svg',
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
                  'assets/images/white_star.svg',
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
          'assets/images/white_star.svg',
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
          'assets/images/white_cloud.svg',
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
          'assets/images/white_star.svg',
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
            'assets/images/white_star.svg',
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
            'assets/images/white_star.svg',
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
            'assets/images/white_cloud.svg',
            width: isMobile ? 28 : 40,
            height: isMobile ? 19 : 27,
          ),
        ),
      );
    }
    
    return elements;
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard(String topicName) async {
    final supabase = Supabase.instance.client;

    // Step 1: Get topic_id for given topicName
    final topicResponse = await supabase
        .from('topics')
        .select('topic_id')
        .eq('topic_name', topicName)
        .single();

    final topicId = topicResponse['topic_id'];

    // Step 2: Get top 10 test_attempts joined with users, sorted
    final attemptsResponse = await supabase
      .from('test_attempts')
      .select('score, duration_seconds, question_list, profiles(name)')
      .eq('topic_id', topicId)
      .order('score', ascending: false)
      .order('duration_seconds', ascending: true)
      .limit(10);

    return List<Map<String, dynamic>>.from(attemptsResponse);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: MyApp.homeLightPink,
      appBar: AppBar(
        backgroundColor: MyApp.homeLightPink,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyApp.homeDarkGreyText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: selectedTopic == null || isLoadingTopics
          ? Center(
              child: CircularProgressIndicator(
                color: MyApp.homeTealGreen,
              ),
            )
          : FutureBuilder<List<Map<String, dynamic>>>(
              key: ValueKey(selectedTopic), // Rebuild when topic changes
              future: fetchLeaderboard(selectedTopic!),
              builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: MyApp.homeTealGreen,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading leaderboard',
                style: TextStyle(
                  color: MyApp.homeDarkGreyText,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Decorative elements
                      ..._buildDecorativeElements(screenWidth, screenHeight, isMobile, 0),
                      // Main content
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16.0 : 24.0,
                          vertical: isMobile ? 16.0 : 24.0,
                        ),
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isMobile ? double.infinity : 600,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header section with filter on same line
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
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Global Leaderboard',
                                              style: TextStyle(
                                                fontSize: isMobile ? 24 : 32,
                                                fontWeight: FontWeight.bold,
                                                color: MyApp.homeDarkGreyText,
                                                fontFamily: 'serif',
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'futuremind 2.0',
                                              style: TextStyle(
                                                fontSize: isMobile ? 16 : 20,
                                                color: MyApp.homeGreyText,
                                                fontFamily: 'sans-serif',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Topic filter dropdown on the same line
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
                                        decoration: BoxDecoration(
                                          color: MyApp.homeLightPink,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: MyApp.homeDarkGreyText.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: DropdownButton<String>(
                                          value: selectedTopic,
                                          hint: Text(
                                            'Select topic',
                                            style: TextStyle(
                                              fontSize: isMobile ? 12 : 14,
                                              color: MyApp.homeDarkGreyText.withOpacity(0.7),
                                            ),
                                          ),
                                          underline: SizedBox(), // Remove default underline
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: MyApp.homeDarkGreyText,
                                            size: isMobile ? 20 : 24,
                                          ),
                                          style: TextStyle(
                                            fontSize: isMobile ? 12 : 14,
                                            color: MyApp.homeDarkGreyText,
                                          ),
                                          dropdownColor: MyApp.homeLightPink,
                                          items: topicList.map<DropdownMenuItem<String>>((topic) {
                                            return DropdownMenuItem<String>(
                                              value: topic['topic_name'] as String,
                                              child: Text(topic['topic_name'] as String),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                selectedTopic = newValue;
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Empty state message
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // SVG Image
                                      SvgPicture.asset(
                                        'assets/images/grey_results.svg',
                                        height: 100,
                                      ),
                                      SizedBox(height: 20), // Space between the image and the text
                                      // Text message
                                      Text(
                                        'Empty Leaderboard',
                                        style: TextStyle(
                                          fontSize: isMobile ? 20 : 24,
                                          fontWeight: FontWeight.bold,
                                          color: MyApp.homeDarkGreyText,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Take a quiz and be the first student on our leaderboard!',
                                        style: TextStyle(
                                          fontSize: isMobile ? 14 : 16,
                                          fontWeight: FontWeight.w500,
                                          color: MyApp.homeGreyText,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          final leaderboard = snapshot.data!;
          
          // Calculate estimated content height based on number of items
          // Header: ~120px, Each card: ~100px, spacing: ~16px
          final estimatedContentHeight = 120.0 + (leaderboard.length * 116.0);
          final actualContentHeight = estimatedContentHeight > screenHeight 
              ? estimatedContentHeight 
              : screenHeight;
          
          return SingleChildScrollView(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Decorative elements - dynamically distributed
                ..._buildDecorativeElements(screenWidth, actualContentHeight, isMobile, leaderboard.length),
                
                // Main content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 24.0,
                    vertical: isMobile ? 16.0 : 24.0,
                  ),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? double.infinity : 600,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header section with filter on same line
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Global Leaderboard',
                                        style: TextStyle(
                                          fontSize: isMobile ? 24 : 32,
                                          fontWeight: FontWeight.bold,
                                          color: MyApp.homeDarkGreyText,
                                          fontFamily: 'serif',
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'futuremind 2.0',
                                        style: TextStyle(
                                          fontSize: isMobile ? 16 : 20,
                                          color: MyApp.homeGreyText,
                                          fontFamily: 'sans-serif',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Topic filter dropdown on the same line
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12),
                                  decoration: BoxDecoration(
                                    color: MyApp.homeLightPink,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: MyApp.homeDarkGreyText.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedTopic,
                                    hint: Text(
                                      'Select topic',
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        color: MyApp.homeDarkGreyText.withOpacity(0.7),
                                      ),
                                    ),
                                    underline: SizedBox(), // Remove default underline
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: MyApp.homeDarkGreyText,
                                      size: isMobile ? 20 : 24,
                                    ),
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 14,
                                      color: MyApp.homeDarkGreyText,
                                    ),
                                    dropdownColor: MyApp.homeLightPink,
                                    items: topicList.map<DropdownMenuItem<String>>((topic) {
                                      return DropdownMenuItem<String>(
                                        value: topic['topic_name'] as String,
                                        child: Text(topic['topic_name'] as String),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          selectedTopic = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Leaderboard cards
                          ...leaderboard.map((user) {
                            final score = (user['score'] as num?)?.toDouble() ?? 0.0;
                            final questionList = user['question_list'] as List<dynamic>? ?? [];
                            final totalQuestions = questionList.length;
                            final starCount = _getStarCount(score, totalQuestions);
                            final userName = user['profiles']?['name'] ?? 'Unknown';
                            
                            return Container(
                              margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 20 : 24,
                                vertical: isMobile ? 16 : 20,
                              ),
                              decoration: BoxDecoration(
                                color: MyApp.homeWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: MyApp.homeDarkGreyText.withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User name
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: isMobile ? 18 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: MyApp.homeDarkGreyText,
                                      fontFamily: 'serif',
                                    ),
                                  ),
                                  
                                  SizedBox(height: isMobile ? 8 : 12),
                                  
                                  // Points and stars row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Topic name and points
                                      Text(
                                        '$selectedTopic: ${score.toInt()} pts',
                                        style: TextStyle(
                                          fontSize: isMobile ? 14 : 16,
                                          color: MyApp.homeGreyText,
                                          fontFamily: 'sans-serif',
                                        ),
                                      ),
                                      
                                      // Stars
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(starCount, (index) {
                                          return Icon(
                                            Icons.star,
                                            color: MyApp.homeYellow,
                                            size: isMobile ? 20 : 24,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                          
                          SizedBox(height: isMobile ? 20 : 30),
                        ],
                      ),
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
