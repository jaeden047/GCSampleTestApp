import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'api_service.dart';
import 'login.dart';
import 'main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  String name = '';
  String email = '';
  String phone = '';
  String school = '';
  String country = '';
  String gender = '';
  String address = '';
  
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final schoolController = TextEditingController();
  final countryController = TextEditingController();
  final genderController = TextEditingController();
  final addressController = TextEditingController();
  
  bool isLoading = true;

  // Check if screen is mobile
  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    schoolController.dispose();
    countryController.dispose();
    genderController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // Function to fetch user profile data
  Future<void> fetchUserProfile() async {
    Map<String, dynamic>? profile = await getUserProfile();
    if (profile != null) {
      setState(() {
        name = profile['name'] ?? '';
        email = profile['email'] ?? '';
        phone = profile['phone_number'] ?? '';
        school = profile['school'] ?? '';
        country = profile['country'] ?? '';
        gender = profile['gender'] ?? '';
        address = profile['address'] ?? '';
        
        nameController.text = name;
        phoneController.text = phone;
        schoolController.text = school;
        countryController.text = country;
        genderController.text = gender;
        addressController.text = address;
        
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to get user profile from Supabase
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await supabase
            .from('profiles')
            .select('name, email, phone_number, school, country, gender, address')
            .eq('id', user.id)
            .single();
        return response;
      } catch (e) {
        // If some fields don't exist in database, return what we can get
        try {
          final response = await supabase
              .from('profiles')
              .select('name, email, phone_number, school, country')
              .eq('id', user.id)
              .single();
          return response;
        } catch (e2) {
          return null;
        }
      }
    }
    return null;
  }

  // Function to update the user profile information
  Future<void> updateUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final phone = phoneController.text.trim();
    final school = schoolController.text.trim();
    final country = countryController.text.trim();
    final gender = genderController.text.trim();
    final address = addressController.text.trim();
    final name = nameController.text.trim();

    try {
      // Build update map with only non-empty fields
      final updateData = <String, dynamic>{};
      if (name.isNotEmpty) updateData['name'] = name;
      if (phone.isNotEmpty) updateData['phone_number'] = phone;
      if (school.isNotEmpty) updateData['school'] = school;
      if (country.isNotEmpty) updateData['country'] = country;
      if (gender.isNotEmpty) updateData['gender'] = gender;
      if (address.isNotEmpty) updateData['address'] = address;

      await supabase.from('profiles').update(updateData).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: MyApp.homeTealGreen,
          ),
        );
        // Refresh profile data
        fetchUserProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Function to sign out
  Future<void> signOut() async {
    await supabase.auth.signOut();
    await ApiService.instance.clearToken(); // clears API token
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var tween = Tween(begin: 0.0, end: 1.0);
            var opacityAnimation = animation.drive(tween);
            return FadeTransition(opacity: opacityAnimation, child: child);
          },
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) {
      return Scaffold(
        backgroundColor: MyApp.homeTealGreen,
        appBar: AppBar(
          backgroundColor: MyApp.homeTealGreen,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: MyApp.homeWhite),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: MyApp.homeWhite,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: MyApp.homeTealGreen,
      appBar: AppBar(
        backgroundColor: MyApp.homeTealGreen,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyApp.homeWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final estimatedContentHeight = 600.0;
          final actualContentHeight = estimatedContentHeight > screenHeight 
              ? estimatedContentHeight 
              : screenHeight;

          return SingleChildScrollView(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Decorative elements
                ..._buildDecorativeElements(screenWidth, actualContentHeight, isMobile),
                // Main content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16.0 : 24.0,
                    vertical: isMobile ? 16.0 : 24.0,
                  ),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? double.infinity : 800,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16 : 20,
                              vertical: isMobile ? 12 : 16,
                            ),
                            margin: EdgeInsets.only(bottom: isMobile ? 16 : 20),
                            decoration: BoxDecoration(
                              color: MyApp.homeLightPink,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'User Profile',
                              style: TextStyle(
                                fontSize: isMobile ? 24 : 32,
                                fontWeight: FontWeight.bold,
                                color: MyApp.homeDarkGreyText,
                                fontFamily: 'serif',
                              ),
                            ),
                          ),
                          
                          // Profile info card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isMobile ? 16 : 20),
                            margin: EdgeInsets.only(bottom: isMobile ? 16 : 20),
                            decoration: BoxDecoration(
                              color: MyApp.homeWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: MyApp.homeDarkGreyText.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name
                                TextField(
                                  controller: nameController,
                                  style: TextStyle(
                                    fontSize: isMobile ? 18 : 22,
                                    fontWeight: FontWeight.bold,
                                    color: MyApp.homeDarkGreyText,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    labelStyle: TextStyle(
                                      color: MyApp.homeGreyText,
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: MyApp.homeDarkGreyText.withOpacity(0.3),
                                      ),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: MyApp.homeTealGreen,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Email (read-only)
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    color: MyApp.homeGreyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Personal Info section
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isMobile ? 16 : 20),
                            margin: EdgeInsets.only(bottom: isMobile ? 16 : 20),
                            decoration: BoxDecoration(
                              color: MyApp.homeWhite,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: MyApp.homeDarkGreyText.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    fontSize: isMobile ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                    color: MyApp.homeDarkGreyText,
                                    fontFamily: 'serif',
                                  ),
                                ),
                                SizedBox(height: isMobile ? 16 : 20),
                                _buildTextField(
                                  controller: phoneController,
                                  label: 'Phone',
                                  isMobile: isMobile,
                                ),
                                SizedBox(height: isMobile ? 16 : 20),
                                _buildTextField(
                                  controller: genderController,
                                  label: 'Gender',
                                  isMobile: isMobile,
                                ),
                                SizedBox(height: isMobile ? 16 : 20),
                                _buildTextField(
                                  controller: addressController,
                                  label: 'Address',
                                  isMobile: isMobile,
                                  maxLines: 2,
                                ),
                                SizedBox(height: isMobile ? 16 : 20),
                                _buildTextField(
                                  controller: schoolController,
                                  label: 'School',
                                  isMobile: isMobile,
                                ),
                                SizedBox(height: isMobile ? 16 : 20),
                                _buildTextField(
                                  controller: countryController,
                                  label: 'Country',
                                  isMobile: isMobile,
                                ),
                              ],
                            ),
                          ),
                          
                          // Action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: updateUserProfile,
                                child: SvgPicture.asset(
                                  'assets/images/update_button.svg',
                                  width: isMobile ? 120 : 150,
                                ),
                              ),
                              SizedBox(width: isMobile ? 16 : 24),
                              GestureDetector(
                                onTap: signOut,
                                child: SvgPicture.asset(
                                  'assets/images/signout_button3.svg',
                                  width: isMobile ? 120 : 150,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: isMobile ? 20 : 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isMobile,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: isMobile ? 14 : 16,
        color: MyApp.homeDarkGreyText,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: MyApp.homeGreyText,
          fontSize: isMobile ? 14 : 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: MyApp.homeDarkGreyText.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: MyApp.homeTealGreen,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: MyApp.homeLightGreyBackground,
      ),
    );
  }

  // Build decorative clouds and stars dynamically distributed along content height
  List<Widget> _buildDecorativeElements(
    double screenWidth,
    double contentHeight,
    bool isMobile,
  ) {
    final elements = <Widget>[];
    final centerX = screenWidth / 2;
    final containerHalfWidth = 400; // Half of maxWidth 800
    final leftBoundary = centerX - containerHalfWidth;
    final rightBoundary = centerX + containerHalfWidth;

    // Calculate safe zones for decorations (outside the centered container)
    final leftZone = leftBoundary - 100;
    final rightZone = screenWidth - rightBoundary - 100;

    // Calculate spacing between decorations
    final minSpacing = isMobile ? 60.0 : 80.0;
    final numDecorationRows = (contentHeight / minSpacing).ceil();

    // Top padding to start decorations below the header
    final topPadding = 100.0;
    final bottomPadding = 50.0;
    final usableHeight = contentHeight - topPadding - bottomPadding;
    final adjustedSpacing = usableHeight / (numDecorationRows + 1);

    // Star sizes
    final starSizes = [
      {'w': isMobile ? 9.0 : 14.0, 'h': isMobile ? 8.5 : 13.2},
      {'w': isMobile ? 10.0 : 15.0, 'h': isMobile ? 9.4 : 14.2},
      {'w': isMobile ? 11.0 : 16.0, 'h': isMobile ? 10.4 : 15.1},
      {'w': isMobile ? 12.0 : 17.0, 'h': isMobile ? 11.3 : 16.0},
      {'w': isMobile ? 13.0 : 18.0, 'h': isMobile ? 12.3 : 17.0},
      {'w': isMobile ? 14.0 : 20.0, 'h': isMobile ? 13.2 : 18.9},
    ];

    // Cloud sizes
    final cloudSizes = [
      {'w': isMobile ? 28 : 40, 'h': isMobile ? 19 : 27},
      {'w': isMobile ? 30 : 42, 'h': isMobile ? 20 : 28},
      {'w': isMobile ? 32 : 45, 'h': isMobile ? 22 : 31},
      {'w': isMobile ? 35 : 48, 'h': isMobile ? 24 : 33},
      {'w': isMobile ? 38 : 52, 'h': isMobile ? 26 : 36},
      {'w': isMobile ? 40 : 55, 'h': isMobile ? 28 : 38},
    ];

    // Left and right positions
    final leftPositions = [0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08];
    final rightPositions = [0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08];

    // Track used positions
    final usedPositionsLeft = <double>[];
    final usedPositionsRight = <double>[];
    final minDistanceBetween = 40.0;

    // Generate decorations dynamically
    for (int i = 0; i < numDecorationRows; i++) {
      final baseY = topPadding + (adjustedSpacing * (i + 1));
      final randomOffset = (i % 3 - 1) * 12.0;
      final y = baseY + randomOffset;
      final useCloud = (i % 5 == 0 || i % 7 == 0);

      // Left side
      if (leftZone > 50) {
        bool leftTooClose = false;
        for (final usedY in usedPositionsLeft) {
          if ((y - usedY).abs() < minDistanceBetween) {
            leftTooClose = true;
            break;
          }
        }

        if (!leftTooClose) {
          usedPositionsLeft.add(y);
          final leftPos = leftPositions[i % leftPositions.length];

          if (useCloud) {
            final cloudSize = cloudSizes[i % cloudSizes.length];
            elements.add(
              Positioned(
                left: screenWidth * leftPos,
                top: y,
                child: SvgPicture.asset(
                  'assets/images/cloud.svg',
                  width: cloudSize['w']!.toDouble(),
                  height: cloudSize['h']!.toDouble(),
                ),
              ),
            );
          } else {
            final starSize = starSizes[i % starSizes.length];
            elements.add(
              Positioned(
                left: screenWidth * leftPos,
                top: y,
                child: SvgPicture.asset(
                  'assets/images/pinkstar.svg',
                  width: starSize['w']!,
                  height: starSize['h']!,
                ),
              ),
            );
          }
        }
      }

      // Right side
      if (rightZone > 50) {
        final rightY = y + ((i % 2 == 0) ? 8.0 : -8.0);

        bool rightTooClose = false;
        for (final usedY in usedPositionsRight) {
          if ((rightY - usedY).abs() < minDistanceBetween) {
            rightTooClose = true;
            break;
          }
        }

        if (!rightTooClose) {
          usedPositionsRight.add(rightY);
          final rightPos = rightPositions[i % rightPositions.length];

          if (useCloud) {
            final cloudSize = cloudSizes[(i + 1) % cloudSizes.length];
            elements.add(
              Positioned(
                right: screenWidth * rightPos,
                top: rightY,
                child: SvgPicture.asset(
                  'assets/images/cloud.svg',
                  width: cloudSize['w']!.toDouble(),
                  height: cloudSize['h']!.toDouble(),
                ),
              ),
            );
          } else {
            final starSize = starSizes[(i + 1) % starSizes.length];
            elements.add(
              Positioned(
                right: screenWidth * rightPos,
                top: rightY,
                child: SvgPicture.asset(
                  'assets/images/pinkstar.svg',
                  width: starSize['w']!,
                  height: starSize['h']!,
                ),
              ),
            );
          }
        }
      }
    }

    return elements;
  }
}
