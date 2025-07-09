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

class _ResultsState extends State<Results> { // 
  final supabase = Supabase.instance.client; // Supabase Object connected to Client
  int numRows = 0; 
  List<TestAttempt> testList = []; // List of Test Attempt Data

  @override // Overriding the initState function
  void initState() { // Function called before screen loads
    super.initState();
    fetchTestAttempts(); // Now, fetchTestAttempts will be apart of the function
  }
  Future<void> fetchTestAttempts() async {
    final testRawData = await supabase.from('testAttempts').select().eq('user_id', supabase.auth.currentUser!.id); 
    // Retrieve Raw Data Rows ONLY from currently signed in user_id from testRawData
    setState(() { // Rebuild UI
      numRows = testRawData.length;
      testList = testRawData.map<TestAttempt>((row) { // Each 'row' is now a separate function.
      // Map each row in testRows to a TestAttempt Object. 
      // Collect all TestAttempt Objects and save it in List<TestAttempt>: testList
        return TestAttempt( 
          dateTime: row['test_datetime']?.toString() ?? 'No Date',
          questionList: List.from(row['question_list'] ?? []), // Make a List from row or leave empty
          answerOrder: List.from(row['answer_order'] ?? []),
          selectedAnswers: List.from(row['selected_answers'] ?? []),
          score: row['score'] ?? 0,
        );
        // ?.toString => Is not null: Keep value, Is null: "null"
        // ?? 'No Date' => left side: "null" => switch to 'No Date' text, else, keep. 
      }).toList(); // Converts to List<TestAttempt>.
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
                      Text('Attempt ${index + 1}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Date: ${testList[index].dateTime}', style: TextStyle(fontSize: 18)),
                      Text('Score: ${testList[index].score}', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      // .join(', ') combines the text items in the string without brackets.
                      Text('Selected Answers: ${testList[index].selectedAnswers.join(', ')}', style: TextStyle(fontSize: 16)),
                      Text('Question List: ${testList[index].questionList.join(', ')}', style: TextStyle(fontSize: 16)),
                      Text('Answer Order: ${testList[index].answerOrder.join(', ')}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
        );}
      ),
    );
  }
  
}