import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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
    });
  }
@override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Past Results'),
        ),
      body: numRows == 0
        ?  Center( // empty results look
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertically center the content
          crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center the content
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Try a quiz before coming back',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )
        : ListView.builder(
            itemCount: numRows,
            itemBuilder: (context, index) {
              DateTime parsedDate = DateTime.parse(testList[index].dateTime); // parses raw ISO Date into a DateTime Variable
              String formattedDate = DateFormat('MM/dd/yyyy h:mma').format(parsedDate);
              double scoreNumber = testList[index].score; 
              return Card(
                color: Colors.green[50], // Color of the Attempt {} Card
                shadowColor: Colors.black, // Attempt {} - Shadow Underlayer
                shape: RoundedRectangleBorder( // Shape of the Attempt {} Card
                  borderRadius: BorderRadius.all(Radius.circular(12)), // Attempt {} - Rounded Corners (20 px)
                ),
                margin: EdgeInsets.all(16), // Attempt {} is 16 px from other Attempt {} cards or edge of screen.
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Space between tile and detail
                  title: Column( // Title of Expansion Block
                    crossAxisAlignment: CrossAxisAlignment.start, // Place text at far left
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Attempt ${index + 1} • ${topicList.firstWhere((t) => t.topicId2 == testList[index].topicId, orElse: () => Topics(topicId2: 0, topicName: 'Unknown')).topicName}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      SizedBox(height: 6),
                      Row( // Row displays two widgets side by side; must be declared in children block.
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 6), // controls width spacing between any widget
                          Text(formattedDate, style: TextStyle(fontSize: 14, color: const Color.fromARGB(137, 36, 36, 36),)),
                          Spacer(), // takes all available space ~ pushes score widget on the far right
                          SizedBox( // Fixed width
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber),
                                SizedBox(width: 6), // controls width spacing between any widget
                                Text(
                                  'Score: ${scoreNumber.toStringAsFixed(1)}%',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)
                                )
                             ],
                            ),
                          ) 
                        ]
                      ),
                    ]
                  ),
                  children: [ // When you click on tile, this is what is displayed
                    Padding( 
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // 16 pixels left/right in space, 8 pixes up/down in space
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center, // align to left
                        children: [
                          SizedBox(height: 8),
                          ...List.generate(
                            testList[index].questionList.length, 
                            (i) {
                              int questionID = testList[index].questionList[i]; 
                              //List<Answers> answerOptions = answerList.where((a) => a.questionID == questionID).toList();
                              int start = i * 4; // Start index: i = 0 : 0 * 4 = 0, 1 * 4 = 4
                              int end = start + 4; // End index: 8
                              // 0 - 4 : Question 1, 4 - 8 : Question 2,
                              List<int> correctAnswerOrder = testList[index].answerOrder.sublist(start, end).cast<int>();
                              // We loop through each question, i = question number.
                              // i = 1, loop through answer-order 4-8. This is the list of answer IDs for Question 1 (i), in the correct order.
                              List<Answers> answerOptions = correctAnswerOrder.map((id) => answerList.firstWhere((a) => a.answerID == id)).toList();
                              // id = the id of each question in the correctAnswerOrder list. a.answerID (answerID of answer Object) mapped to id (answerID in List<int> - correctAnswerOrder)
                              // 28 (correctAnswerOrder) -> find the corresponding answer object -> "Answer B" - QID: 28 -> add to list
                              return Container(
                                //width: 360,
                                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // space outside card
                                padding: EdgeInsets.all(12), // space inside card
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Color(0xFFE0E0E0),
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
                                      Text( // questionList i = answer questionID -> answerText, allAnswers[i] = correct/wrong
                                      '${i + 1}. ${(questionList.firstWhere((q) => q.questionID == questionID).questionText)}', 
                                      //'${answerOptions.map((a) => '- ${a.answerText}').join('\n')}',
                                      // .map turns each answerOptions object into a String
                                      // .join puts each on it's own line
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4), // Gap between questiontext and answertext  
                                    ...answerOptions.map((row) {
                                      bool isSelected = testList[index].selectedAnswers.contains(row.answerID); 
                                      // Is answer a selected answer ; T/F
                                      bool isCorrect = row.isCorrect;
                                      // Is answer a correct answer ; T/F
                                      Icon iconChosen = Icon(Icons.check_circle_outline);
                                      Color colorChosen = Colors.black;
                                      if (isSelected && isCorrect) { // if Selected and Right
                                        iconChosen = Icon(Icons.circle, color: Color(0xFF628B35));
                                        colorChosen = Color(0xFF628B35);
                                      } else if (isSelected && !isCorrect) { // if Selected but Wrong
                                        iconChosen = Icon(Icons.circle, color: Color(0xFFBD433E));
                                        colorChosen = Color(0xFFBD433E);
                                      } else if (!isSelected && isCorrect) { // if Not Selected but Right
                                        iconChosen = Icon(Icons.circle_outlined, color: Color(0xFF628B35));
                                        colorChosen = Color(0xFF628B35);
                                      } else if (!isSelected && !isCorrect) { // If Not Selected but Wrong
                                        iconChosen = Icon(Icons.circle_outlined); 
                                        colorChosen = Colors.black;
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
                                    }) // elipses (...) is a spread operator used to insert a list of widgets into another list of widgets, i.e. Column
                                  ]
                                )
                              );
                            }
                          ),
                        ],
                      ),
                      )
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}