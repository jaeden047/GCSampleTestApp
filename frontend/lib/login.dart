import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
import 'home.dart';
import 'main.dart';
import 'signup/signup_screen1.dart';

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

// Custom ScrollBehavior to hide scrollbars
class _NoScrollbarScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // Return child without scrollbar
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // Return child without overscroll indicator
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

  bool _isLoading = false; // Prevent multiple submissions
  bool _passwordVisible = false; // Password visibility toggle

  // Input validation function (login only)
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
    } on AuthException catch (e) {
      // Supabase authentication errors
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      // Catch any other unexpected errors
      if (!mounted) return;
      print('Unexpected error during login: $e');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get colors from MyApp theme
    final tealBackground = MyApp.loginTealBackground;
    final pinkTitle = MyApp.loginPinkTitle;
    final darkNavyButton = MyApp.loginDarkNavyButton;
    final greySubtitle = MyApp.loginGreySubtitle;
    
    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final horizontalPadding = isMobile ? 24.0 : 40.0;
    final verticalPadding = isMobile ? 32.0 : 48.0;
    final titleFontSize = isMobile ? 28.0 : 36.0;
    final subtitleFontSize = isMobile ? 14.0 : 16.0;
    final logoHeight = isMobile ? 80.0 : 120.0;
    
    return Scaffold(
      backgroundColor: tealBackground,
      body: SafeArea(
        child: Center(
          child: ScrollConfiguration(
            behavior: _NoScrollbarScrollBehavior(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 500,
                minHeight: screenHeight - (verticalPadding * 2) - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/images/gcFuture.png',
                            height: logoHeight,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: isMobile ? 32 : 40),
                        // Title
                        Text(
                          'Login to your account!',
                          style: TextStyle(
                            color: pinkTitle,
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                        // Subtitle
                        Text(
                          'Enter your verified account details to start the quiz.',
                          style: TextStyle(
                            color: greySubtitle,
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: isMobile ? 32 : 40),
                        // Email/Student ID field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontSize: isMobile ? 14 : 16),
                            decoration: InputDecoration(
                              hintText: 'Student ID or your email',
                              hintStyle: TextStyle(color: greySubtitle, fontSize: isMobile ? 14 : 16),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isMobile ? 16 : 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        // Password field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: passwordController,
                            obscureText: !_passwordVisible,
                            style: TextStyle(fontSize: isMobile ? 14 : 16),
                            decoration: InputDecoration(
                              hintText: 'Enter password',
                              hintStyle: TextStyle(color: greySubtitle, fontSize: isMobile ? 14 : 16),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isMobile ? 16 : 18,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: greySubtitle,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 32 : 40),
                        // Loading spinner (when loading)
                        if (_isLoading) ...[
                          const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: isMobile ? 24 : 32),
                        ],
                        // Login/Signup button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkNavyButton,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: darkNavyButton.withOpacity(0.6),
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 16 : 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _isLoading
                                  ? 'processing..'
                                  : 'Login',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        // Navigate to signup
                        Center(
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    // Navigate to first signup screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => SignupScreen1()),
                                    );
                                  },
                            child: Text(
                              "Don't have an account? Sign up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 13 : 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}