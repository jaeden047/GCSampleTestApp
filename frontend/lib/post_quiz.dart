import 'package:flutter/material.dart';
import 'home.dart';

class PostQuiz extends StatelessWidget {
  final int score;
  final VoidCallback onRedoQuiz;
  final VoidCallback onViewAnswers;

  const PostQuiz({
    super.key,
    required this.score,
    required this.onRedoQuiz,
    required this.onViewAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Complete')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Score: $score/10',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onRedoQuiz();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Home()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                ),
                ElevatedButton.icon(
                  onPressed: onViewAnswers,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Answers'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
