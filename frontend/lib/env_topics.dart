import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertically center the content
          crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center the content
          children: [
            // SVG Image
            SvgPicture.asset(
              'assets/images/grey_leaf.svg',
              height: 100,
            ),
            SizedBox(height: 20), // Space between the image and the text
            // Text message
            Text(
              'Coming Soon',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'More quizzes to come',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}