import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
import 'package:flutter_svg/flutter_svg.dart'; // import svg image

// navigated pages
import 'profile.dart';
import 'math_grades.dart';
import 'env_topics.dart';
import 'results.dart';
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
                            // Top right: Profile button with initials
                            // Note: Logo is now positioned in Stack below
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
                              // Decorative stars around cards
                              ..._buildCardDecorativeElements(
                                screenWidth,
                                screenHeight,
                                isMobile,
                                useVerticalLayout,
                                useTwoColumnLayout,
                              ),
                            ],
                          );
                        },
                      ),
                      
                      SizedBox(height: 40),
                    ],
                  ),
                    // Top left logo - positioned in Stack like decorative elements
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
                    // Decorative stars and clouds around title - positioned after Column so they render on top
                    // Using screenWidth/screenHeight 
                    ..._buildDecorativeElements(screenWidth, screenHeight, isMobile),
                  ],
                ),
              ),
            ),
    );
  }

  // Build decorative stars and clouds around the title
  // Using screenWidth/screenHeight positioning like signup_screen4.dart - this is the key!
  List<Widget> _buildDecorativeElements(double screenWidth, double screenHeight, bool isMobile) {
    final elements = <Widget>[];
    
    // Clouds - positioned closer to text, wrapping around it
    // Left cloud - positioned close to "Future Mind" on the left
    elements.add(
      Positioned(
        left: screenWidth * 0.12,
        top: screenHeight * 0.28,
        child: SvgPicture.asset(
          'assets/images/cloud.svg',
          width: isMobile ? 40 : 55,
          height: isMobile ? 28 : 38,
        ),
      ),
    );
    
    // Right cloud - positioned below "Challenges" to the right, smaller size
    elements.add(
      Positioned(
        right: screenWidth * 0.15,
        top: screenHeight * 0.35,
        child: SvgPicture.asset(
          'assets/images/cloud.svg',
          width: isMobile ? 30 : 40,
          height: isMobile ? 20 : 28,
        ),
      ),
    );
    
    // Stars positioned around the title using screenWidth/screenHeight like signup_screen4.dart
    // Top row - above the text
    elements.add(
      Positioned(
        left: screenWidth * 0.15,
        top: screenHeight * 0.24,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 12.0 : 18.0,
          height: isMobile ? 11.3 : 17.0,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.25,
        top: screenHeight * 0.23,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 10.0 : 15.0,
          height: isMobile ? 9.4 : 14.2,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.45,
        top: screenHeight * 0.25,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 14.0 : 20.0,
          height: isMobile ? 13.2 : 18.9,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.55,
        top: screenHeight * 0.24,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 11.0 : 16.0,
          height: isMobile ? 10.4 : 15.1,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.70,
        top: screenHeight * 0.23,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 13.0 : 19.0,
          height: isMobile ? 12.3 : 17.9,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.80,
        top: screenHeight * 0.25,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 9.0 : 14.0,
          height: isMobile ? 8.5 : 13.2,
        ),
      ),
    );
    
    // Middle row - beside the text
    elements.add(
      Positioned(
        left: screenWidth * 0.10,
        top: screenHeight * 0.30,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 9.0 : 14.0,
          height: isMobile ? 8.5 : 13.2,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.05,
        top: screenHeight * 0.34,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 12.0 : 18.0,
          height: isMobile ? 11.3 : 17.0,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.10,
        top: screenHeight * 0.31,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 11.0 : 16.0,
          height: isMobile ? 10.4 : 15.1,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.05,
        top: screenHeight * 0.35,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 10.0 : 15.0,
          height: isMobile ? 9.4 : 14.2,
        ),
      ),
    );
    
    // Bottom row - below the text
    elements.add(
      Positioned(
        left: screenWidth * 0.18,
        top: screenHeight * 0.38,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 11.0 : 16.0,
          height: isMobile ? 10.4 : 15.1,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.35,
        top: screenHeight * 0.39,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 10.0 : 15.0,
          height: isMobile ? 9.4 : 14.2,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.50,
        top: screenHeight * 0.38,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 12.0 : 18.0,
          height: isMobile ? 11.3 : 17.0,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.65,
        top: screenHeight * 0.40,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 9.0 : 14.0,
          height: isMobile ? 8.5 : 13.2,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.78,
        top: screenHeight * 0.39,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 13.0 : 19.0,
          height: isMobile ? 12.3 : 17.9,
        ),
      ),
    );
    
    return elements;
  }
  
  // Build decorative stars around the cards section
  // Using percentage-based positioning like signup_screen4.dart
  List<Widget> _buildCardDecorativeElements(double screenWidth, double screenHeight, bool isMobile, bool useVerticalLayout, bool useTwoColumnLayout) {
    final elements = <Widget>[];
    
    // Stars around the cards using percentage-based positioning
    // Adjust positions based on layout type
    if (useVerticalLayout) {
      // For vertical layout, position stars along the sides and between cards
      // Left side stars
      elements.add(
        Positioned(
          left: screenWidth * 0.02,
          top: screenHeight * 0.45,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 10.0 : 14.0,
            height: isMobile ? 9.4 : 13.2,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          left: screenWidth * 0.01,
          top: screenHeight * 0.55,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 12.0 : 16.0,
            height: isMobile ? 11.3 : 15.1,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          left: screenWidth * 0.03,
          top: screenHeight * 0.65,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 9.0 : 13.0,
            height: isMobile ? 8.5 : 12.3,
          ),
        ),
      );
      
      // Right side stars
      elements.add(
        Positioned(
          right: screenWidth * 0.02,
          top: screenHeight * 0.47,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 10.0 : 14.0,
            height: isMobile ? 9.4 : 13.2,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          right: screenWidth * 0.01,
          top: screenHeight * 0.57,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 13.0 : 17.0,
            height: isMobile ? 12.3 : 16.0,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          right: screenWidth * 0.03,
          top: screenHeight * 0.67,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 9.0 : 13.0,
            height: isMobile ? 8.5 : 12.3,
          ),
        ),
      );
      
      // Center stars between cards
      elements.add(
        Positioned(
          left: screenWidth * 0.5,
          top: screenHeight * 0.50,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 11.0 : 15.0,
            height: isMobile ? 10.4 : 14.2,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          left: screenWidth * 0.5,
          top: screenHeight * 0.60,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 10.0 : 14.0,
            height: isMobile ? 9.4 : 13.2,
          ),
        ),
      );
    } else if (useTwoColumnLayout) {
      // Two-column layout - adjust star positions for 2 cards side by side
      // Left side stars
      elements.add(
        Positioned(
          left: screenWidth * 0.02,
          top: screenHeight * 0.42,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 10.0 : 14.0,
            height: isMobile ? 9.4 : 13.2,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          left: screenWidth * 0.01,
          top: screenHeight * 0.50,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 12.0 : 16.0,
            height: isMobile ? 11.3 : 15.1,
          ),
        ),
      );
      
      // Right side stars
      elements.add(
        Positioned(
          right: screenWidth * 0.02,
          top: screenHeight * 0.44,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 10.0 : 14.0,
            height: isMobile ? 9.4 : 13.2,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          right: screenWidth * 0.01,
          top: screenHeight * 0.52,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 13.0 : 17.0,
            height: isMobile ? 12.3 : 16.0,
          ),
        ),
      );
      
      // Center stars between the two cards
      elements.add(
        Positioned(
          left: screenWidth * 0.5,
          top: screenHeight * 0.43,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 11.0 : 15.0,
            height: isMobile ? 10.4 : 14.2,
          ),
        ),
      );
      
      // Stars around the bottom card (third card)
      elements.add(
        Positioned(
          left: screenWidth * 0.15,
          top: screenHeight * 0.62,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 10.0 : 14.0,
            height: isMobile ? 9.4 : 13.2,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          right: screenWidth * 0.15,
          top: screenHeight * 0.64,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 12.0 : 16.0,
            height: isMobile ? 11.3 : 15.1,
          ),
        ),
      );
      
      elements.add(
        Positioned(
          left: screenWidth * 0.5,
          top: screenHeight * 0.63,
          child: SvgPicture.asset(
            'assets/images/pinkstar.svg',
            width: isMobile ? 9.0 : 13.0,
            height: isMobile ? 8.5 : 12.3,
          ),
        ),
      );
    } else {
      // Three-card horizontal layout - original positioning
      // Left side stars
      elements.add(
      Positioned(
        left: screenWidth * 0.02,
        top: screenHeight * 0.40,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 10.0 : 14.0,
          height: isMobile ? 9.4 : 13.2,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.01,
        top: screenHeight * 0.48,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 12.0 : 16.0,
          height: isMobile ? 11.3 : 15.1,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.03,
        top: screenHeight * 0.56,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 9.0 : 13.0,
          height: isMobile ? 8.5 : 12.3,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.015,
        top: screenHeight * 0.64,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 11.0 : 15.0,
          height: isMobile ? 10.4 : 14.2,
        ),
      ),
    );
    
    // Right side stars
    elements.add(
      Positioned(
        right: screenWidth * 0.02,
        top: screenHeight * 0.42,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 10.0 : 14.0,
          height: isMobile ? 9.4 : 13.2,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.01,
        top: screenHeight * 0.50,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 13.0 : 17.0,
          height: isMobile ? 12.3 : 16.0,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.03,
        top: screenHeight * 0.58,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 9.0 : 13.0,
          height: isMobile ? 8.5 : 12.3,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.015,
        top: screenHeight * 0.66,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 11.0 : 15.0,
          height: isMobile ? 10.4 : 14.2,
        ),
      ),
    );
    
    // Top stars above cards
    elements.add(
      Positioned(
        left: screenWidth * 0.12,
        top: screenHeight * 0.36,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 10.0 : 14.0,
          height: isMobile ? 9.4 : 13.2,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.5,
        top: screenHeight * 0.34,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 12.0 : 16.0,
          height: isMobile ? 11.3 : 15.1,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.12,
        top: screenHeight * 0.35,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 9.0 : 13.0,
          height: isMobile ? 8.5 : 12.3,
        ),
      ),
    );
    
    // Bottom stars below cards
    elements.add(
      Positioned(
        left: screenWidth * 0.15,
        top: screenHeight * 0.72,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 11.0 : 15.0,
          height: isMobile ? 10.4 : 14.2,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        left: screenWidth * 0.5,
        top: screenHeight * 0.74,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 10.0 : 14.0,
          height: isMobile ? 9.4 : 13.2,
        ),
      ),
    );
    
    elements.add(
      Positioned(
        right: screenWidth * 0.15,
        top: screenHeight * 0.73,
        child: SvgPicture.asset(
          'assets/images/pinkstar.svg',
          width: isMobile ? 12.0 : 16.0,
          height: isMobile ? 11.3 : 15.1,
        ),
      ),
    );
    }
    
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
          child: Container(
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
