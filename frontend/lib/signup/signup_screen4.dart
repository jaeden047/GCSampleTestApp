import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'signup_data.dart';
import 'signup_screen1.dart';
import '../home.dart';

// Screen 4: Email Verification Confirmation
class SignupScreen4 extends StatefulWidget {
  final SignupData data;
  
  const SignupScreen4({super.key, required this.data});

  @override
  State<SignupScreen4> createState() => _SignupScreen4State();
}

class _SignupScreen4State extends State<SignupScreen4> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _accountCreated = false;
  
  final tealBackground = MyApp.loginTealBackground;
  final pinkTitle = MyApp.loginPinkTitle;
  final darkNavyButton = MyApp.loginDarkNavyButton;
  final greySubtitle = MyApp.loginGreySubtitle;
  
  @override
  void initState() {
    super.initState();
    // Account will be created when user clicks "Create account" button
  }
  
  Future<void> _createAccount() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create Supabase auth account
      final response = await supabase.auth.signUp(
        email: widget.data.email!,
        password: widget.data.password!,
        data: {
          'phone': widget.data.phoneNumber,
        },
      );
      
      if (!mounted) return;
      
      if (response.user != null && response.user?.id != null) {
        final userId = response.user!.id;
        
        // Save to profiles table (only old fields for now)
        try {
          await supabase.from('profiles').insert({
            'id': userId,
            'name': widget.data.fullName,
            'email': widget.data.email,
            'phone_number': widget.data.phoneNumber,
            // New fields will be saved later when database is updated
            // 'gender': widget.data.gender,
            // 'address': widget.data.address,
            // 'school': widget.data.institutionSchool,
            // 'country': widget.data.residentialCountry,
          });
          
          setState(() {
            _accountCreated = true;
            _isLoading = false;
          });
        } catch (profileError) {
          if (!mounted) return;
          print('Profile insert failed: $profileError');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created, but profile setup failed. Please contact support.'),
              duration: Duration(seconds: 5),
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up completed, but user data is missing. Please try logging in.')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      print('Unexpected error during signup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  String _maskEmail(String email) {
    if (email.isEmpty) return '';
    final parts = email.split('@');
    if (parts.length != 2) return email;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 3) {
      return '${'*' * username.length}@$domain';
    }
    
    final visiblePart = username.substring(username.length - 3);
    final maskedPart = '*' * (username.length - 3);
    return '$maskedPart$visiblePart@$domain';
  }
  
  Widget _buildStarDecoration() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: pinkTitle,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.star,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildCloudDecoration() {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: pinkTitle.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
    );
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
                child: Stack(
                  children: [
                    // Decorative elements - more scattered and natural
                    Positioned(
                      top: screenHeight * 0.06,
                      left: screenWidth * 0.10,
                      child: _buildStarDecoration(),
                    ),
                    Positioned(
                      top: screenHeight * 0.14,
                      left: screenWidth * 0.25,
                      child: _buildCloudDecoration(),
                    ),
                    Positioned(
                      top: screenHeight * 0.10,
                      right: screenWidth * 0.12,
                      child: _buildStarDecoration(),
                    ),
                    Positioned(
                      top: screenHeight * 0.22,
                      right: screenWidth * 0.18,
                      child: _buildStarDecoration(),
                    ),
                    Positioned(
                      top: screenHeight * 0.30,
                      left: screenWidth * 0.15,
                      child: _buildCloudDecoration(),
                    ),
                    Positioned(
                      top: screenHeight * 0.38,
                      right: screenWidth * 0.08,
                      child: _buildStarDecoration(),
                    ),
                    // Main content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isMobile ? 40 : 60),
                        // Email icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: pinkTitle,
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Envelope icon
                              Icon(
                                Icons.mail_outline,
                                size: 60,
                                color: Colors.white,
                              ),
                              // Three lines on the left
                              Positioned(
                                left: 20,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    3,
                                    (index) => Container(
                                      width: 3,
                                      height: 20,
                                      margin: const EdgeInsets.only(bottom: 4),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 40 : 60),
                        // Hurray title
                        Text(
                          'Hurray!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 40 : 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        // Check your email
                        Text(
                          'Check your email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 32 : 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        // Instruction text
                        Text(
                          'We have sent you a verification code to the email address you provided.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: greySubtitle,
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        // Masked email
                        Text(
                          _maskEmail(widget.data.email ?? ''),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: greySubtitle,
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        // Go back and change email link
                        GestureDetector(
                          onTap: () {
                            // Navigate back to screen 1 with existing data so user can edit email
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SignupScreen1(initialData: widget.data),
                              ),
                              (route) => route.isFirst, // Keep only the login screen
                            );
                          },
                          child: Text(
                            'go back and change the email',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: greySubtitle.withOpacity(0.8),
                              fontSize: isMobile ? 13 : 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 40 : 60),
                        // Create account button (or loading)
                        if (_isLoading)
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        else if (_accountCreated)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to home after email verification
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => Home()),
                                  (route) => false,
                                );
                              },
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
                          )
                        else
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
                      ],
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
