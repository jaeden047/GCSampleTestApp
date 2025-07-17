import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
import 'package:flutter_svg/flutter_svg.dart'; // import svg image

// navigated pages
import 'profile.dart';
import 'math_grades.dart';
import 'env_topics.dart';
import 'results.dart';

// Home dashboard: Math quiz, Environmental quiz, Past Results
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Fetch user data from Supabase when Home page initializes
  Future<void> _getUserData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('name')
            .eq('id', user.id)
            .single();

        if (response['name'] != null) {
          setState(() {
            userName = response['name'];
          });
        }
      } catch (e) {
        // Handle error if fetching profile fails
        // print("Error fetching user data: $e");
      }
    }
    
    // Stop loading indicator once data is fetched
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Padding for the entire row (top space + left indentation)
            Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 10.0), // Add top space and left padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // Align the items to the left
                crossAxisAlignment: CrossAxisAlignment.center, // Vertically center the content in the row
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to Profile Page when the circle is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                    // Profile Circle with the first letter of the user's name
                    child: Container(
                      width: 50, // Circle width
                      height: 50, // Circle height
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Makes the container circular
                        border: Border.all(color: Color(0xFF2A262A), width: 2), // Border around the circle
                      ),
                      child: Center(
                        child: Text(
                          userName != null ? userName![0].toUpperCase() : '', // First letter of the user's name
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Add space between the circle and the text
                  // Greeting text
                  Text(
                    userName != null ? 'Hello, $userName' : 'Hello, User',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      // color: Color(0xFF2A262A), // Custom color #2A262A
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30), // Space between the greeting and the rest of the content
            
            // Rest of the UI content
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0), // tab-style indent
                child: Text(
                  'Competition',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
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
                    height: 280,
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
                    height: 280,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0), // tab-style indent
                child: Text(
                  'Results Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Results()),
                );
              },
              child: SvgPicture.asset(
                'assets/images/pastImage.svg',
                height: 175,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
