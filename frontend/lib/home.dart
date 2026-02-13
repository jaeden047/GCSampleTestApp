
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // import svg image
import 'package:frontend/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// navigated pages
import 'api_service.dart';
import 'profile.dart';
import 'math_grades.dart';
import 'env_topics.dart';
import 'results.dart';
import 'leaderboard.dart';
import 'main.dart';

// Home dashboard: Math quiz, Environmental quiz, Past Results
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? userName; // "Welcome ___", name.
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _hasCentered = false;

  @override
  void initState() { // Runs instantly
    super.initState();
    _getUserData(); 
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch user data from Supabase when Home page initializes
  Future<void> _getUserData() async {
    // We need token (for access) and field map (for UI)
    final profile = await ApiService.instance.getProfile(); 
    // Inside getProfile(), it first reads the saved token from storage
    // The returned profile is only the server’s JSON response map.
    // The token is not inside profile. It is in _storage
    final name = profile['user']?['name']?.toString();
    // If token exists in storage, the app will treat the user as logged in (or will try to).
    if (name == null){
      await ApiService.instance.clearToken();// If name is non-usable; delete the user token. Make the session invalid, and re-login
      ScaffoldMessenger.of(context).showSnackBar( 
      const SnackBar(content: Text('Session invalid. Please log in again.')),
      );
      Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
      ); 
    }
      setState(() { // Triggers rebuild with updated fields
        userName = name;
        isLoading = false;
    });
  }
  
  // Center the math card on mobile
  void _centerMathCard(BuildContext context) {
    if (!_hasCentered && _isMobile(context) && _scrollController.hasClients) {
      _hasCentered = true; // marks centering happened; prevents re-run
      // Scroll to center the math card (second card)
      final cardWidth = 280.0; // Mobile card width
      final spacing = 20.0;
      final screenWidth = MediaQuery.of(context).size.width;
      final scrollPosition = cardWidth + spacing - (screenWidth - cardWidth) / 2;
      _scrollController.animateTo(
        scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Get user initials from name; to fit in mobile
  String _getUserInitials() {
    if (userName == null || userName!.isEmpty) return 'U';
    final parts = userName!.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return userName![0].toUpperCase();
  }

  // Check if screen is mobile
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  } // If width < 768px; mobile user.

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = _isMobile(context);

    return Scaffold(
      backgroundColor: MyApp.homeLightGreyBackground,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Decorative stars and clouds — drawn first so they stay behind header and cards
                    ..._buildDecorativeElements(
                      screenWidth,
                      screenHeight,
                      isMobile,
                      MediaQuery.of(context).padding.top + 20,
                      isMobile ? (screenHeight * 1.5) : screenHeight,
                    ),
                    // Main content
                    Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top section with logo and profile button
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 20,
                          left: 20,
                          right: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top right: Leaderboard button with star icon (below profile)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Profile button with initials
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProfilePage()),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 16,
                                      vertical: isMobile ? 8 : 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: MyApp.homeWhite,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: MyApp.homeDarkGreyText,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      _getUserInitials(),
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                        color: MyApp.homeDarkGreyText,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Leaderboard button with star icon — open with default Grade 5 and 6, Sample Quiz
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Leaderboard(topicName: 'Grade 5 and 6'),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 12 : 16,
                                      vertical: isMobile ? 8 : 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: MyApp.homeWhite,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: MyApp.homeDarkGreyText,
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.star,
                                      size: isMobile ? 14 : 16,
                                      color: MyApp.homeDarkGreyText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isMobile ? 20 : 30),
                      
                      // Welcome message section - centered
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Welcome text
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        color: MyApp.homeGreyText,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      children: [
                                        TextSpan(text: 'Welcome '),
                                        TextSpan(
                                          text: userName ?? 'User',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Continue with Quiz',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                      color: MyApp.homeGreyText,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isMobile ? 8 : 12),
                              
                              // Future Mind Challenges title
                              Text(
                                'Future Mind\nChallenges',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isMobile ? 32 : 48,
                                  fontWeight: FontWeight.bold,
                                  color: MyApp.homeDarkGreyText,
                                  height: 1.1,
                                  fontFamily: 'serif',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isMobile ? 30 : 50),
                      
                      // Responsive cards section with decorative stars
                      // Smart responsive calculation: determine how many cards can fit horizontally
                      Builder(
                        builder: (context) {
                          final cardWidth = isMobile ? 280.0 : 360.0;
                          final cardSpacing = isMobile ? 20.0 : 30.0;
                          final horizontalPadding = 40.0; // Left + right padding
                          final availableWidth = screenWidth - horizontalPadding;
                          
                          // Calculate how many cards can fit
                          int cardsPerRow = 3; // Default to 3 cards
                          if (availableWidth < (cardWidth * 3) + (cardSpacing * 2)) {
                            // Can't fit 3 cards, check if we can fit 2
                            if (availableWidth >= (cardWidth * 2) + cardSpacing) {
                              cardsPerRow = 2;
                            } else {
                              // Can't even fit 2 cards, use vertical layout
                              cardsPerRow = 1;
                            }
                          }
                          
                          final useVerticalLayout = cardsPerRow == 1;
                          final useTwoColumnLayout = cardsPerRow == 2;
                          
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Card-area decorations — behind the cards
                              ..._buildCardDecorativeElements(
                                screenWidth,
                                screenHeight,
                                isMobile,
                                useVerticalLayout,
                                useTwoColumnLayout,
                              ),
                              // Cards container - smart responsive layout
                              useVerticalLayout
                                  ? // Vertical layout for very small screens
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // Environmental Quiz Card - centered
                                          Center(
                                            child: _buildQuizCard(
                                              context: context,
                                              assetPath: 'assets/images/environment_logo.svg',
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => EnvTopics()),
                                                );
                                              },
                                              isMobile: isMobile,
                                            ),
                                          ),
                                          
                                          SizedBox(height: isMobile ? 20 : 30),
                                          
                                          // Mathematics Quiz Card - centered
                                          Center(
                                            child: _buildQuizCard(
                                              context: context,
                                              assetPath: 'assets/images/math_logo.svg',
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => MathGrades()),
                                                );
                                              },
                                              isMobile: isMobile,
                                              isCenter: true,
                                            ),
                                          ),
                                          
                                          SizedBox(height: isMobile ? 20 : 30),
                                          
                                          // Results Card - centered
                                          Center(
                                            child: _buildQuizCard(
                                              context: context,
                                              assetPath: 'assets/images/results_logo.svg',
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => Results()),
                                                );
                                              },
                                              isMobile: isMobile,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : useTwoColumnLayout
                                      ? // Two-column layout for medium screens
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 20),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              // First row: 2 cards
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  // Environmental Quiz Card
                                                  _buildQuizCard(
                                                    context: context,
                                                    assetPath: 'assets/images/environment_logo.svg',
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => EnvTopics()),
                                                      );
                                                    },
                                                    isMobile: isMobile,
                                                  ),
                                                  
                                                  SizedBox(width: isMobile ? 20 : 30),
                                                  
                                                  // Mathematics Quiz Card
                                                  _buildQuizCard(
                                                    context: context,
                                                    assetPath: 'assets/images/math_logo.svg',
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => MathGrades()),
                                                      );
                                                    },
                                                    isMobile: isMobile,
                                                    isCenter: true,
                                                  ),
                                                ],
                                              ),
                                              
                                              SizedBox(height: isMobile ? 20 : 30),
                                              
                                              // Second row: 1 card (centered)
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  // Results Card
                                                  _buildQuizCard(
                                                    context: context,
                                                    assetPath: 'assets/images/results_logo.svg',
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => Results()),
                                                      );
                                                    },
                                                    isMobile: isMobile,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : // Horizontal layout for larger screens (3 cards)
                                        SizedBox(
                                          height: isMobile ? 350 : 400,
                                          child: Builder(
                                            builder: (context) {
                                              // Center math card on mobile after first build
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                _centerMathCard(context);
                                              });
                                              return ListView(
                                                controller: _scrollController,
                                                scrollDirection: Axis.horizontal,
                                                padding: EdgeInsets.only(
                                                  left: isMobile ? 20 : (screenWidth - 1200) / 2 > 0 ? (screenWidth - 1200) / 2 : 40,
                                                  right: isMobile ? 20 : (screenWidth - 1200) / 2 > 0 ? (screenWidth - 1200) / 2 : 40,
                                                ),
                                                children: [
                                                  // Environmental Quiz Card (left)
                                                  _buildQuizCard(
                                                    context: context,
                                                    assetPath: 'assets/images/environment_logo.svg',
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => EnvTopics()),
                                                      );
                                                    },
                                                    isMobile: isMobile,
                                                  ),
                                                  
                                                  SizedBox(width: isMobile ? 20 : 30),
                                                  
                                                  // Mathematics Quiz Card (center)
                                                  _buildQuizCard(
                                                    context: context,
                                                    assetPath: 'assets/images/math_logo.svg',
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => MathGrades()),
                                                      );
                                                    },
                                                    isMobile: isMobile,
                                                    isCenter: true,
                                                  ),
                                                  
                                                  SizedBox(width: isMobile ? 20 : 30),
                                                  
                                                  // Results Card (right)
                                                  _buildQuizCard(
                                                    context: context,
                                                    assetPath: 'assets/images/results_logo.svg',
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => Results()),
                                                      );
                                                    },
                                                    isMobile: isMobile,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                            ],
                          );
                        },
                      ),
                      
                      SizedBox(height: 40),
                    ],
                    ),
                    // Top left logo — on top so it stays visible
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 20,
                      left: 20,
                      child: SizedBox(
                        width: isMobile ? 40 : 50,
                        height: isMobile ? 40 : 50,
                        child: SvgPicture.asset(
                          'assets/images/grey_leaf.svg',
                          width: isMobile ? 40 : 50,
                          height: isMobile ? 40 : 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// Deterministic hash in [0, 1]. Uses large prime so consecutive indices do NOT get consecutive
  /// values — avoids straight lines. Same inputs => same output (no flicker).
  static double _scatter(int index, int seed) {
    const int prime = 7919;
    return (((index * prime + seed * 31) % 1000) / 1000.0);
  }

  /// Independent hash for X vs Y so positions fill 2D area instead of a line.
  static double _scatter2(int index, int seed) {
    const int prime = 6781;
    return (((index * prime + seed * 17) % 1000) / 1000.0);
  }

  static double _jitter(int index, int seed, double range) {
    return ((_scatter(index, seed) - 0.5) * 2.0 * range);
  }

  /// Clamp that never throws when max < min (can happen on tiny windows).
  static double _safeClamp(double value, double min, double max) {
    if (max < min) return min;
    return value.clamp(min, max).toDouble();
  }

  // Decorative stars and clouds — evenly distributed across full screen/scroll area.
  // Band-based algorithm: guarantees same density when scrolling on mobile.
  // topBoundary: grey leaf + profile button line — decorations at or below.
  List<Widget> _buildDecorativeElements(double screenWidth, double screenHeight, bool isMobile, double topBoundary, double contentHeight) {
    const double textWidthFrac = 0.32;
    const double edgeMargin = 24.0;
    final pad = isMobile ? 12.0 : 16.0;
    final centerX = screenWidth / 2;

    final usableHeight = (contentHeight - topBoundary).clamp(1.0, double.infinity);
    final textTop = topBoundary + 0.08 * usableHeight;
    final textBottom = topBoundary + 0.25 * usableHeight;
    final cardsTop = topBoundary + 0.28 * usableHeight;
    final cardsBottom = contentHeight - 0.05 * usableHeight;

    final textRect = Rect.fromLTWH(
      centerX - screenWidth * textWidthFrac / 2,
      textTop,
      screenWidth * textWidthFrac,
      textBottom - textTop,
    );
    final cardWidth = isMobile ? 260.0 : (screenWidth * 0.82).clamp(400.0, 1200.0);
    final cardsRect = Rect.fromLTWH(
      centerX - cardWidth / 2 - 12,
      cardsTop,
      cardWidth + 24,
      (cardsBottom - cardsTop).clamp(0.0, double.infinity),
    );

    bool overlapsContent(double left, double top, double w, double h) {
      final r = Rect.fromLTWH(left, top, w, h);
      return r.overlaps(textRect) || r.overlaps(cardsRect);
    }

    final textLeft = textRect.left;
    final textRight = textRect.right;
    final cardsLeft = cardsRect.left;
    final cardsRight = cardsRect.right;

    final leftStripMin = edgeMargin;
    final leftStripMax = (cardsLeft - pad).clamp(edgeMargin + 4, centerX - 4);
    final rightStripMin = (cardsRight + pad).clamp(0.0, screenWidth);
    final rightStripMax = (screenWidth - edgeMargin).clamp(4.0, screenWidth - 4);
    final gapTop = textBottom + pad;
    final gapBottom = (cardsTop - pad).clamp(gapTop, contentHeight);

    final elements = <Widget>[];

    // Minimum spacing between decorations to prevent clustering (responsive to screen size)
    final minStarSpacing = isMobile ? 14.0 : (screenWidth * 0.05).clamp(22.0, 36.0);
    final starRects = <Rect>[];

    void addStarIfSafe(double left, double top, double w, double h) {
      if (top < topBoundary) return;
      if (left < edgeMargin || left + w > screenWidth - edgeMargin) return;
      if (top + h > contentHeight - 8) return;
      if (overlapsContent(left, top, w, h)) return;
      final r = Rect.fromLTWH(left, top, w, h);
      for (final s in starRects) {
        final dx = (r.center.dx - s.center.dx).abs();
        final dy = (r.center.dy - s.center.dy).abs();
        if (dx < minStarSpacing && dy < minStarSpacing) return;
      }
      starRects.add(r);
      elements.add(
        Positioned(left: left, top: top, child: SvgPicture.asset('assets/images/pinkstar.svg', width: w, height: h)),
      );
    }

    final cloudRects = <Rect>[];
    final minCloudDx = isMobile ? 22.0 : (screenWidth * 0.18).clamp(32.0, 100.0);
    final minCloudDy = isMobile ? 18.0 : (contentHeight * 0.07).clamp(28.0, 80.0);
    bool canPlaceCloud(double left, double top, double w, double h) {
      if (top < topBoundary) return false;
      if (left < edgeMargin || left + w > screenWidth - edgeMargin) return false;
      final r = Rect.fromLTWH(left, top, w, h);
      if (overlapsContent(left, top, w, h)) return false;
      for (final c in cloudRects) {
        final dx = (r.center.dx - c.center.dx).abs();
        final dy = (r.center.dy - c.center.dy).abs();
        if (dx < minCloudDx && dy < minCloudDy) return false;
      }
      for (final s in starRects) {
        final dx = (r.center.dx - s.center.dx).abs();
        final dy = (r.center.dy - s.center.dy).abs();
        if (dx < minCloudDx * 0.8 && dy < minCloudDy * 0.8) return false;
      }
      cloudRects.add(r);
      return true;
    }

    double starW(int band, int slot) => (isMobile ? 9.0 : 12.0) + _scatter2(band * 7 + slot, 1) * (isMobile ? 5.0 : 6.0);
    double starH(double w) => w * (11.3 / 12);

    // Band-based placement: divide vertical space into bands for even density when scrolling
    // For web: scale decoration count by screen area — reduce on small screens to prevent clustering
    final numBands = isMobile ? 16 : 10;
    final bandHeight = (contentHeight - topBoundary - 24) / numBands;
    final screenArea = screenWidth * screenHeight;
    final starsPerBand = isMobile ? 2 : ((screenArea / 65000).round().clamp(1, 2));
    final totalStars = numBands * starsPerBand;

    // Web: zone widths for balanced placement (skip narrow zones)
    final leftStripWidth = (leftStripMax - leftStripMin).clamp(0.0, screenWidth);
    final rightStripWidth = (rightStripMax - rightStripMin).clamp(0.0, screenWidth);
    final gapCenterWidth = (textRight - textLeft - pad * 2).clamp(0.0, screenWidth);
    final minZoneWidth = 28.0;
    final useLeftZone = !isMobile ? leftStripWidth >= minZoneWidth : true;
    final useRightZone = !isMobile ? rightStripWidth >= minZoneWidth : true;

    for (int i = 0; i < totalStars; i++) {
      final band = i ~/ starsPerBand;
      final slot = i % starsPerBand;
      final bandTop = topBoundary + band * bandHeight + 12;
      final bandBottom = topBoundary + (band + 1) * bandHeight - 12;
      if (bandBottom <= bandTop + 8) continue;

      final w = starW(band, slot);
      final h = starH(w);
      final bandCenterY = (bandTop + bandBottom) / 2;

      // Web: balanced zones — center 60%, left 25%, right 15% (avoid right clustering)
      int hZone;
      if (isMobile) {
        hZone = (band + slot) % 3;
      } else {
        final seq = (band + slot) % 10;
        if (seq < 6) {
          hZone = 1;
        } else if (seq < 8 && useLeftZone) {
          hZone = 0;
        } else if (seq < 10 && useRightZone) {
          hZone = 2;
        } else {
          hZone = 1;
        }
      }
      double left;
      double top = bandTop + _safeClamp(
        _scatter2(i, 2) * (bandBottom - bandTop - h) + _jitter(i, 3, bandHeight * 0.3),
        0.0, bandBottom - bandTop - h,
      );

      if (hZone == 0 && useLeftZone && leftStripMax > leftStripMin + w + 4) {
        final stripW = leftStripMax - leftStripMin - w;
        left = leftStripMin + _safeClamp(
          _scatter(i, 4) * stripW + _jitter(i, 5, stripW * 0.4),
          0.0, stripW,
        );
      } else if (hZone == 1) {
        // Center zone: wrap around text and cards — gap, left/right of content
        final inGap = bandCenterY >= gapTop && bandCenterY <= gapBottom;
        final inCardBand = bandCenterY >= cardsTop && bandCenterY <= cardsBottom;
        final contentL = inCardBand ? cardsLeft : textLeft;
        final contentR = inCardBand ? cardsRight : textRight;
        final centerL = (contentL - leftStripMax - pad).clamp(0.0, screenWidth);
        final centerR = (rightStripMin - contentR - pad).clamp(0.0, screenWidth);

        if (inGap && gapCenterWidth > w + 12) {
          left = textLeft + pad + _safeClamp(
            _scatter(i, 6) * (textRight - textLeft - w - pad * 2) + _jitter(i, 7, 18),
            0.0, textRight - textLeft - w - pad * 2,
          );
        } else if (centerL > w + 8) {
          left = leftStripMax + pad + _safeClamp(
            _scatter(i, 8) * (centerL - w) + _jitter(i, 9, 14),
            0.0, centerL - w,
          );
        } else if (centerR > w + 8) {
          left = contentR + pad + _safeClamp(
            _scatter(i, 10) * (centerR - w) + _jitter(i, 11, 14),
            0.0, centerR - w,
          );
        } else if (useRightZone && rightStripMax > rightStripMin + w + 4) {
          final stripW = (rightStripMax - rightStripMin - w).clamp(0.0, screenWidth);
          left = rightStripMin + _safeClamp(_scatter(i, 12) * stripW, 0.0, stripW);
        } else if (useLeftZone && leftStripMax > leftStripMin + w + 4) {
          left = leftStripMin + _safeClamp(_scatter(i, 12) * (leftStripMax - leftStripMin - w), 0.0, leftStripMax - leftStripMin - w);
        } else {
          continue;
        }
      } else if (hZone == 2 && (useRightZone || isMobile) && rightStripMax > rightStripMin + w + 4) {
        if (rightStripMax > rightStripMin + w + 4) {
          final stripW = (rightStripMax - rightStripMin - w).clamp(0.0, screenWidth);
          left = rightStripMin + _safeClamp(
            _scatter(i, 14) * stripW + _jitter(i, 15, stripW * 0.6),
            0.0, stripW,
          );
        } else {
          // Fallback: alternate left/right when right strip too narrow
          if ((band + slot) % 2 == 0 && leftStripMax > leftStripMin + w + 4) {
            left = leftStripMin + _safeClamp(_scatter(i, 16) * (leftStripMax - leftStripMin - w), 0.0, leftStripMax - leftStripMin - w);
          } else if (rightStripMax > rightStripMin + w + 4) {
            final stripW = (rightStripMax - rightStripMin - w).clamp(0.0, screenWidth);
            left = rightStripMin + _safeClamp(_scatter(i, 17) * stripW, 0.0, stripW);
          } else {
            continue;
          }
        }
      } else {
        // Fallback: alternate left/right
        if ((band + slot) % 2 == 0 && leftStripMax > leftStripMin + w + 4) {
          left = leftStripMin + _safeClamp(_scatter(i, 16) * (leftStripMax - leftStripMin - w), 0.0, leftStripMax - leftStripMin - w);
        } else if (rightStripMax > rightStripMin + w + 4) {
          final stripW = (rightStripMax - rightStripMin - w).clamp(0.0, screenWidth);
          left = rightStripMin + _safeClamp(_scatter(i, 17) * stripW, 0.0, stripW);
        } else {
          continue;
        }
      }
      addStarIfSafe(left, top, w, h);
    }

    // Clouds: scale by screen size on web — fewer on small screens to prevent clustering
    final cloudCount = isMobile ? 16 : ((screenArea / 80000).round().clamp(3, 6));
    final cw = isMobile ? 26.0 : (screenWidth * 0.035).clamp(24.0, 36.0);
    final ch = cw * 0.68;
    for (int i = 0; i < cloudCount; i++) {
      final band = (i * numBands) ~/ cloudCount;
      final bandTop = topBoundary + band * bandHeight + 16;
      final bandBottom = topBoundary + (band + 1) * bandHeight - ch - 16;
      if (bandBottom <= bandTop) continue;

      int cloudZone;
      if (isMobile) {
        cloudZone = i % 3;
      } else {
        final seq = i % 8;
        cloudZone = seq < 4 ? 1 : (seq < 6 && useLeftZone ? 0 : (seq < 8 && useRightZone ? 2 : 1));
      }
      double left;
      double top = bandTop + _safeClamp(
        _scatter2(i + 200, 1) * (bandBottom - bandTop) + _jitter(i + 200, 2, 22),
        0.0, bandBottom - bandTop,
      );

      if (cloudZone == 0 && useLeftZone && leftStripMax > leftStripMin + cw + 8) {
        left = leftStripMin + _safeClamp(_scatter(i + 200, 3) * (leftStripMax - leftStripMin - cw) + _jitter(i + 200, 4, 18), 0.0, leftStripMax - leftStripMin - cw);
      } else if (cloudZone == 1) {
        final bandCenterY = (bandTop + bandBottom) / 2;
        final inGap = bandCenterY >= gapTop && bandCenterY <= gapBottom;
        final inCardBand = bandCenterY >= cardsTop && bandCenterY <= cardsBottom;
        final contentL = inCardBand ? cardsLeft : textLeft;
        final contentR = inCardBand ? cardsRight : textRight;
        final centerL = (contentL - leftStripMax - pad - cw).clamp(0.0, screenWidth);
        final centerR = (rightStripMin - contentR - pad - cw).clamp(0.0, screenWidth);

        if (inGap && gapCenterWidth > cw + 12) {
          left = textLeft + pad + _safeClamp(_scatter(i + 200, 5) * (textRight - textLeft - cw - pad * 2) + _jitter(i + 200, 6, 15), 0.0, textRight - textLeft - cw - pad * 2);
        } else if (centerL > cw + 8) {
          left = leftStripMax + pad + _safeClamp(_scatter(i + 200, 7) * centerL + _jitter(i + 200, 8, 12), 0.0, centerL);
        } else if (centerR > cw + 8) {
          left = contentR + pad + _safeClamp(_scatter(i + 200, 9) * centerR + _jitter(i + 200, 10, 12), 0.0, centerR);
        } else if (useRightZone && rightStripMax > rightStripMin + cw + 8) {
          final rw = (rightStripMax - rightStripMin - cw).clamp(0.0, screenWidth);
          left = rightStripMin + _safeClamp(_scatter(i + 200, 11) * rw, 0.0, rw);
        } else if (useLeftZone && leftStripMax > leftStripMin + cw + 8) {
          left = leftStripMin + _safeClamp(_scatter(i + 200, 9) * (leftStripMax - leftStripMin - cw), 0.0, leftStripMax - leftStripMin - cw);
        } else {
          continue;
        }
      } else if (cloudZone == 2 && (useRightZone || isMobile)) {
        if (rightStripMax > rightStripMin + cw + 8) {
          final rw = (rightStripMax - rightStripMin - cw).clamp(0.0, screenWidth);
          left = rightStripMin + _safeClamp(_scatter(i + 200, 10) * rw + _jitter(i + 200, 11, rw * 0.5), 0.0, rw);
        } else {
          if ((i % 2 == 0) && rightStripMax > rightStripMin + cw + 8) {
            final rw = (rightStripMax - rightStripMin - cw).clamp(0.0, screenWidth);
            left = rightStripMin + _safeClamp(_scatter(i + 200, 10) * rw, 0.0, rw);
          } else if (leftStripMax > leftStripMin + cw + 8) {
            left = leftStripMin + _safeClamp(_scatter(i + 200, 9) * (leftStripMax - leftStripMin - cw), 0.0, leftStripMax - leftStripMin - cw);
          } else {
            continue;
          }
        }
      } else {
        if ((i % 2 == 0) && rightStripMax > rightStripMin + cw + 8) {
          final rw = (rightStripMax - rightStripMin - cw).clamp(0.0, screenWidth);
          left = rightStripMin + _safeClamp(_scatter(i + 200, 10) * rw, 0.0, rw);
        } else if (leftStripMax > leftStripMin + cw + 8) {
          left = leftStripMin + _safeClamp(_scatter(i + 200, 9) * (leftStripMax - leftStripMin - cw), 0.0, leftStripMax - leftStripMin - cw);
        } else {
          continue;
        }
      }
      if (!canPlaceCloud(left, top, cw, ch)) continue;
      elements.add(Positioned(left: left, top: top, child: SvgPicture.asset('assets/images/cloud.svg', width: cw, height: ch)));
    }

    return elements;
  }
  
  /// Add scattered stars/clouds in strips around the card area. X and Y use independent hashes so no lines.
  void _addScatteredCardDecorations(
    List<Widget> elements,
    double screenWidth,
    double screenHeight,
    bool isMobile,
    double cardAreaLeft,
    double cardAreaRight,
    double cardAreaTop,
    double cardAreaBottom,
    int seedOffset,
  ) {
    const double margin = 20.0;
    final jitter = isMobile ? 28.0 : 38.0;
    final leftStripMax = (cardAreaLeft - margin).clamp(0.0, screenWidth * 0.5);
    final rightStripWidth = (screenWidth - cardAreaRight - margin).clamp(0.0, screenWidth);
    final topStripMax = (cardAreaTop - margin).clamp(0.0, screenHeight * 0.5);
    final bottomStripMin = (cardAreaBottom + margin).clamp(0.0, screenHeight);

    // Left strip: very light scatter (natural look)
    if (leftStripMax > 30) {
      for (int i = 0; i < 2; i++) {
        final leftMax = leftStripMax - 18;
        final left = _safeClamp(
          (_scatter(i + seedOffset, 1) * (leftStripMax - 16) + _jitter(i + seedOffset, 3, 14)),
          0.0,
          leftMax,
        );
        final top = _safeClamp(
          (_scatter2(i + seedOffset, 2) * (screenHeight - 25) + _jitter(i + seedOffset, 4, jitter)),
          0.0,
          (screenHeight - 25),
        );
        final w = (isMobile ? 9.0 : 12.0) + _scatter2(i + seedOffset, 5) * (isMobile ? 5.0 : 6.0);
        final h = w * (11.3 / 12);
        elements.add(
          Positioned(left: left, top: top, child: SvgPicture.asset('assets/images/pinkstar.svg', width: w, height: h)),
        );
      }
      for (int i = 0; i < 2; i++) {
        final leftMax = leftStripMax - 55;
        if (leftMax <= 0) continue;
        final left = _safeClamp(
          (_scatter(i + seedOffset + 10, 1) * (leftStripMax - 50) + _jitter(i + seedOffset + 10, 3, 18)),
          0.0,
          leftMax,
        );
        final top = _safeClamp(
          (_scatter2(i + seedOffset + 10, 2) * (screenHeight - 45) + _jitter(i + seedOffset + 10, 4, jitter)),
          0.0,
          (screenHeight - 45),
        );
        final cw = isMobile ? 26.0 : 36.0;
        final ch = isMobile ? 18.0 : 24.0;
        elements.add(
          Positioned(left: left, top: top, child: SvgPicture.asset('assets/images/cloud.svg', width: cw, height: ch)),
        );
      }
    }
    // Right strip: very light scatter
    if (rightStripWidth > 30) {
      for (int i = 0; i < 2; i++) {
        final rightMax = rightStripWidth - 18;
        final right = _safeClamp(
          (_scatter(i + seedOffset + 20, 1) * (rightStripWidth - 16) + _jitter(i + seedOffset + 20, 3, 14)),
          0.0,
          rightMax,
        );
        final top = _safeClamp(
          (_scatter2(i + seedOffset + 20, 2) * (screenHeight - 25) + _jitter(i + seedOffset + 20, 4, jitter)),
          0.0,
          (screenHeight - 25),
        );
        final w = (isMobile ? 9.0 : 12.0) + _scatter2(i + seedOffset + 20, 5) * (isMobile ? 5.0 : 6.0);
        final h = w * (11.3 / 12);
        elements.add(
          Positioned(right: right, top: top, child: SvgPicture.asset('assets/images/pinkstar.svg', width: w, height: h)),
        );
      }
      for (int i = 0; i < 2; i++) {
        final rightMax = rightStripWidth - 60;
        if (rightMax <= 0) continue;
        final right = _safeClamp(
          (_scatter(i + seedOffset + 30, 1) * (rightStripWidth - 55) + _jitter(i + seedOffset + 30, 3, 18)),
          0.0,
          rightMax,
        );
        final top = _safeClamp(
          (_scatter2(i + seedOffset + 30, 2) * (screenHeight - 45) + _jitter(i + seedOffset + 30, 4, jitter)),
          0.0,
          (screenHeight - 45),
        );
        final cw = isMobile ? 24.0 : 34.0;
        final ch = isMobile ? 16.0 : 22.0;
        elements.add(
          Positioned(right: right, top: top, child: SvgPicture.asset('assets/images/cloud.svg', width: cw, height: ch)),
        );
      }
    }
    // Top strip (above cards)
    if (topStripMax > 28) {
      for (int i = 0; i < 2; i++) {
        final left = _safeClamp(
          (_scatter(i + seedOffset + 40, 1) * (screenWidth - 24) + _jitter(i + seedOffset + 40, 2, jitter)),
          0.0,
          (screenWidth - 22),
        );
        final top = _safeClamp(
          (_scatter2(i + seedOffset + 40, 3) * (topStripMax - 18) + _jitter(i + seedOffset + 40, 4, 14)),
          0.0,
          (topStripMax - 20),
        );
        final w = (isMobile ? 9.0 : 12.0) + _scatter(i + seedOffset + 40, 5) * (isMobile ? 4.0 : 5.0);
        final h = w * (11.3 / 12);
        elements.add(
          Positioned(left: left, top: top, child: SvgPicture.asset('assets/images/pinkstar.svg', width: w, height: h)),
        );
      }
    }
    // Bottom strip (below cards)
    if (screenHeight - bottomStripMin > 28) {
      final bottomHeight = screenHeight - bottomStripMin - 22;
      for (int i = 0; i < 2; i++) {
        final left = _safeClamp(
          (_scatter(i + seedOffset + 50, 1) * (screenWidth - 24) + _jitter(i + seedOffset + 50, 2, jitter)),
          0.0,
          (screenWidth - 22),
        );
        final top = _safeClamp(
          (bottomStripMin + _scatter2(i + seedOffset + 50, 3) * bottomHeight + _jitter(i + seedOffset + 50, 4, 14)),
          bottomStripMin,
          (screenHeight - 20),
        );
        final w = (isMobile ? 9.0 : 12.0) + _scatter(i + seedOffset + 50, 5) * (isMobile ? 4.0 : 5.0);
        final h = w * (11.3 / 12);
        elements.add(
          Positioned(left: left, top: top, child: SvgPicture.asset('assets/images/pinkstar.svg', width: w, height: h)),
        );
      }
    }
  }

  // Build decorative stars around the cards section — scattered, never covering the 3 quiz cards.
  List<Widget> _buildCardDecorativeElements(double screenWidth, double screenHeight, bool isMobile, bool useVerticalLayout, bool useTwoColumnLayout) {
    final elements = <Widget>[];
    final centerX = screenWidth / 2;
    final cardWidth = isMobile ? 280.0 : 360.0;
    final cardHeight = isMobile ? 320.0 : 380.0;
    final cardSpacing = isMobile ? 20.0 : 30.0;
    
    double cardAreaLeft, cardAreaRight;
    double cardAreaTopPercent, cardAreaBottomPercent;
    
    if (useVerticalLayout) {
      cardAreaLeft = centerX - cardWidth / 2 - 20;
      cardAreaRight = centerX + cardWidth / 2 + 20;
      cardAreaTopPercent = 0.45;
      cardAreaBottomPercent = 0.45 + ((cardHeight * 3) + (cardSpacing * 2) + 40) / screenHeight;
    } else if (useTwoColumnLayout) {
      final twoCardWidth = (cardWidth * 2) + cardSpacing;
      cardAreaLeft = centerX - twoCardWidth / 2 - 20;
      cardAreaRight = centerX + twoCardWidth / 2 + 20;
      cardAreaTopPercent = 0.45;
      cardAreaBottomPercent = 0.45 + ((cardHeight * 2) + cardSpacing + 40) / screenHeight;
    } else {
      final threeCardWidth = (cardWidth * 3) + (cardSpacing * 2);
      cardAreaLeft = centerX - threeCardWidth / 2 - 40;
      cardAreaRight = centerX + threeCardWidth / 2 + 40;
      cardAreaTopPercent = 0.45;
      cardAreaBottomPercent = 0.45 + (cardHeight + 40) / screenHeight;
    }
    
    final cardAreaTop = cardAreaTopPercent * screenHeight;
    final cardAreaBottom = cardAreaBottomPercent * screenHeight;
    final seedOffset = useVerticalLayout ? 100 : (useTwoColumnLayout ? 200 : 300);
    
    _addScatteredCardDecorations(
      elements,
      screenWidth,
      screenHeight,
      isMobile,
      cardAreaLeft,
      cardAreaRight,
      cardAreaTop,
      cardAreaBottom,
      seedOffset,
    );
    
    return elements;
  }

  // Build individual quiz card with hover effect
  Widget _buildQuizCard({
    required BuildContext context,
    required String assetPath,
    required VoidCallback onTap,
    required bool isMobile,
    bool isCenter = false,
  }) {
    return _HoverableCard(
      assetPath: assetPath,
      onTap: onTap,
      isMobile: isMobile,
    );
  }
}

// Separate StatefulWidget for hoverable card
class _HoverableCard extends StatefulWidget {
  final String assetPath;
  final VoidCallback onTap;
  final bool isMobile;

  const _HoverableCard({
    required this.assetPath,
    required this.onTap,
    required this.isMobile,
  });

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.05 : 1.0),
          child: SizedBox(
            width: widget.isMobile ? 280 : 360,
            height: widget.isMobile ? 320 : 380,
            child: Opacity(
              opacity: _isHovered ? 0.9 : 1.0,
              child: SvgPicture.asset(
                widget.assetPath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}