import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller to access the text input
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  // Supabase client instance for performing auth and database operations
  final supabase = Supabase.instance.client;

  // Attempts to log in the user using email and password from the input fields
  Future<void> login() async {
    // Retrieve and trim the email input
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      // Attempt to sign in with Supabase using provided credentials
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        // If the login is successful and a user object is returned
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged in as ${response.user!.email}')), // Confirmation messagge
        );
        // Navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Home()),
        );
      }
    } on AuthException catch (e) {
      // Login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              // Input field for user to enter their email
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              // Input field for user to enter their password
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              // Button to trigger login using entered email and password
              onPressed: login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}