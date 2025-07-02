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

    try {
      // 1. Generate 10 question IDs for the quiz
      final questions = await supabase.rpc('generate_questions', params: {
        'topic_input': topicName,
      });

      if (questions is List) {
        final questionIds = questions.cast<int>();
        print('Got 10 question IDs: $questionIds');

        // 2. Create the quiz and generate an ID
        final response = await supabase.rpc('create_quiz', params: {
          'p_user_id': user.id,
          'p_question_list': questionIds,
        });
        
        print('attempt_id is $response');
        // 3. Navigate to quiz page if the attempt ID is returned
        if (response is int) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizPage(
                attemptId: response,
                questions: [],
                topicName: topicName,
                onRedoQuiz: () => _startQuiz(context, topicName),
              ),
            ),
          );
        } else {
          print('Failed to create quiz: $response');
        }
      } else {
        print('Unexpected response: $questions');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting quiz: $e')),
      );
    }
}


  @override
  Widget build(BuildContext context) {
    final topics = ['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];

    return Scaffold(
      appBar: AppBar(title: Text('Math Quizzes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: topics.map((topic) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: () => _startQuiz(context, topic),
                child: Text(topic),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}