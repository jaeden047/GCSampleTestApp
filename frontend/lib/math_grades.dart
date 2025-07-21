import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; //supabase flutter sdk
import 'quiz.dart';

class MathGrades extends StatelessWidget {
  const MathGrades({super.key});

  // Start a new quiz: create an attempt and fetch questions
  Future<void> _startQuiz(BuildContext context, String topicName) async {
    final supabase = Supabase.instance.client;
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
    List<String> oneTryTopics = ['Grade 5 and 6', 'Grade 7 and 8', 'Grade 9 and 10', 'Grade 11 and 12'];

    // Check if the user has already attempted the specific quizzes
    if (oneTryTopics.contains(topicName)) {
      try{
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
        // print('Got 10 question IDs: $questionIds');

        // 2. Create the quiz and generate an ID
        final quizAttempt = await supabase.rpc('create_new_quiz', params: {
          'p_user_id': user.id,
          'p_question_list': questionIds,
          'p_topic_id': topicId
        });
        // print('attempt_id is $quizAttempt');

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
            );
          } else{
            // print('Failed to retrieve questions');
          }
        } else {
          // print('Failed to create quiz: $quizAttempt');
        }
      } else {
        // print('Unexpected response: $questions');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting quiz: $e')),
      );
    }
}


  @override
  Widget build(BuildContext context) {
    final topics = [
      {'title': 'Sample Quiz', 'description': 'The sample quiz consists of 10 questions and must be completed within 30 minutes. Students have unlimited attempts to practice.'},
      {'title': 'Grade 5 and 6', 'description': 'The quiz consists of 15 questions and must be completed within 30 minutes. Each student is allowed only ONE attempt.'},
      {'title': 'Grade 7 and 8', 'description': 'The quiz consists of 15 questions and must be completed within 30 minutes. Each student is allowed only ONE attempt.'},
      {'title': 'Grade 9 and 10', 'description': 'The quiz consists of 15 questions and must be completed within 30 minutes. Each student is allowed only ONE attempt.'},
      {'title': 'Grade 11 and 12', 'description': 'The quiz consists of 15 questions and must be completed within 30 minutes. Each student is allowed only ONE attempt.'}
    ];

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(  // Make the content scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,  // Align items at the top
            crossAxisAlignment: CrossAxisAlignment.center, // Align content to the left (if needed)
            children: [
              Container(
                width: double.infinity, // Ensures the button spans the full width
                margin: const EdgeInsets.only(bottom: 16, left: 15, right: 15), // Adjust side margin (removed bottom margin)
                padding: EdgeInsets.all(16.0), // Padding inside the box
                decoration: BoxDecoration(
                  color: Color(0xFFFFFDF5), // Background color (light green)
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 3), // Shadow offset
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Global Competition and Challenge",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Math Series 2025",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 8), // Space between the title and the text
                    Text(
                      "In partnership with Saddle River Day School, New Jersey, USA",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8), // Space between the title and the text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Row to display two images side by side
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Centers the images horizontally
                          children: [
                            // First Image
                            Image.asset(
                              'assets/images/gc_logo.jpg', // Replace with your first PNG image path
                              height: 50, // Adjust height as needed
                            ),
                            SizedBox(width: 16), // Space between the two images
                            // Second Image
                            Image.asset(
                              'assets/images/school_logo.png', // Replace with your second PNG image path
                              height: 50, // Adjust height as needed
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // The list of quiz buttons
              ...topics.map((topic) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16, left: 15, right: 15), // Adjust side margin here (left and right)
                  child: SizedBox(
                    width: double.infinity, // Ensures the button spans the full width
                    child: ElevatedButton(
                      onPressed: () => _startQuiz(context, topic['title']!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEDF1E6), // Custom color (green)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Padding inside the button
                        minimumSize: Size(double.infinity, 80), // Minimum height for consistency
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0), // Padding inside button content
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Align texts to the left
                          children: [
                            Text(
                              topic['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18, // Adjust size as needed
                              ),
                            ),
                            SizedBox(height: 4), // Spacing between title and description
                            Text(
                              topic['description']!,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14, // Adjust size as needed
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}