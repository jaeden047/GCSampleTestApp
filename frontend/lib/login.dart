import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
import 'home.dart';

// Known Errors:
// --
// Null issue - Resolved (Needs tests)
// The fact you can back out during a one-attempt quiz - Resolved
// "Are you sure?" check - verifying all blanks are filled - Resolved
// Profile check - Unnecessary/Resolved
// --
// README.txt
// Rewrite comments for clarity
// Package, deploy, finish.

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
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
            SnackBar(content: Text('Logged in as ${response.user?.email}')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Home()),
          );
        }
      } else {
        // Sign Up
        final name = nameController.text.trim();
        if (name.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Full Name is required.')),
          );
          return;
        }
        // : if the “final name” is empty, do not continue.

        final phone = phoneController.text.trim();
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
          // phone: phone,
          data:{
            'phone': phone // Saved as metadata, because phone can't interfere with login.
          }
        );
        if (response.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Check your email for a verification link. If you already have an account, try logging in instead.')),
          );
          // Insert to profiles table
          final userId = response.user?.id;
          await supabase.from('profiles').insert({
            'id': userId,
            'name': nameController.text.trim(),
            'email': email,
            'phone_number': phone,
          });

        }
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Future<void> _forgotPassword() async {
  final email = emailController.text.trim();

  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter your email first.')),
    );
    return;
  } // Makes sure the user puts in an email before clicking forgot password

  try {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'https://future-minds-challenge.web.app/#/reset-password',
    ); 
    /*
    Supabase receives a request to initiate a password reset flow for that email.
    If the email exists, Supabase sends a password-reset email.
    If the email does not exist, Supabase does nothing visible.
    Your app does not get told which case happened
    */
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "If an account exists for this email, you'll receive a reset link shortly. Check your email.",
        ),
      ),
    );
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
      body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/gcFuture.png',
            ),
            if (_isLogin == false)...[
              const SizedBox(height: 12),
              TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              ),
            ],
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
            if (_isLogin) ...[
                Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                onPressed: _forgotPassword,
                child: const Text('Forgot password?'),
                ),
              ),
            ],
            if (_isLogin == false)...[
              const SizedBox(height: 12),
              TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number (Optional)'),
              ),
            ],
            const SizedBox(height: 20),
            GestureDetector(
              onTap: submit,
              child: SvgPicture.asset(
                _isLogin ? 'assets/images/login_button.svg' : 'assets/images/signup_button.svg',
              ),
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
      ),
    );
  }
}