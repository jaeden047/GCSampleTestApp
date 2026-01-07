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
  bool _isLoading = false; // Prevent multiple submissions

  // Input validation function
  String? _validateInputs() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    
    if (email.isEmpty) {
      return 'Email is required';
    }
    
    if (!email.contains('@') || !email.contains('.')) {
      return 'Please enter a valid email address';
    }
    
    if (password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    final specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!specialCharRegex.hasMatch(password)) {
      return r'Password must contain at least one special character: [!@#$%^&*(),.?":{}|<>]';
    }
    
    if (!_isLogin) {
      final name = nameController.text.trim();
      if (name.isEmpty) {
        return 'Name is required';
      }
    }
    
    return null; // when all validations passed
  }

  Future<void> submit() async {
    // Validate inputs first
    final validationError = _validateInputs();
    if (validationError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }
    
    // Prevent multiple submissions
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    
    
    await Future.delayed(const Duration(milliseconds: 50));
    
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      if (_isLogin) {
        // LOGIN FLOW
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        // Check if widget is still mounted
        if (!mounted) return;
        
        // Validate response.user is not null
        if (response.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged in as ${response.user?.email ?? email}')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Home()),
          );
        } else {
          // This shouldn't happen, but handle it gracefully
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. Please try again.')),
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
        final name = nameController.text.trim();
        
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {
            'phone': phone.isEmpty ? null : phone, // Saved as metadata, because phone can't interfere with login.
          },
        );
        
        // Check if widget is still mounted
        if (!mounted) return;
        
        // Validate response.user and response.user.id before using
        if (response.user != null && response.user?.id != null) {
          final userId = response.user!.id; 
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Check your email for a verification link. If you already have an account, try logging in instead.')),
          );
          
          // Wrap profile insert in separate try-catch
          try {
            await supabase.from('profiles').insert({
              'id': userId,
              'name': name,
              'email': email,
              'phone_number': phone.isEmpty ? null : phone,
            });
            
            // Profile insert succeeded - user can proceed
          } catch (profileError) {
            // Profile insert failed - handle gracefully
            if (!mounted) return;
            
            // Log the error (for debugging)
            print('Profile insert failed: $profileError');
            
            // Show user-friendly message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created, but profile setup failed. Please contact support or try updating your profile later.'),
                duration: Duration(seconds: 5),
              ),
            );
            
            // User is still authenticated, they can update profile later
            // Navigation can proceed since auth succeeded
          }
        } else {
          // Signup succeeded but user is null (unlikely but possible)
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign up completed, but user data is missing. Please try logging in.')),
          );
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
      redirectTo: 'http://localhost:50520/#/reset-password',
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
              keyboardType: TextInputType.emailAddress,
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
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number (Optional)'),
              ),
            ],
            const SizedBox(height: 20),
            _isLoading
              ? const SizedBox(
                  height: 70,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                )
              : GestureDetector(
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