import 'package:flutter/material.dart';
// EnvTopics page
// Showcase all environmental quiz topics for the users to select
// It is not in development stage for now

class EnvTopics extends StatelessWidget {
  const EnvTopics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Environmental Topics'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Goes back to previous screen
          },
        ),
      ),
      body: Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}