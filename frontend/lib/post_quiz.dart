import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
import 'home.dart';

class PostQuiz extends StatelessWidget {
  final double score;
  final VoidCallback onRedoQuiz;
  final String topicName;
  final VoidCallback onViewAnswers;

  const PostQuiz({
    super.key,
    required this.score,
    required this.onRedoQuiz,
    required this.topicName,
    required this.onViewAnswers,
  });

  Future<List<Map<String, dynamic>>> fetchLeaderboard(String topicName) async {
    final supabase = Supabase.instance.client;

    // Step 1: Get topic_id for given topicName
    final topicResponse = await supabase
        .from('topics')
        .select('topic_id')
        .eq('topic_name', topicName)
        .single();

    final topicId = topicResponse['topic_id'];

    // Step 2: Get top 10 test_attempts joined with users, sorted
    final attemptsResponse = await supabase
      .from('test_attempts')
      .select('score, duration_seconds, profiles(name)')  // Fetching 'name' from 'profiles' table
      .eq('topic_id', topicId)
      .order('score', ascending: false)  // Highest score first
      .order('duration_seconds', ascending: true)  // Shortest duration first
      .limit(10);

    return List<Map<String, dynamic>>.from(attemptsResponse);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Complete'), automaticallyImplyLeading: false),
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
              'Your Score: ${score}%',
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
                      onTap: onRedoQuiz, // Call onRedoQuiz directly
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
            // LEADERBOARD SECTION
            const SizedBox(height: 24),
            const Text('Leaderboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchLeaderboard(topicName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Error loading leaderboard');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No data found');
                  }

                  final leaderboard = snapshot.data!;
                  return ListView.separated(
                    itemCount: leaderboard.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = leaderboard[index];
                      return ListTile(
                        leading: Text('#${index + 1}'),
                        title: Text(user['profiles']['name']),
                        subtitle: Text('Score: ${user['score']} • Time: ${user['duration_seconds']}s'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
