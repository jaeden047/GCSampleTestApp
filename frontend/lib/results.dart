import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

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
  final int score;

  TestAttempt({ // Model for Constructor for the class: To create an object - this is what you require
    required this.dateTime,
    required this.questionList,
    required this.answerOrder,
    required this.selectedAnswers,
    required this.score,
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

class _ResultsState extends State<Results> { // 
  final supabase = Supabase.instance.client; // Supabase Object connected to Client
  int numRows = 0; 
  List<TestAttempt> testList = []; // List of Test Attempt Data
  List<Answers> answerList = []; // List of Test Attempt Data

  @override // Overriding the initState function
  void initState() { // Function called before screen loads
    super.initState();
    fetchTestAttempts(); // Now, fetchTestAttempts will be apart of the function
  }
  Future<void> fetchTestAttempts() async {
    final testRawData = await supabase.from('test_attempts').select().eq('user_id', supabase.auth.currentUser!.id); 
    // Retrieve Raw Data Rows ONLY from currently signed in user_id from testRawData
    final questionAnswers = await supabase.from('answers').select(); 
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
      // numRows = number of user's testattempts
    });
  }
  @override
  Widget build(BuildContext context) { // Always runs first
    return Scaffold(
      body: numRows == 0 ? const Center(child: Text('No attempts yet...')) // For Scaffold only - 
      //if 0 rows = "No attempts" - if >0 rows, follow build
      : ListView.builder( 
        // itemCount and itemBuilder are directly related. Number of itemCount = affects index of itemBuilder
          itemCount: numRows,
          itemBuilder: (context, index){
          List<int> correctAnswers = [];
          List<bool> allAnswers = List.filled(testList[index].questionList.length, false);
          for (int i = 0; i < testList[index].selectedAnswers.length; i++){ 
            // For each selected answer in our testAttempt selectedAnswers for the current attempt
            int answerSelected = testList[index].selectedAnswers[i]; 
            for (final answer in answerList){ // for each answer block in answerList
              if (answer.answerID == answerSelected){ // if the answerID = the selected Answer from our TestAtmpt
                if (answer.isCorrect == true){ // check if it's true
                  correctAnswers.add(answer.questionID);
                }
              }
            }
          }
          for (int j = 0; j < testList[index].questionList.length; j++){
            int questionSelected = testList[index].questionList[j];
            for (final correctAnswer in correctAnswers){
              if (correctAnswer == questionSelected){ 
                // when Question ID matches a Correct Answer - we flag it. 
                // That questionSelected is now "true".
                allAnswers[j] = true;
              } 
              // question on questionList is now mapped to true/false
            }
          }
            return Container( // Every itembuilder needs to return a widget - container is that widget
              width: double.infinity,
              height: 300,
              child: Card(
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.all(32),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Left-aligns the text
                    children: [
                      Text(
                        'Attempt ${index + 1}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Date: ${testList[index].dateTime}',
                        style: TextStyle(fontSize: 18),
                      ),
                        Text(
                          'Score: ${testList[index].score}',
                          style: TextStyle(fontSize: 18),
                        ),
                      SizedBox(height: 10),
                      ...List.generate(
                        testList[index].questionList.length,
                        (i) => Text( // For each question list item generate a text box
                          'Question ${i + 1}: ${allAnswers[i] ? 'Correct' : 'Incorrect'}',
                          style: TextStyle(
                            fontSize: 16,
                            color: allAnswers[i] ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        );}
      ),
    );
  } 
}

/*
ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Home()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                ),
                */