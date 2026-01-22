import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';
import 'signup_data.dart';

// Screen 4: Email Verification Confirmation
class SignupScreen4 extends StatefulWidget {
  final SignupData data;
  
  const SignupScreen4({super.key, required this.data});

  @override
  State<SignupScreen4> createState() => _SignupScreen4State();
}

class _SignupScreen4State extends State<SignupScreen4> {
  final tealBackground = MyApp.loginTealBackground;
  final pinkTitle = MyApp.loginPinkTitle;
  final greySubtitle = MyApp.loginGreySubtitle;
  
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
                  clipBehavior: Clip.none,
                  children: [
                    // Main content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isMobile ? 40 : 60),
                        // Email icon (SVG)
                        SvgPicture.asset(
                          'assets/images/fast_email.svg',
                          width: isMobile ? 100 : 120,
                          height: isMobile ? 100 : 120,
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
                      ],
                    ),
                    // Decorative SVG elements - positioned after Column so they render on top
                    // Using percentage-based positioning similar to signup_screen2.dart
                    Positioned(
                      top: screenHeight * 0.06,
                      left: screenWidth * 0.10,
                      child: SvgPicture.asset(
                        'assets/images/pinkstar.svg',
                        width: isMobile ? 18 : 20,
                        height: isMobile ? 17 : 19,
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.14,
                      left: screenWidth * 0.25,
                      child: SvgPicture.asset(
                        'assets/images/cloud.svg',
                        width: isMobile ? 50 : 60,
                        height: isMobile ? 14 : 17,
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.10,
                      right: screenWidth * 0.12,
                      child: SvgPicture.asset(
                        'assets/images/pinkstar.svg',
                        width: isMobile ? 18 : 20,
                        height: isMobile ? 17 : 19,
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.22,
                      right: screenWidth * 0.18,
                      child: SvgPicture.asset(
                        'assets/images/pinkstar.svg',
                        width: isMobile ? 18 : 20,
                        height: isMobile ? 17 : 19,
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.30,
                      left: screenWidth * 0.15,
                      child: SvgPicture.asset(
                        'assets/images/cloud.svg',
                        width: isMobile ? 50 : 60,
                        height: isMobile ? 14 : 17,
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.38,
                      right: screenWidth * 0.08,
                      child: SvgPicture.asset(
                        'assets/images/pinkstar.svg',
                        width: isMobile ? 18 : 20,
                        height: isMobile ? 17 : 19,
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
