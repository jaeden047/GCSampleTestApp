import 'package:flutter/material.dart';
// MathGrades page
// Showcase all mathematics grades for the users to select
// This page should lead users to quiz page

class MathGrades extends StatelessWidget {
  const MathGrades({super.key});

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
                // TODO: Connect to Quiz page
              },
              child: Text('Take a Quiz'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Connect to View Past Results
              },
              child: Text('View Past Results'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Connect to Settings or Profile
              },
              child: Text('Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
