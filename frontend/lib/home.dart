
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
import 'package:flutter_svg/flutter_svg.dart'; // import svg image

// navigated pages
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
  String? userName;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _hasCentered = false;

  @override
  void initState() {
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
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('name')
            .eq('id', user.id)
            .single();

        if (response['name'] != null) {
          setState(() {
            userName = response['name'];
          });
        }
      } catch (e) {
        // Handle error if fetching profile fails
        // print("Error fetching user data: $e");
      }
    }
    
    // Stop loading indicator once data is fetched
    setState(() {
      isLoading = false;
    });
  }
  
  // Center the math card on mobile
  void _centerMathCard(BuildContext context) {
    if (!_hasCentered && _isMobile(context) && _scrollController.hasClients) {
      _hasCentered = true;
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

  // Get user initials from name
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
  }

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
                    ..._buildDecorativeElements(screenWidth, screenHeight, isMobile),
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

  // Decorative stars and clouds — scattered across screen, wrapping around content; never cover text or cards.
  List<Widget> _buildDecorativeElements(double screenWidth, double screenHeight, bool isMobile) {
    const double marginFrac = 0.09;
    const double cardsTopFrac = 0.40;
    const double cardsBottomFrac = 0.88;
    // Very tight text rect — hugs "Welcome" / "Continue with Quiz" / "Future Mind Challenges" so stars fill the gap around them
    const double textWidthFrac = 0.32;
    const double textTopFrac = 0.13;
    const double textBottomFrac = 0.30;

    final textRect = Rect.fromLTWH(
      screenWidth * (1 - textWidthFrac) / 2,
      screenHeight * textTopFrac,
      screenWidth * textWidthFrac,
      screenHeight * (textBottomFrac - textTopFrac),
    );
    final cardsRect = Rect.fromLTWH(
      screenWidth * marginFrac,
      screenHeight * cardsTopFrac,
      screenWidth * (1 - marginFrac * 2),
      screenHeight * (cardsBottomFrac - cardsTopFrac),
    );

    // Forbid only the actual content: center text block and card area. Rest of screen is free.
    bool overlapsContent(double left, double top, double w, double h) {
      final r = Rect.fromLTWH(left, top, w, h);
      return r.overlaps(textRect) || r.overlaps(cardsRect);
    }

    final textLeft = textRect.left;
    final textRight = textRect.right;
    final textTop = textRect.top;
    final textBottom = textRect.bottom;
    final cardsLeft = cardsRect.left;
    final cardsRight = cardsRect.right;
    final cardsTop = cardsRect.top;
    final cardsBottom = cardsRect.bottom;

    final elements = <Widget>[];
    final pad = isMobile ? 8.0 : 12.0;
    // Larger jitter so stars are scattered and even, not clustered (ref: second image)
    final jitterPx = isMobile ? 52.0 : 68.0;

    void addStarIfSafe(double left, double top, double w, double h) {
      if (overlapsContent(left, top, w, h)) return;
      elements.add(
        Positioned(left: left, top: top, child: SvgPicture.asset('assets/images/pinkstar.svg', width: w, height: h)),
      );
    }

    // Clouds: spread across screen (same zones as stars), never on text or cards; keep distance from each other.
    final cloudRects = <Rect>[];
    final minCloudDx = screenWidth * 0.28;
    final minCloudDy = screenHeight * 0.24;
    bool canPlaceCloud(double left, double top, double w, double h) {
      final r = Rect.fromLTWH(left, top, w, h);
      if (overlapsContent(left, top, w, h)) return false;
      for (final c in cloudRects) {
        final dx = (r.center.dx - c.center.dx).abs();
        final dy = (r.center.dy - c.center.dy).abs();
        if (dx < minCloudDx && dy < minCloudDy) return false;
      }
      cloudRects.add(r);
      return true;
    }

    // ---- Stars: scattered across full screen, wrapping around content (no overlap with text or cards) ----
    // Star size; responsive
    double starW(int i, int s) => (isMobile ? 9.0 : 12.0) + _scatter2(i, s) * (isMobile ? 5.0 : 6.0);
    double starH(double w) => w * (11.3 / 12);

    // Zone 1: Top band — fewer stars, more scattered (natural look)
    final topBandBottom = (textTop - pad - 6).clamp(0.0, screenHeight);
    if (topBandBottom > 12) {
      final nTop = isMobile ? 3 : 4;
      for (int i = 0; i < nTop; i++) {
        final w = starW(i, 1);
        final h = starH(w);
        final left = _safeClamp(_scatter(i, 2) * (screenWidth - w - 4) + _jitter(i, 3, jitterPx), 0.0, screenWidth - w - 4);
        final top = _safeClamp(_scatter2(i, 4) * (topBandBottom - h) + _jitter(i, 5, jitterPx * 0.6), 0.0, topBandBottom - h);
        addStarIfSafe(left, top, w, h);
      }
    }

    // Zone 1b: Header frame — a few stars just above and just below "Future Mind Challenges" (closer to title, scattered)
    const double headerFramePad = 4.0;
    final justAboveTop = (textTop - 28).clamp(0.0, screenHeight);
    final justAboveBottom = (textTop - headerFramePad - 6).clamp(0.0, screenHeight);
    if (justAboveBottom > justAboveTop + 8) {
      final nFrame = isMobile ? 2 : 3;
      for (int i = 0; i < nFrame; i++) {
        final w = starW(i + 80, 1);
        final h = starH(w);
        final left = _safeClamp(_scatter(i + 80, 2) * (screenWidth - w - 4) + _jitter(i + 80, 3, jitterPx * 0.8), 0.0, screenWidth - w - 4);
        final top = _safeClamp(justAboveTop + _scatter2(i + 80, 4) * (justAboveBottom - justAboveTop - h) + _jitter(i + 80, 5, 10), justAboveTop, justAboveBottom - h);
        addStarIfSafe(left, top, w, h);
      }
    }
    final justBelowTop = (textBottom + headerFramePad).clamp(0.0, screenHeight);
    final justBelowBottom = (textBottom + 32).clamp(0.0, screenHeight);
    if (justBelowBottom > justBelowTop + 8) {
      final nFrame = isMobile ? 2 : 3;
      for (int i = 0; i < nFrame; i++) {
        final w = starW(i + 85, 1);
        final h = starH(w);
        final left = _safeClamp(_scatter(i + 85, 2) * (screenWidth - w - 4) + _jitter(i + 85, 3, jitterPx * 0.8), 0.0, screenWidth - w - 4);
        final top = _safeClamp(justBelowTop + _scatter2(i + 85, 4) * (justBelowBottom - justBelowTop - h) + _jitter(i + 85, 5, 10), justBelowTop, justBelowBottom - h);
        addStarIfSafe(left, top, w, h);
      }
    }

    // Zone 2: Beside header (left/right of "Future Mind Challenges") — few stars, well scattered
    final leftOfTextMax = (textLeft - pad - 6).clamp(0.0, screenWidth);
    final rightOfTextMin = (textRight + pad).clamp(0.0, screenWidth);
    if (leftOfTextMax > 10) {
      final nSide = isMobile ? 2 : 3;
      for (int i = 0; i < nSide; i++) {
        final w = starW(i + 20, 1);
        final h = starH(w);
        final left = _safeClamp(_scatter(i + 20, 2) * leftOfTextMax + _jitter(i + 20, 3, jitterPx * 0.7), 0.0, leftOfTextMax);
        final top = _safeClamp(textTop + _scatter2(i + 20, 4) * (textRect.height - h) + _jitter(i + 20, 5, jitterPx * 0.4), textTop, textBottom - h);
        addStarIfSafe(left, top, w, h);
      }
    }
    if (screenWidth - rightOfTextMin > 10) {
      final nSide = isMobile ? 2 : 3;
      for (int i = 0; i < nSide; i++) {
        final w = starW(i + 30, 1);
        final h = starH(w);
        final rightSpace = (screenWidth - rightOfTextMin - w).clamp(0.0, screenWidth);
        final left = screenWidth - rightSpace - w + _safeClamp(_scatter(i + 30, 2) * (rightSpace - 2) + _jitter(i + 30, 3, jitterPx * 0.7), 0.0, rightSpace - 2);
        final top = _safeClamp(textTop + _scatter2(i + 30, 4) * (textRect.height - h) + _jitter(i + 30, 5, jitterPx * 0.4), textTop, textBottom - h);
        addStarIfSafe(left, top, w, h);
      }
    }

    // Zone 3: Gap between header and cards — fewer stars, even spread
    final gapTop = (textBottom + pad).clamp(0.0, screenHeight);
    final gapBottom = (cardsTop - pad - 6).clamp(0.0, screenHeight);
    if (gapBottom > gapTop + 12) {
      final nGap = isMobile ? 2 : 3;
      for (int i = 0; i < nGap; i++) {
        final w = starW(i + 40, 1);
        final h = starH(w);
        final left = _safeClamp(_scatter(i + 40, 2) * (screenWidth - w - 4) + _jitter(i + 40, 3, jitterPx), 0.0, screenWidth - w - 4);
        final top = _safeClamp(gapTop + _scatter2(i + 40, 4) * (gapBottom - gapTop - h) + _jitter(i + 40, 5, jitterPx * 0.5), gapTop, gapBottom - h);
        addStarIfSafe(left, top, w, h);
      }
    }

    // Zone 4: Beside cards — fewer stars, scattered
    final leftOfCardsMax = (cardsLeft - pad - 6).clamp(0.0, screenWidth);
    final rightOfCardsMin = (cardsRight + pad).clamp(0.0, screenWidth);
    if (leftOfCardsMax > 10) {
      final nSide = isMobile ? 2 : 3;
      for (int i = 0; i < nSide; i++) {
        final w = starW(i + 50, 1);
        final h = starH(w);
        final left = _safeClamp(_scatter(i + 50, 2) * leftOfCardsMax + _jitter(i + 50, 3, jitterPx * 0.7), 0.0, leftOfCardsMax);
        final top = _safeClamp(cardsTop + _scatter2(i + 50, 4) * (cardsRect.height - h) + _jitter(i + 50, 5, jitterPx * 0.5), cardsTop, cardsBottom - h);
        addStarIfSafe(left, top, w, h);
      }
    }
    if (screenWidth - rightOfCardsMin > 10) {
      final nSide = isMobile ? 2 : 3;
      for (int i = 0; i < nSide; i++) {
        final w = starW(i + 60, 1);
        final h = starH(w);
        final rightSpace = (screenWidth - rightOfCardsMin - w).clamp(0.0, screenWidth);
        final left = screenWidth - rightSpace - w + _safeClamp(_scatter(i + 60, 2) * (rightSpace - 2) + _jitter(i + 60, 3, jitterPx * 0.7), 0.0, rightSpace - 2);
        final top = _safeClamp(cardsTop + _scatter2(i + 60, 4) * (cardsRect.height - h) + _jitter(i + 60, 5, jitterPx * 0.5), cardsTop, cardsBottom - h);
        addStarIfSafe(left, top, w, h);
      }
    }

    // Zone 5: Bottom band — fewer stars, even spread
    final bottomBandTop = (cardsBottom + pad).clamp(0.0, screenHeight);
    final bottomBandBottom = (screenHeight - 16).clamp(0.0, screenHeight);
    if (bottomBandBottom > bottomBandTop + 12) {
      final nBottom = isMobile ? 4 : 5;
      for (int i = 0; i < nBottom; i++) {
        final w = starW(i + 70, 1);
        final h = starH(w);
        final left = _safeClamp(_scatter(i + 70, 2) * (screenWidth - w - 4) + _jitter(i + 70, 3, jitterPx), 0.0, screenWidth - w - 4);
        final top = _safeClamp(bottomBandTop + _scatter2(i + 70, 4) * (bottomBandBottom - bottomBandTop - h) + _jitter(i + 70, 5, jitterPx * 0.6), bottomBandTop, bottomBandBottom - h);
        addStarIfSafe(left, top, w, h);
      }
    }

    // Clouds: spread across same zones as stars (top full width, beside header, gap, beside cards, bottom full width).
    final cloudCount = isMobile ? 5 : 6;
    final cw = isMobile ? 26.0 : 32.0;
    final ch = cw * 0.68;
    for (int i = 0; i < cloudCount; i++) {
      double left;
      double top;
      final zone = i % cloudCount;
      if (zone == 0) {
        // Top band (full width)
        final topBandB = (textTop - pad - ch).clamp(0.0, screenHeight);
        if (topBandB > ch + 4) {
          left = _safeClamp(_scatter(i + 120, 1) * (screenWidth - cw - 8) + _jitter(i + 120, 2, 20), 0.0, screenWidth - cw - 8);
          top = _safeClamp(_scatter2(i + 120, 3) * (topBandB - ch) + _jitter(i + 120, 4, 8), 0.0, topBandB - ch);
        } else { continue; }
      } else if (zone == 1) {
        // Beside header (left)
        final leftMax = (textLeft - pad - cw).clamp(0.0, screenWidth);
        if (leftMax <= 0) continue;
        left = _safeClamp(_scatter(i + 120, 5) * leftMax + _jitter(i + 120, 6, 12), 0.0, leftMax);
        top = _safeClamp(textTop + _scatter2(i + 120, 7) * (textRect.height - ch) + _jitter(i + 120, 8, 6), textTop, textBottom - ch);
      } else if (zone == 2) {
        // Gap between header and cards (full width)
        final gTop = (textBottom + pad).clamp(0.0, screenHeight);
        final gBottom = (cardsTop - pad - ch).clamp(0.0, screenHeight);
        if (gBottom <= gTop + ch) continue;
        left = _safeClamp(_scatter(i + 120, 9) * (screenWidth - cw - 8) + _jitter(i + 120, 10, 24), 0.0, screenWidth - cw - 8);
        top = _safeClamp(gTop + _scatter2(i + 120, 11) * (gBottom - gTop - ch) + _jitter(i + 120, 12, 6), gTop, gBottom - ch);
      } else if (zone == 3) {
        // Beside cards (right)
        final rightSpace = (screenWidth - cardsRight - pad - cw).clamp(0.0, screenWidth);
        if (rightSpace <= 0) continue;
        left = screenWidth - rightSpace - cw + _safeClamp(_scatter(i + 120, 13) * (rightSpace - 4) + _jitter(i + 120, 14, 12), 0.0, rightSpace - 4);
        top = _safeClamp(cardsTop + _scatter2(i + 120, 15) * (cardsRect.height - ch) + _jitter(i + 120, 16, 6), cardsTop, cardsBottom - ch);
      } else {
        // Bottom band (full width)
        final botTop = (cardsBottom + pad).clamp(0.0, screenHeight);
        final botBottom = (screenHeight - ch - 8).clamp(0.0, screenHeight);
        if (botBottom <= botTop + ch) continue;
        left = _safeClamp(_scatter(i + 120, 17) * (screenWidth - cw - 8) + _jitter(i + 120, 18, 24), 0.0, screenWidth - cw - 8);
        top = _safeClamp(botTop + _scatter2(i + 120, 19) * (botBottom - botTop - ch) + _jitter(i + 120, 20, 8), botTop, botBottom - ch);
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
