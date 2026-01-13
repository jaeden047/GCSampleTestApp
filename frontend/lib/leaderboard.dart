import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class Leaderboard extends StatelessWidget {
  final String topicName;

  const Leaderboard({
    super.key,
    required this.topicName,
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
      .select('score, duration_seconds, profiles(name)')
      .eq('topic_id', topicId)
      .order('score', ascending: false)
      .order('duration_seconds', ascending: true)
      .limit(10);

    return List<Map<String, dynamic>>.from(attemptsResponse);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: MyApp.homeTealGreen,
      appBar: AppBar(
        backgroundColor: MyApp.homeTealGreen,
        foregroundColor: MyApp.homeWhite,
        title: const Text('Leaderboard'),
        automaticallyImplyLeading: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLeaderboard(topicName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: MyApp.homeWhite,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading leaderboard',
                style: TextStyle(
                  color: MyApp.homeWhite,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No data found',
                style: TextStyle(
                  color: MyApp.homeWhite,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            );
          }

          final leaderboard = snapshot.data!;
          return ListView.separated(
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            itemCount: leaderboard.length,
            separatorBuilder: (_, __) => Divider(
              color: MyApp.homeWhite.withOpacity(0.3),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final user = leaderboard[index];
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 20,
                  vertical: isMobile ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  color: MyApp.homeWhite.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Rank number
                    Container(
                      width: isMobile ? 40 : 50,
                      height: isMobile ? 40 : 50,
                      decoration: BoxDecoration(
                        color: MyApp.homeWhite,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '#${index + 1}',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: MyApp.homeTealGreen,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 16 : 20),
                    // User name and score
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['profiles']?['name'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: MyApp.homeWhite,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Score: ${user['score']} • Time: ${user['duration_seconds']}s',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              color: MyApp.homeWhite.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
