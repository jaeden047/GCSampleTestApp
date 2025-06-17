// home.dart
import 'package:flutter/material.dart';
import 'math_grades.dart';
import 'env_topics.dart';
import 'results.dart';
import 'package:flutter_svg/flutter_svg.dart'; // import svg image
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MathGrades()),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/images/mathImage.svg',
                    height: 250,
                  ),
                ),
                SizedBox(width: 20), // spacing between the two SVGs
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EnvTopics()),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/images/envImage.svg',
                    height: 250,
                  ),
                ),
              ],
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
