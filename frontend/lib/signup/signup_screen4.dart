import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';
import '../login.dart';
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

  /// Content layout heights (from top of Column) - used for collision bounds
  static const _iconTop = 40.0;
  static const _iconH = 100.0;
  static const _iconToHurray = 40.0;
  static const _hurrayH = 48.0;
  static const _hurrayToCheck = 16.0;
  static const _checkH = 36.0;
  static const _checkToInstruction = 24.0;
  static const _instructionH = 44.0;
  static const _instructionToEmail = 24.0;
  static const _emailH = 22.0;
  static const _emailToButton = 0.0;
  static const _buttonH = 48.0;

  /// Builds decorations with collision avoidance. Content bounds are computed from
  /// the known layout; decorations are placed only in safe zones.
  List<Widget> _buildDecorations({
    required double screenWidth,
    required double screenHeight,
    required double contentWidth,
    required bool isMobile,
  }) {
    const margin = 12.0;
    final starW = isMobile ? 18.0 : 20.0;
    final starH = isMobile ? 17.0 : 19.0;
    final cloudW = isMobile ? 50.0 : 60.0;
    final cloudH = isMobile ? 14.0 : 17.0;

    // Content area: centered in the scroll view's child (contentWidth = screenWidth - 2*padding)
    final contentAreaWidth = contentWidth;
    const maxTextWidth = 280.0;
    final actualContentWidth = contentAreaWidth < maxTextWidth ? contentAreaWidth : maxTextWidth;
    final contentLeft = (contentAreaWidth - actualContentWidth) / 2;
    final contentRight = contentLeft + actualContentWidth;

    // Vertical: Column is centered in minHeight. Approximate content top.
    final minHeight = screenHeight - 64;
    const contentHeight = _iconTop + _iconH + _iconToHurray + _hurrayH + _hurrayToCheck +
        _checkH + _checkToInstruction + _instructionH + _instructionToEmail + _emailH +
        _emailToButton + _buttonH;
    final contentTop = (minHeight - contentHeight) / 2;
    final contentBottom = contentTop + contentHeight;

    final contentRect = _Rect(contentLeft - margin, contentTop - margin,
        contentRight + margin, contentBottom + margin);

    bool overlapsAny(double left, double top, double w, double h, List<_Rect> placed) {
      final r = _Rect(left, top, left + w, top + h);
      if (contentRect.overlaps(r)) return true;
      for (final p in placed) {
        if (p.overlaps(r)) return true;
      }
      return false;
    }

    final placed = <_Rect>[];
    final decorations = <Widget>[];

    // Candidate positions: (onLeft, top as fraction of screenHeight)
    // Top/bottom zones avoid center content; algorithm skips any that overlap
    final starCandidates = [
      (true, 0.04), (false, 0.04), (true, 0.10), (false, 0.10),
      (true, 0.56), (false, 0.56), (true, 0.62), (false, 0.62),
    ];
    final cloudCandidates = [
      (true, 0.07), (false, 0.07), (true, 0.58), (false, 0.58),
      (true, 0.64), (false, 0.64),
    ];

    void tryPlaceStar(bool onLeft, double topFrac) {
      final top = screenHeight * topFrac;
      final left = onLeft ? 0.0 : contentAreaWidth - starW;
      if (overlapsAny(left, top, starW, starH, placed)) return;
      placed.add(_Rect(left, top, left + starW, top + starH));
      decorations.add(Positioned(
        left: onLeft ? left : null,
        right: onLeft ? null : 0.0,
        top: top,
        child: SvgPicture.asset('assets/images/pinkstar.svg', width: starW, height: starH),
      ));
    }

    void tryPlaceCloud(bool onLeft, double topFrac) {
      final top = screenHeight * topFrac;
      final left = onLeft ? 0.0 : contentAreaWidth - cloudW;
      if (overlapsAny(left, top, cloudW, cloudH, placed)) return;
      placed.add(_Rect(left, top, left + cloudW, top + cloudH));
      decorations.add(Positioned(
        left: onLeft ? left : null,
        right: onLeft ? null : 0.0,
        top: top,
        child: SvgPicture.asset('assets/images/cloud.svg', width: cloudW, height: cloudH),
      ));
    }

    int starsPlaced = 0;
    int cloudsPlaced = 0;
    for (final (onLeft, topFrac) in starCandidates) {
      if (starsPlaced >= 4) break;
      final before = decorations.length;
      tryPlaceStar(onLeft, topFrac);
      if (decorations.length > before) starsPlaced++;
    }
    for (final (onLeft, topFrac) in cloudCandidates) {
      if (cloudsPlaced >= 2) break;
      final before = decorations.length;
      tryPlaceCloud(onLeft, topFrac);
      if (decorations.length > before) cloudsPlaced++;
    }

    return decorations;
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
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                              (route) => false,
                            );
                          },
                          child: Text(
                            'Back to Login',
                            style: TextStyle(color: greySubtitle),
                          ),
                        ),
                      ],
                    ),
                    // Decorative SVG elements - collision-aware placement
                    ..._buildDecorations(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      contentWidth: (screenWidth - 2 * horizontalPadding).clamp(0, 500),
                      isMobile: isMobile,
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

class _Rect {
  final double left;
  final double top;
  final double right;
  final double bottom;

  _Rect(this.left, this.top, this.right, this.bottom);

  bool overlaps(_Rect other) {
    return left < other.right && right > other.left && top < other.bottom && bottom > other.top;
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
