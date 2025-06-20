import 'package:flutter/material.dart';
import 'quiz.dart';
import 'api_service.dart';
// MathGrades page
// Showcase all mathematics grades for the users to select
// This page should lead users to quiz page
class MathGrades extends StatelessWidget {
  const MathGrades({super.key});

  // Updated to accept topic name instead of grade number
  void _startQuiz(BuildContext context, String topicName) async {
    final token = await ApiService.getToken();
    
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found, please log in again.')),
      );
      return;
    }

    // Updated API call with topicName
    final response = await ApiService.postQuiz(topicName, token);

    if (!context.mounted) return;

    if (response != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizPage(
            attemptId: response['attempt_id'],
            questions: response['questions'],
            topicName: topicName,
            onRedoQuiz: () => _startQuiz(context, topicName),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load quiz.')),
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

