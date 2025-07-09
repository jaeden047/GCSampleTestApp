import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import for Supabase
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  String phone = '';
  String country = '';
  String school = '';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  // Function to fetch user profile data
  Future<void> fetchUserProfile() async {
    Map<String, dynamic>? profile = await getUserProfile();
    if (profile != null) {
      setState(() {
        name = profile['name'];
        email = profile['email'];
        phone = profile['phone'] ?? 'Not provided';
        country = profile['country'] ?? 'Not provided';
        school = profile['school'] ?? 'Not provided';
      });
    }
  }

  // Function to get user profile from Supabase
  Future<Map<String, dynamic>?> getUserProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from('profiles')
          .select('name, email, phone_number, school, country')
          .eq('id', user.id)
          .single();

      return response;
    }
    return null;  // Return null if no user is logged in
  }

  // Function to sign out
  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(begin: 0.0, end: 1.0);
          var opacityAnimation = animation.drive(tween);

          return FadeTransition(opacity: opacityAnimation, child: child);
        },
      ),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0), // Padding to the left
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                children: [
                  Text(
                    name, 
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email, 
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Profile Info', 
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Display user profile data here
            Text('Phone: $phone', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Country: $country', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('School: $school', style: TextStyle(fontSize: 18)),

            // Buttons for Edit Profile and Sign Out
            SizedBox(height: 20),
            // Edit Profile Button
            ElevatedButton(
              onPressed: () {
                // Implement Edit Profile functionality (optional)
                // You can navigate to an edit profile page here
              },
              child: Text('Edit Profile'),
            ),
            SizedBox(height: 10), // Add space between buttons

            // Sign Out Button
            ElevatedButton(
              onPressed: signOut,
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
