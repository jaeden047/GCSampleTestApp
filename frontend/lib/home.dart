// home.dart
import 'package:flutter/material.dart';
import 'math_grades.dart';
import 'env_topics.dart';
import 'results.dart';
// Home dashboard: Math quiz, Environmental quiz, Past Results

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome to Future Mind')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to view math grades selections
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MathGrades()),
                );
              },
              child: Text('Take a Quiz (Math)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to view environments selections
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EnvTopics()),
                );
              },
              child: Text('Take a Quiz (Environment)'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Connect to View Past Results
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Results()),
                );
              },
              child: Text('View Past Results'),
            ),
          ],
        ),
      ),
    );
  }
}
