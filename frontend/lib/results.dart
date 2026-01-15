import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'main.dart';

// Results page
class Results extends StatefulWidget { // Results is a type of widget (Class) 
// StatefulWidget => Changeable Widget during Runtime. StatelessWidget => Static Widget. extends Stateful => copy fields to Results
  const Results({super.key}); // Results() is constructor for class
  // Constructor; applies super.key to a class key field. Key field
  @override
  State<Results> createState() => _ResultsState(); //
}

class TestAttempt { // Here we create a custom type (i.e. String is a type)
  // Data fields, 'dynamic' => can hold any type of value
  final String dateTime;
  final List<dynamic> questionList;
  final List<dynamic> answerOrder;
  final List<dynamic> selectedAnswers;
  final double score;
  final int topicId;

  TestAttempt({ // Model for Constructor for the class: To create an object - this is what you require
    required this.dateTime,
    required this.questionList,
    required this.answerOrder,
    required this.selectedAnswers,
    required this.score,
    required this.topicId,
  });
}

class Answers {
  final int answerID;
  final int questionID;
  final String answerText;
  final bool isCorrect;

  Answers({
    required this.answerID,
    required this.questionID,
    required this.answerText,
    required this.isCorrect,
  });
}

class Questions {
  final int questionID;
  final int topicID;
  final String questionText;

  Questions({
    required this.questionID,
    required this.topicID,
    required this.questionText,
  });
}

class Topics {
  final int topicId2;
  final String topicName;

  Topics({
    required this.topicId2,
    required this.topicName,
  });
}

class _ResultsState extends State<Results> { // 
  final supabase = Supabase.instance.client; // Supabase Object connected to Client
  int numRows = 0; 
  List<TestAttempt> testList = []; // List of Test Attempt Data
  List<Answers> answerList = []; // List of Test Attempt Data
  List<Questions> questionList = []; // List of Test Attempt Data
  List<Topics> topicList = [];
  String? selectedFilter; // Selected filter option

  // Check if screen is mobile
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  @override // Overriding the initState function
  void initState() { // Function called before screen loads
    super.initState();
    fetchTestAttempts(); // Now, fetchTestAttempts will be apart of the function
  }
  Future<void> fetchTestAttempts() async {
    final testRawData = await supabase.from('test_attempts').select().eq('user_id', supabase.auth.currentUser!.id); 
    // Retrieve Raw Data Rows ONLY from currently signed in user_id from testRawData
    final questionAnswers = await supabase.from('answers').select(); 
    final questionData = await supabase.from('questions').select();
    final topicData = await supabase.from('topics').select();
    // questionAnswers pulls all rows from the answers table 
    setState(() { // Rebuild UI
      numRows = testRawData.length;
      testList = testRawData.map<TestAttempt>((row) { // Each 'row' is now a separate function.
      // Map each row in testRows to a TestAttempt Object. 
      // Collect all TestAttempt Objects and save it in List<TestAttempt>: testList
        return TestAttempt( 
          dateTime: row['test_datetime']?.toString() ?? 'No Date',
          questionList: List<dynamic>.from(row['question_list'] ?? []), // Make a List from row or leave empty
          answerOrder: List<dynamic>.from(row['answer_order'] ?? []),
          selectedAnswers: List<dynamic>.from(row['selected_answers'] ?? []),
          score: row['score'] ?? 0,
          topicId: row['topic_id'] ?? 0,
        );
        // ?.toString => Is not null: Keep value, Is null: "null"
        // ?? 'No Date' => left side: "null" => switch to 'No Date' text, else, keep. 
      }).toList(); // Converts to List<TestAttempt>.

      answerList = questionAnswers.map<Answers>((row) {
        return Answers(
          answerID: row['answer_id'],
          questionID: row['question_id'],
          answerText: row['answer_text'],
          isCorrect: row['is_correct'],
        );
      }).toList();

      questionList = questionData.map<Questions>((row) {
        return Questions(
          questionID: row['question_id'],
          topicID: row['topic_id'],
          questionText: row['question_text'],
        );
      }).toList();
      // numRows = number of user's testattempts

      topicList = topicData.map<Topics>((row) {
        return Topics(
          topicId2: row['topic_id'],
          topicName: row['topic_name'],
        );
      }).toList();
      
      // Apply default sorting (newest to oldest) after fetching
      testList.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.dateTime);
          final dateB = DateTime.parse(b.dateTime);
          return dateB.compareTo(dateA); // Descending (newest first)
        } catch (e) {
          return 0;
        }
      });
      selectedFilter = 'newest'; // Set default filter
    });
  }
  
  // Sort test list based on selected filter
  void _sortTestList(String? filter) {
    if (filter == null) {
      setState(() {
        selectedFilter = filter;
      });
      return;
    }
    
    setState(() {
      selectedFilter = filter;
      final sortedList = List<TestAttempt>.from(testList);
      
      switch (filter) {
        case 'newest':
          sortedList.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.dateTime);
              final dateB = DateTime.parse(b.dateTime);
              return dateB.compareTo(dateA); // Descending (newest first)
            } catch (e) {
              return 0;
            }
          });
          break;
        case 'oldest':
          sortedList.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.dateTime);
              final dateB = DateTime.parse(b.dateTime);
              return dateA.compareTo(dateB); // Ascending (oldest first)
            } catch (e) {
              return 0;
            }
          });
          break;
        case 'highest':
          sortedList.sort((a, b) => b.score.compareTo(a.score)); // Descending (highest first)
          break;
        case 'lowest':
          sortedList.sort((a, b) => a.score.compareTo(b.score)); // Ascending (lowest first)
          break;
      }
      
      testList = sortedList;
    });
  }
  
  // Convert UTC DateTime to EST
  DateTime _convertToEST(DateTime utcDateTime) {
    // EST is UTC-5, EDT is UTC-4
    // For simplicity, we'll use EST (UTC-5) year-round
    return utcDateTime.subtract(Duration(hours: 5));
  }
  
  // Format date in EST
  String _formatDateEST(String dateTimeString) {
    try {
      // Parse the datetime string - if it has timezone info, it will be parsed correctly
      // If not, assume it's UTC (common for database timestamps)
      DateTime utcDateTime;
      if (dateTimeString.endsWith('Z') || dateTimeString.contains('+') || dateTimeString.contains('-', 10)) {
        // Has timezone info, parse as-is
        utcDateTime = DateTime.parse(dateTimeString).toUtc();
      } else {
        // No timezone info, assume UTC
        utcDateTime = DateTime.parse(dateTimeString).toUtc();
      }
      final estDateTime = _convertToEST(utcDateTime);
      return DateFormat('MM/dd/yyyy h:mma').format(estDateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
      body: numRows == 0
        ? LayoutBuilder(
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
                              'Empty History',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: MyApp.homeDarkGreyText,
                              ),
                            ),
                            Text(
                              'Try a quiz before coming back',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: MyApp.homeGreyText,
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
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              // Calculate estimated content height based on number of items
              // Title header: ~80px, Each card: ~120px (collapsed), spacing: ~20px
              final estimatedContentHeight = 100.0 + (numRows * 140.0);
              final actualContentHeight = estimatedContentHeight > screenHeight 
                  ? estimatedContentHeight 
                  : screenHeight;
              
              return SingleChildScrollView(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Decorative elements - dynamically distributed
                    ..._buildDecorativeElements(screenWidth, actualContentHeight, isMobile, numRows),
                    // Main content
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16.0 : 24.0,
                        vertical: isMobile ? 16.0 : 24.0,
                      ),
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: isMobile ? double.infinity : 800,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title header with filter dropdown
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
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Past Results',
                                        style: TextStyle(
                                          fontSize: isMobile ? 24 : 32,
                                          fontWeight: FontWeight.bold,
                                          color: MyApp.homeDarkGreyText,
                                          fontFamily: 'serif',
                                        ),
                                      ),
                                    ),
                                    // Filter dropdown
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
                                        value: selectedFilter,
                                        hint: Text(
                                          'Filter by',
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
                                        items: [
                                          DropdownMenuItem<String>(
                                            value: 'newest',
                                            child: Text('Newest to oldest'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'oldest',
                                            child: Text('Oldest to newest'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'highest',
                                            child: Text('Highest scores'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'lowest',
                                            child: Text('Lowest scores'),
                                          ),
                                        ],
                                        onChanged: (String? newValue) {
                                          _sortTestList(newValue);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Results list
                              ...List.generate(
                                numRows,
                                (index) {
                                  String formattedDate = _formatDateEST(testList[index].dateTime);
                                  double scoreNumber = testList[index].score; 
                                  return Container(
                                    margin: EdgeInsets.only(bottom: isMobile ? 16 : 20),
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
                                    child: ExpansionTile(
                                      tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      backgroundColor: MyApp.homeTealGreen,
                                      collapsedBackgroundColor: MyApp.homeTealGreen,
                                      iconColor: MyApp.homeWhite,
                                      collapsedIconColor: MyApp.homeWhite,
                                      title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Attempt ${index + 1} • ${topicList.firstWhere((t) => t.topicId2 == testList[index].topicId, orElse: () => Topics(topicId2: 0, topicName: 'Unknown')).topicName}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: MyApp.homeWhite,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today, color: MyApp.homeWhite, size: 16),
                                              SizedBox(width: 6),
                                              Text(
                                                formattedDate,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: MyApp.homeWhite.withOpacity(0.9),
                                                ),
                                              ),
                                              Spacer(),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.star, color: MyApp.homeYellow, size: 18),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    'Score: ${scoreNumber.toStringAsFixed(1)}%',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      color: MyApp.homeWhite,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      children: [
                                        Padding( 
                                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 8),
                                              ...List.generate(
                                                testList[index].questionList.length, 
                                                (i) {
                                                  int questionID = testList[index].questionList[i]; 
                                                  int start = i * 4;
                                                  int end = start + 4;
                                                  List<int> correctAnswerOrder = testList[index].answerOrder.sublist(start, end).cast<int>();
                                                  List<Answers> answerOptions = correctAnswerOrder.map((id) => answerList.firstWhere((a) => a.answerID == id)).toList();
                                                  return Container(
                                                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    padding: EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: MyApp.homeWhite.withOpacity(0.9),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: MyApp.homeWhite.withOpacity(0.3),
                                                        width: 1,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black12,
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),  
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          '${i + 1}. ${(questionList.firstWhere((q) => q.questionID == questionID).questionText)}',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                            color: MyApp.homeDarkGreyText,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        ...answerOptions.map((row) {
                                                          bool isSelected = testList[index].selectedAnswers.contains(row.answerID); 
                                                          bool isCorrect = row.isCorrect;
                                                          Icon iconChosen = Icon(Icons.check_circle_outline);
                                                          Color colorChosen = MyApp.homeDarkGreyText;
                                                          if (isSelected && isCorrect) {
                                                            iconChosen = Icon(Icons.circle, color: Color(0xFF628B35));
                                                            colorChosen = Color(0xFF628B35);
                                                          } else if (isSelected && !isCorrect) {
                                                            iconChosen = Icon(Icons.circle, color: Color(0xFFBD433E));
                                                            colorChosen = Color(0xFFBD433E);
                                                          } else if (!isSelected && isCorrect) {
                                                            iconChosen = Icon(Icons.circle_outlined, color: Color(0xFF628B35));
                                                            colorChosen = Color(0xFF628B35);
                                                          } else if (!isSelected && !isCorrect) {
                                                            iconChosen = Icon(Icons.circle_outlined, color: MyApp.homeDarkGreyText); 
                                                            colorChosen = MyApp.homeDarkGreyText;
                                                          }
                                                          return Row(
                                                            children: [
                                                              iconChosen,
                                                              SizedBox(width: 6),
                                                              Flexible(
                                                                child: Text(
                                                                  row.answerText,
                                                                  style: TextStyle(color: colorChosen),
                                                                  softWrap: true,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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