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
        // SIGNUP FLOW
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
            const SnackBar(content: Text('Sign up successful. Please verify your email.')),
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
      // Supabase authentication errors
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      // Catch any other unexpected errors
      if (!mounted) return;
      print('Unexpected error during ${_isLogin ? "login" : "signup"}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
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
    );
  }
}