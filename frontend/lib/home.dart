import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // import svg image
import 'package:frontend/login.dart';

// navigated pages
import 'api_service.dart';
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
    // We need token (for access) and field map (for UI)
    final profile = await ApiService.instance.getProfile(); 
    // Inside getProfile(), it first reads the saved token from storage
    // The returned profile is only the server’s JSON response map.
    // The token is not inside profile. It is in _storage
    final name = profile['name']?.toString(); 

    // If token exists in storage, the app will treat the user as logged in (or will try to).
    if (name == null){
      // this session is bad
      // Remove session token, send to login page, provide error message that the user did not have a name.
      await ApiService.instance.clearToken();
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session invalid. Please log in again.')),
      );
      Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
      ); 
      }
    setState(() { // Triggers rebuild with updated fields
    isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top header row
              Padding(
                padding: const EdgeInsets.only(top: 60.0, left: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProfilePage()),
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF2A262A),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            userName.toString(),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      userName != null ? 'Hello, $userName' : 'Hello, User',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Competition section
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Competition',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => MathGrades()),
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/images/mathImage.svg',
                      height: 280,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EnvTopics()),
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/images/envImage.svg',
                      height: 280,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Results section
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    'Results Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Results()),
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
      ),
    );
  }
}