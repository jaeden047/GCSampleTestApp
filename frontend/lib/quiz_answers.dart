import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:logger/logger.dart';
import 'main.dart';
import 'math_text.dart';

class QuizAnswers extends StatefulWidget {
  final int attemptId;

  const QuizAnswers({
    super.key,
    required this.attemptId,
  });

  @override
  State<QuizAnswers> createState() => _QuizAnswersState();
}

class TestAttempt {
  final String dateTime;
  final List<dynamic> questionList;
  final List<dynamic> answerOrder;
  /// From DB: Map (question_id -> answer_id) or legacy List.
  final dynamic selectedAnswers;
  final double score;
  final int topicId;
  final String round;

  TestAttempt({
    required this.dateTime,
    required this.questionList,
    required this.answerOrder,
    required this.selectedAnswers,
    required this.score,
    required this.topicId,
    this.round = 'local',
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
  final bool resultsReleased;
  final bool isSampleQuiz;

  Topics({
    required this.topicId2,
    required this.topicName,
    required this.resultsReleased,
    required this.isSampleQuiz,
  });

  bool get canShowResults => isSampleQuiz || resultsReleased;
}

class _QuizAnswersState extends State<QuizAnswers> {
  final supabase = Supabase.instance.client;
  static const _mathRoundTopicNames = ['Grade 5 and 6', 'Grade 7 and 8', 'Grade 9 and 10', 'Grade 11 and 12'];
  static String _roundLabel(String? round) => round == 'sample' ? 'Sample Quiz' : round == 'final' ? 'Final Round' : 'Local Round';

  bool _isMathRoundTopic(String? topicName) => topicName != null && _mathRoundTopicNames.contains(topicName);
  /// For math grade topics: sample round always visible; local/final only when topic.resultsReleased.
  bool _canShowResultsForPage(Topics t, TestAttempt? attempt) {
    if (_isMathRoundTopic(t.topicName)) {
      if (attempt == null) return t.resultsReleased;
      if (attempt.round == 'sample') return true;
      if (attempt.round == 'local' || attempt.round == 'final') return t.resultsReleased;
      return t.resultsReleased;
    }
    return t.canShowResults;
  }

  List<int> _getAnsweredQuestionIdsInOrder(TestAttempt a) {
    if (a.selectedAnswers is Map) {
      final m = a.selectedAnswers as Map;
      return [
        for (var qid in a.questionList)
          if (m.containsKey(qid.toString()))
            (qid is int ? qid : int.tryParse(qid.toString()) ?? 0)
      ];
    }
    return List<int>.from(a.questionList);
  }

  bool _isAnswerSelected(TestAttempt a, int questionId, int answerId) {
    if (a.selectedAnswers is Map) return (a.selectedAnswers as Map)[questionId.toString()] == answerId;
    if (a.selectedAnswers is List) return (a.selectedAnswers as List).contains(answerId);
    return false;
  }

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  TestAttempt? testAttempt;
  List<Answers> answerList = [];
  List<Questions> questionList = [];
  Topics? topic;
  bool isLoading = true;

  // Check if screen is mobile
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  @override
  void initState() {
    super.initState();
    fetchQuizData();
  }

  Future<void> fetchQuizData() async {
    try {
      // Fetch the test attempt
      final testRawData = await supabase
          .from('test_attempts')
          .select()
          .eq('attempt_id', widget.attemptId)
          .single();

      // Fetch all answers, questions, and topics
      final questionAnswers = await supabase.from('answers').select();
      final questionData = await supabase.from('questions').select();
      final topicData = await supabase.from('topics').select('topic_id, topic_name, results_released, is_sample_quiz');

      setState(() {
        testAttempt = TestAttempt(
          dateTime: testRawData['test_datetime']?.toString() ?? 'No Date',
          questionList: List<dynamic>.from(testRawData['question_list'] ?? []),
          answerOrder: List<dynamic>.from(testRawData['answer_order'] ?? []),
          selectedAnswers: testRawData['selected_answers'],
          score: testRawData['score'] ?? 0,
          topicId: testRawData['topic_id'] ?? 0,
          round: (testRawData['round'] as String?) ?? 'local',
        );

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

        final topicRow = topicData.firstWhere(
          (t) => t['topic_id'] == testAttempt!.topicId,
          orElse: () => {'topic_id': 0, 'topic_name': 'Unknown', 'results_released': false, 'is_sample_quiz': false},
        );
        topic = Topics(
          topicId2: topicRow['topic_id'],
          topicName: topicRow['topic_name'],
          resultsReleased: topicRow['results_released'] == true,
          isSampleQuiz: topicRow['is_sample_quiz'] == true,
        );

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quiz data: $e')),
        );
      }
    }
  }

  // Format date in Toronto timezone
  String _formatDateToronto(String dateTimeString) {
    try {
      _logger.d('=== Timezone Conversion Debug ===');
      _logger.d('Original timestamp string from Supabase: $dateTimeString');
      
      // Parse the datetime string - handle ISO format (e.g., "2026-01-22T17:24:03.99345")
      DateTime parsedDateTime;
      
      // Remove microseconds if present for easier parsing, but preserve timezone
      String cleanDateTime = dateTimeString.trim();
      
      // Check if it has timezone info FIRST (before removing microseconds)
      // Look for patterns like: "2026-01-22T17:40:00+00:00" or "2026-01-22T17:40:00Z"
      bool hasTimezone = cleanDateTime.endsWith('Z') || 
                         RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(cleanDateTime);
      
      // Extract timezone part if present (e.g., "+00:00" or "-05:00")
      String? timezonePart;
      if (hasTimezone && !cleanDateTime.endsWith('Z')) {
        final timezoneMatch = RegExp(r'([+-]\d{2}:\d{2})$').firstMatch(cleanDateTime);
        if (timezoneMatch != null) {
          timezonePart = timezoneMatch.group(1);
        }
      }
      
      // Handle different formats from Supabase
      // Supabase typically returns timestamps in ISO 8601 format
      // Remove microseconds but preserve timezone
      if (cleanDateTime.contains('.')) {
        // Split on '.' but keep timezone if present
        final parts = cleanDateTime.split('.');
        cleanDateTime = parts[0];
        // Re-add timezone if it was present
        if (timezonePart != null) {
          cleanDateTime += timezonePart;
        } else if (hasTimezone && cleanDateTime.endsWith('Z')) {
          // Z is already at the end, keep it
        }
      }
      
      _logger.d('Has timezone info: $hasTimezone');
      _logger.d('Cleaned datetime string: $cleanDateTime');
      
      if (!hasTimezone) {
        // No timezone indicator - add 'Z' to indicate UTC
        cleanDateTime += 'Z';
        _logger.d('Added Z suffix, new string: $cleanDateTime');
      }
      
      // Parse the datetime - DateTime.parse handles timezone if present
      parsedDateTime = DateTime.parse(cleanDateTime);
      _logger.d('Parsed DateTime (before UTC conversion): ${parsedDateTime.toString()}');
      
      // Always convert to UTC for consistent handling
      // If it had timezone info, toUtc() converts it
      // If it didn't, we already added 'Z' so it's treated as UTC
      parsedDateTime = parsedDateTime.toUtc();
      _logger.d('UTC DateTime: ${parsedDateTime.year}-${parsedDateTime.month.toString().padLeft(2, '0')}-${parsedDateTime.day.toString().padLeft(2, '0')} ${parsedDateTime.hour.toString().padLeft(2, '0')}:${parsedDateTime.minute.toString().padLeft(2, '0')}:${parsedDateTime.second.toString().padLeft(2, '0')}');
      
      // Convert to Toronto timezone using timezone package
      final torontoLocation = tz.getLocation('America/Toronto');
      
      // Create TZDateTime in UTC from the parsed DateTime
      final utcTZ = tz.TZDateTime.utc(
        parsedDateTime.year,
        parsedDateTime.month,
        parsedDateTime.day,
        parsedDateTime.hour,
        parsedDateTime.minute,
        parsedDateTime.second,
      );
      
      // Get timezone information for Toronto at this UTC time
      final timeZoneInfo = torontoLocation.timeZone(utcTZ.millisecondsSinceEpoch);
      
      // The timezone package's offset represents the offset FROM UTC TO local time
      // For EST (UTC-5): offset should be negative (behind UTC)
      // For EDT (UTC-4): offset should be negative (behind UTC)
      final offsetMs = timeZoneInfo.offset;
      final offsetHours = offsetMs / 3600000;
      
      _logger.d('UTC TZDateTime: ${utcTZ.year}-${utcTZ.month.toString().padLeft(2, '0')}-${utcTZ.day.toString().padLeft(2, '0')} ${utcTZ.hour.toString().padLeft(2, '0')}:${utcTZ.minute.toString().padLeft(2, '0')}:${utcTZ.second.toString().padLeft(2, '0')}');
      _logger.d('Toronto timezone offset: $offsetMs ms ($offsetHours hours)');
      _logger.d('Is DST: ${timeZoneInfo.isDst}');
      
      // Convert UTC to Toronto time using the timezone package's proper method
      // Create a TZDateTime in Toronto timezone directly from the UTC TZDateTime
      // This is the correct way to convert between timezones
      final torontoTZ = tz.TZDateTime.fromMillisecondsSinceEpoch(
        torontoLocation,
        utcTZ.millisecondsSinceEpoch,
      );
      
      _logger.d('Toronto TZDateTime: ${torontoTZ.year}-${torontoTZ.month.toString().padLeft(2, '0')}-${torontoTZ.day.toString().padLeft(2, '0')} ${torontoTZ.hour.toString().padLeft(2, '0')}:${torontoTZ.minute.toString().padLeft(2, '0')}:${torontoTZ.second.toString().padLeft(2, '0')}');
      
      // Create a regular DateTime from the TZDateTime for formatting
      // Use the year, month, day, hour, minute, second from the Toronto TZDateTime
      final torontoDateTime = DateTime(
        torontoTZ.year,
        torontoTZ.month,
        torontoTZ.day,
        torontoTZ.hour,
        torontoTZ.minute,
        torontoTZ.second,
      );
      
      _logger.d('Toronto DateTime: ${torontoDateTime.year}-${torontoDateTime.month.toString().padLeft(2, '0')}-${torontoDateTime.day.toString().padLeft(2, '0')} ${torontoDateTime.hour.toString().padLeft(2, '0')}:${torontoDateTime.minute.toString().padLeft(2, '0')}:${torontoDateTime.second.toString().padLeft(2, '0')}');
      
      // Format as MM/dd/yyyy h:mm a with space between date and time (e.g., "01/22/2026 12:24 PM")
      final formattedDate = DateFormat('MM/dd/yyyy h:mm a').format(torontoDateTime);
      _logger.d('Formatted date string: $formattedDate');
      _logger.d('=== End Timezone Conversion Debug ===');
      
      return formattedDate;
    } catch (e) {
      // If parsing fails, try to format the original string as-is
      try {
        final fallbackDateTime = DateTime.parse(dateTimeString);
        return DateFormat('MM/dd/yyyy h:mma').format(fallbackDateTime);
      } catch (_) {
        // Last resort: return a formatted version of the original string
        return dateTimeString;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) {
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
        body: Center(
          child: CircularProgressIndicator(
            color: MyApp.homeTealGreen,
          ),
        ),
      );
    }

    if (topic != null && !_canShowResultsForPage(topic!, testAttempt)) {
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
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 48, color: MyApp.homeDarkGreyText),
                SizedBox(height: 16),
                Text(
                  'Results will be available when your admin releases them.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    color: MyApp.homeDarkGreyText,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (testAttempt == null) {
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
        body: Center(
          child: Text(
            'Quiz data not found',
            style: TextStyle(
              color: MyApp.homeDarkGreyText,
              fontSize: isMobile ? 16 : 18,
            ),
          ),
        ),
      );
    }

    final answeredIds = _getAnsweredQuestionIdsInOrder(testAttempt!);
    final estimatedContentHeight = 200.0 + (answeredIds.length * 140.0);
    final actualContentHeight = estimatedContentHeight > screenHeight 
        ? estimatedContentHeight 
        : screenHeight;

    String formattedDate = _formatDateToronto(testAttempt!.dateTime);
    double scoreNumber = testAttempt!.score;

    return Scaffold(
      backgroundColor: MyApp.homeTealGreen,
      appBar: AppBar(
        backgroundColor: MyApp.homeTealGreen,
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
                // Decorative elements - dynamically distributed
                ..._buildDecorativeElements(screenWidth, actualContentHeight, isMobile, answeredIds.length),
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
                          // Header card
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${topic?.topicName ?? 'Quiz'}${_isMathRoundTopic(topic?.topicName) ? ' • ${_roundLabel(testAttempt!.round)}' : ''} Answers',
                                  style: TextStyle(
                                    fontSize: isMobile ? 24 : 32,
                                    fontWeight: FontWeight.bold,
                                    color: MyApp.homeDarkGreyText,
                                    fontFamily: 'serif',
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, color: MyApp.homeDarkGreyText, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: MyApp.homeDarkGreyText.withOpacity(0.9),
                                      ),
                                    ),
                                    Spacer(),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star, color: MyApp.homeYellow, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Score: ${scoreNumber.toInt()} pts',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: MyApp.homeDarkGreyText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Questions and answers (only those the student answered, e.g. 15/37)
                          ...List.generate(
                            answeredIds.length,
                            (i) {
                              int questionID = answeredIds[i];
                              int origIndex = testAttempt!.questionList.indexOf(questionID);
                              if (origIndex < 0) return SizedBox.shrink();
                              int start = origIndex * 4;
                              int end = start + 4;
                              if (end > testAttempt!.answerOrder.length) return SizedBox.shrink();
                              List<int> correctAnswerOrder = testAttempt!.answerOrder.sublist(start, end).cast<int>();
                              List<Answers> answerOptions = [];
                              for (final id in correctAnswerOrder) {
                                final match = answerList.where((a) => a.answerID == id).toList();
                                if (match.isNotEmpty) answerOptions.add(match.first);
                              }
                              final questionMatch = questionList.where((q) => q.questionID == questionID).toList();
                              final questionText = questionMatch.isEmpty ? 'Question (unavailable)' : questionMatch.first.questionText;
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: MyApp.homeWhite.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: MyApp.homeTealGreen.withOpacity(0.3),
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
                                    MathText(
                                      '${i + 1}. $questionText',
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: MyApp.homeDarkGreyText,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    ...answerOptions.map((row) {
                                      bool isSelected = _isAnswerSelected(testAttempt!, questionID, row.answerID);
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
                                            child: MathText(
                                              row.answerText,
                                              textStyle: TextStyle(color: colorChosen),
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
