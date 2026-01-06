import 'package:flutter/material.dart';
import '../main.dart';
import 'signup_data.dart';
import 'signup_screen4.dart';

// Screen 3: Password Creation
class SignupScreen3 extends StatefulWidget {
  final SignupData data;
  
  const SignupScreen3({super.key, required this.data});

  @override
  State<SignupScreen3> createState() => _SignupScreen3State();
}

class _SignupScreen3State extends State<SignupScreen3> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  
  final tealBackground = MyApp.loginTealBackground;
  final pinkTitle = MyApp.loginPinkTitle;
  final darkNavyButton = MyApp.loginDarkNavyButton;
  final greySubtitle = MyApp.loginGreySubtitle;
  
  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  String? _validateInputs() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
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
    
    // Check for alphabet and number
    final hasAlphabet = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    
    if (!hasAlphabet) {
      return 'Password must contain at least one letter';
    }
    
    if (!hasNumber) {
      return 'Password must contain at least one number';
    }
    
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  void _createAccount() {
    final validationError = _validateInputs();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }
    
    final updatedData = widget.data.copyWith(
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SignupScreen4(data: updatedData)),
    );
  }
  
  void _goBack() {
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final horizontalPadding = isMobile ? 24.0 : 40.0;
    final verticalPadding = isMobile ? 32.0 : 48.0;
    
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      "Create a strong password",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 32 : 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    // Instruction text
                    Text(
                      'password should have a combination of alphabet, number and special case',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: greySubtitle,
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: isMobile ? 32 : 40),
                    // Password field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_passwordVisible,
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
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
                    SizedBox(height: isMobile ? 16 : 20),
                    // Confirm password field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: !_confirmPasswordVisible,
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                        decoration: InputDecoration(
                          hintText: 'Re-enter password',
                          hintStyle: TextStyle(color: greySubtitle, fontSize: isMobile ? 14 : 16),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: isMobile ? 16 : 18,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: greySubtitle,
                            ),
                            onPressed: () {
                              setState(() {
                                _confirmPasswordVisible = !_confirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 32 : 40),
                    // Create account button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkNavyButton,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 16 : 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Create account',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 24 : 32),
                    // Back link
                    Center(
                      child: GestureDetector(
                        onTap: _goBack,
                        child: Text(
                          'back',
                          style: TextStyle(
                            color: greySubtitle,
                            fontSize: isMobile ? 13 : 14,
                            fontFamily: 'serif',
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

// Custom ScrollBehavior to hide scrollbars
class _NoScrollbarScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
