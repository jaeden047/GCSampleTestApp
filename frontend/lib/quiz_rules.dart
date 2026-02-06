import 'package:flutter/material.dart';
import 'main.dart';

class QuizRulesScreen extends StatelessWidget {
  final VoidCallback onAgree;
  final VoidCallback? onClose;

  const QuizRulesScreen({
    super.key,
    required this.onAgree,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final tealBackground = MyApp.loginTealBackground; // #439D93

    return Scaffold(
      backgroundColor: tealBackground,
      body: SafeArea(
        child: Center(
          child: _TermsContent(
            title: 'Quiz Rules and Regulations',
            subheader: '** Read all instructions carefully before starting the quiz **',
            content: _getQuizRulesContent(),
            onAgree: onAgree,
            onClose: onClose,
            isMobile: isMobile,
          ),
        ),
      ),
    );
  }

  String _getQuizRulesContent() {
    return '''The exam consists of multiple questions that must be answered in sequence.

Questions will appear in a random order and may be different for other students taking the exam at the same time.

There is no negative marking for incorrect answers.

You may skip a question if you are unsure of the answer.

Once you skip a question, you cannot return to it later.

Please decide carefully before moving on to the next question.

Do not spend too much time on a single question. Manage your time wisely.

Your final score is based only on the total number of correct answers.

Select only one answer per question, unless otherwise instructed.

Ensure your submission before the exam time ends.

Any form of unfair practice will result in disqualification.

Best wishes for your exam. Work calmly and confidently!''';
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
                      top: onClose != null ? 60.0 : (isMobile ? 24.0 : 32.0),
                      left: isMobile ? 24.0 : 32.0,
                      right: isMobile ? 24.0 : 32.0,
                      bottom: isMobile ? 24.0 : 32.0,
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
