import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final supabase = Supabase.instance.client;

  bool _isLogin = true; // true = Login, false = Sign Up

  Future<void> submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      if (_isLogin) {
        // Login
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (response.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged in as ${response.user!.email}')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Home()),
          );
        }
      } else {
        // Sign Up
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
          data:{
            'phone': phoneController.text.trim() // Saved as metadata, because phone can't interfere with login.
          }
        );
        if (response.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign up successful. Please verify your email.')),
          );
        }
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (_isLogin == false)...[
              const SizedBox(height: 12),
              TextField(
              controller: phoneController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Phone Number (Optional)'),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submit,
              child: Text(_isLogin ? 'Login' : 'Sign Up'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin
                  ? "Don't have an account? Sign up"
                  : "Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}