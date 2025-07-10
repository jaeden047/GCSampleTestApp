import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
            SvgPicture.asset(
              'assets/images/stars.svg',
              height: 110,
            ),
            const SizedBox(height: 24),
            Text(
              'Your Score: $score/10',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          onRedoQuiz();
                        });
                      },
                      child: SvgPicture.asset(
                        'assets/images/redo_button.svg',
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Redo', style: TextStyle(fontSize: 14)),
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const Home()),
                          (route) => false,
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/images/home_button.svg',
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Home', style: TextStyle(fontSize: 14)),
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: onViewAnswers,
                      child: SvgPicture.asset(
                        'assets/images/results_button.svg',
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Answers', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
