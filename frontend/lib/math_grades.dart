import 'package:flutter/material.dart';
import 'quiz.dart';
import 'api_service.dart';
// MathGrades page
// Showcase all mathematics grades for the users to select
// This page should lead users to quiz page

class MathGrades extends StatelessWidget {
  const MathGrades({super.key});


  void _startQuiz(BuildContext context, int grade) async {
    // Retrieve the token
    final token = await ApiService.getToken();
    
    if (token == null) {
      // Handle the case where no token is available (e.g., prompt the user to log in again)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token not found, please log in again.')),
      );
      return;
    }

    final response = await ApiService.postQuiz(grade, token);

    if (!context.mounted) return; // Safely check if context is still valid

    if (response != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizPage(
            attemptId: response['attempt_id'],
            questions: response['questions'],
            grade: grade,
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
    final grades = [7, 8, 9, 10, 11, 12];

    return Scaffold(
      appBar: AppBar(title: Text('Math Quizzes')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: grades.map((grade) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: () => _startQuiz(context, grade),
                child: Text('Grade $grade'),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
