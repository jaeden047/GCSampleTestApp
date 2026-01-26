import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'login.dart';
import 'home.dart';

class PlatformTermsScreen extends StatefulWidget {
  const PlatformTermsScreen({super.key});

  @override
  State<PlatformTermsScreen> createState() => _PlatformTermsScreenState();
}

class _PlatformTermsScreenState extends State<PlatformTermsScreen> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final tealBackground = MyApp.loginTealBackground; // #439D93

    return Scaffold(
      backgroundColor: tealBackground,
      body: SafeArea(
        child: Center(
          child: _TermsContent(
            title: 'Platform Terms',
            content: _getPlatformTermsContent(),
            onAgree: () {
              if (!mounted) return;
              // Navigate to home screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Home()),
              );
            },
            onClose: () async {
              // Sign out and go back to login
              await Supabase.instance.client.auth.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
                (route) => false, // Remove all previous routes
              );
            },
            isMobile: isMobile,
          ),
        ),
      ),
    );
  }

  String _getPlatformTermsContent() {
    return '''By accessing or using this quiz application ("App"), you acknowledge that you have read, understood, and agreed to be bound by these Terms & Conditions. If you do not agree, you must not use the App.

To maintain the integrity, fairness, and security of quizzes and assessments, the App employs monitoring technologies designed to detect cheating, impersonation, or unauthorized assistance.

By using the App, you expressly consent to the collection and analysis of keystroke activity, which may include:

• Typing patterns and input timing
• Copy, paste, or automated input detection
• Navigation and interaction behavior within the App

This data is used solely for security, verification, and integrity analysis and not for profiling unrelated to the quiz.

** You Must Agree to the Terms and Conditions to use the App. **''';
  }
}

// Reusable widget for terms/rules screens
class _TermsContent extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onAgree;
  final bool isMobile;
  final String? subheader;
  final VoidCallback? onClose;

  const _TermsContent({
    required this.title,
    required this.content,
    required this.onAgree,
    required this.isMobile,
    this.subheader,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final darkNavyButton = MyApp.loginDarkNavyButton; // #14172D

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.0 : 40.0,
        vertical: isMobile ? 20.0 : 30.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // White content panel with rounded corners
          Expanded(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 600,
                maxHeight: screenHeight * 0.75,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Close button (if onClose callback is provided)
                  if (onClose != null)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        icon: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.black87,
                          ),
                        ),
                        onPressed: onClose,
                      ),
                    ),
                  // Scrollable content
                  Padding(
                    padding: EdgeInsets.only(
                      top: title == 'Platform Terms' ? 60.0 : 30.0,
                      left: isMobile ? 24.0 : 32.0,
                      right: isMobile ? 24.0 : 32.0,
                      bottom: 24.0,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header (serif font, bold, large)
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: isMobile ? 28 : 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                              fontFamily: 'serif',
                            ),
                          ),
                          // Subheader if provided
                          if (subheader != null) ...[
                            SizedBox(height: 12),
                            Text(
                              subheader!,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                                fontFamily: 'sans-serif',
                              ),
                            ),
                          ],
                          SizedBox(height: 24),
                          // Body content (sans-serif, regular)
                          Text(
                            content,
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 16,
                              height: 1.6,
                              color: Colors.grey[800],
                              fontFamily: 'sans-serif',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isMobile ? 20 : 24),
          // Agree button - smaller and centered
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? 200 : 250,
              ),
              child: ElevatedButton(
                onPressed: onAgree,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkNavyButton,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 40 : 50,
                    vertical: isMobile ? 14 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Agree',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'sans-serif',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
