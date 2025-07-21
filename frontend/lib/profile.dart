import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import for Supabase
import 'package:flutter_svg/flutter_svg.dart'; // import svg image

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
  String school = '';
  String country = '';
  final phoneController = TextEditingController();
  final schoolController = TextEditingController();
  final countryController = TextEditingController();

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
        phone = profile['phone_number'] ?? 'Not provided';
        school = profile['school'] ?? 'Not provided';
        country = profile['country'] ?? 'Not provided';
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
      // pre set the info to the text field
      setState(() {
        phoneController.text = response['phone_number'] ?? '';
        schoolController.text = response['school'] ?? '';
        countryController.text = response['country'] ?? '';
      });
      return response;
    }
    return null;  // Return null if no user is logged in
  }

  // Function to update the user profile information
  Future<void> updateUserProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      final phone = phoneController.text.trim();
      final school = schoolController.text.trim();
      final country = countryController.text.trim();

      final response = await supabase.from('profiles').update({
        'phone_number': phone.isEmpty ? null : phone,
        'school': school.isEmpty ? null : school,
        'country': country.isEmpty ? null : country,
      }).eq('id', user.id);

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: ${response.error!.message}')));
      }
    }
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
                  SizedBox(height: 30),
                  // Display user profile data here
                  Text(
                    'Personal Info', 
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Phone'),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: schoolController,
                    decoration: InputDecoration(labelText: 'School'),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: countryController,
                    decoration: InputDecoration(labelText: 'Country'),
                  ),
                ],
              ),
            ),
            // Buttons for Edit Profile and Sign Out
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: updateUserProfile,
                    child: SvgPicture.asset(
                      'assets/images/update_button.svg',
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: signOut,
                    child: SvgPicture.asset(
                      'assets/images/signout_button3.svg',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
