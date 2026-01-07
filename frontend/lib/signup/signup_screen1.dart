import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';
import 'signup_data.dart';
import 'signup_screen2.dart';
import 'country_codes.dart';
import '../login.dart';

// Screen 1: Personal Details
class SignupScreen1 extends StatefulWidget {
  final SignupData? initialData;
  
  const SignupScreen1({super.key, this.initialData});

  @override
  State<SignupScreen1> createState() => _SignupScreen1State();
}

class _SignupScreen1State extends State<SignupScreen1> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  CountryCode _selectedCountryCode = CountryCodes.getDefault();
  String? _selectedGender;
  
  final tealBackground = MyApp.loginTealBackground;
  final pinkTitle = MyApp.loginPinkTitle;
  final darkNavyButton = MyApp.loginDarkNavyButton;
  final greySubtitle = MyApp.loginGreySubtitle;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _nameController.text = widget.initialData!.fullName ?? '';
      _emailController.text = widget.initialData!.email ?? '';
      // Extract phone number without dial code if it exists
      final phone = widget.initialData!.phoneNumber ?? '';
      if (phone.startsWith('+')) {
        // Find country code from phone number
        final countryCode = CountryCodes.findByDialCode(
          phone.split(' ').first,
        );
        if (countryCode != null) {
          _selectedCountryCode = countryCode;
          _phoneController.text = phone.substring(countryCode.dialCode.length).trim();
        } else {
          _phoneController.text = phone;
        }
      } else {
        _phoneController.text = phone;
      }
      final code = widget.initialData!.countryCode ?? 'CA';
      _selectedCountryCode = CountryCodes.findByCode(code) ?? CountryCodes.getDefault();
      _selectedGender = widget.initialData!.gender;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  String? _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      return 'Full name is required';
    }
    if (_emailController.text.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailController.text.contains('@') || !_emailController.text.contains('.')) {
      return 'Please enter a valid email address';
    }
    if (_phoneController.text.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }
  
  void _goToNext() {
    final validationError = _validateInputs();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }
    
    // Combine dial code with phone number
    final fullPhoneNumber = '${_selectedCountryCode.dialCode} ${_phoneController.text.trim()}';
    
    final data = (widget.initialData ?? SignupData()).copyWith(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: fullPhoneNumber,
      countryCode: _selectedCountryCode.code,
      gender: _selectedGender,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SignupScreen2(data: data)),
    );
  }
  
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final horizontalPadding = isMobile ? 24.0 : 40.0;
    final verticalPadding = isMobile ? 32.0 : 48.0;
    
    // Calculate content area position for desktop (centered with maxWidth 500)
    final starSize = isMobile ? 18.0 : 20.0;
    
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
                    // Main content column
                    Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        // Title broken into 2 lines, left-aligned
                        RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 32 : 40,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                              height: 1.2,
                            ),
                            children: [
                              const TextSpan(text: "Let's start\n"),
                              const TextSpan(text: "with your details!"),
                            ],
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        // Instruction text broken into 2 lines, left-aligned
                        Text(
                          'Your name must match your passport\nor valid government ID for verification purpose.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: greySubtitle,
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: isMobile ? 32 : 40),
                        // Full Name field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Full Name as per passport',
                              hintStyle: TextStyle(color: greySubtitle, fontSize: isMobile ? 14 : 16),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isMobile ? 16 : 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        // Email field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontSize: isMobile ? 14 : 16),
                            decoration: InputDecoration(
                              hintText: 'Your email address',
                              hintStyle: TextStyle(color: greySubtitle, fontSize: isMobile ? 14 : 16),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isMobile ? 16 : 18,
                              ),
                            ),
                          ),
                        ),
                                            
                        SizedBox(height: isMobile ? 16 : 20),
                        // Phone number with country code dropdown
                        Row(
                          children: [
                            // Country code dropdown - wider with full country names
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<CountryCode>(
                                    value: _selectedCountryCode,
                                    isExpanded: true,
                                    icon: Icon(Icons.arrow_drop_down, color: greySubtitle),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: isMobile ? 16 : 18,
                                      ),
                                    ),
                                    dropdownColor: Colors.white,
                                    items: CountryCodes.codes.map((CountryCode country) {
                                      return DropdownMenuItem<CountryCode>(
                                        value: country,
                                        child: Text(
                                          '${country.dialCode} ${country.name}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: isMobile ? 14 : 16,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (CountryCode? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedCountryCode = newValue;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Phone number field 
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                                  decoration: InputDecoration(
                                    hintText: 'Phone number',
                                    hintStyle: TextStyle(color: greySubtitle, fontSize: isMobile ? 14 : 16),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: isMobile ? 16 : 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        // Gender selector
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.white,
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                hintText: 'Select Gender',
                                hintStyle: TextStyle(color: greySubtitle, fontSize: isMobile ? 14 : 16),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: isMobile ? 16 : 18,
                                ),
                              ),
                              items: ['Male', 'Female', 'Other', 'Prefer not to say']
                                  .map((gender) => DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 32 : 40),
                        // Already have account link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => LoginPage()),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: greySubtitle,
                                  fontSize: isMobile ? 13 : 14,
                                ),
                                children: [
                                  const TextSpan(text: 'Already have an account? '),
                                  TextSpan(
                                    text: 'Sign in',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 24 : 32),
                        // Next button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _goToNext,
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
                              'Next',
                              style: TextStyle(
                                fontSize: isMobile ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Decorative SVG stars - scattered on the right side, 2 near "start" (letter "t")
                    // Two stars very close to "start" text, specifically near the letter "t"
                    Positioned(
                      top: 5.0,
                      left: isMobile ? (screenWidth - horizontalPadding * 2) * 0.52 : 260.0,
                      child: SvgPicture.asset(
                        'assets/images/pinkstar.svg',
                        width: isMobile ? starSize * 0.9 : starSize * 0.85,
                        height: isMobile ? starSize * 0.9 * 17 / 18 : starSize * 0.85 * 17 / 18,
                      ),
                    ),
                    Positioned(
                      top: 15.0,
                      left: isMobile ? (screenWidth - horizontalPadding * 2) * 0.55 : 275.0,
                      child: SvgPicture.asset(
                        'assets/images/pinkstar.svg',
                        width: isMobile ? starSize * 1.1 : starSize * 1.15,
                        height: isMobile ? starSize * 1.1 * 17 / 18 : starSize * 1.15 * 17 / 18,
                      ),
                    ),
                    // Upper right star - scattered, smaller size
                    Positioned(
                      top: 10.0,
                      right: 25.0,
                      child: SvgPicture.asset(
                        'assets/images/pinkstar.svg',
                        width: isMobile ? starSize * 0.8 : starSize * 0.75,
                        height: isMobile ? starSize * 0.8 * 17 / 18 : starSize * 0.75 * 17 / 18,
                      ),
                    ),
                    // Star near "details!" - scattered position, medium size
                    Positioned(
                      top: 58.0,
                      right: 20.0,
                      child: SvgPicture.asset(
                        'assets/images/pinkstar.svg',
                        width: isMobile ? starSize * 1.0 : starSize * 1.05,
                        height: isMobile ? starSize * 1.0 * 17 / 18 : starSize * 1.05 * 17 / 18,
                      ),
                    ),
                    // Star to the right of "details!" - scattered, larger size
                    Positioned(
                      top: 75.0,
                      left: isMobile ? (screenWidth - horizontalPadding * 2) * 0.72 : 360.0,
                      child: SvgPicture.asset(
                        'assets/images/pinkstar.svg',
                        width: isMobile ? starSize * 1.2 : starSize * 1.25,
                        height: isMobile ? starSize * 1.2 * 17 / 18 : starSize * 1.25 * 17 / 18,
                      ),
                    ),
                    // Star below instruction text - scattered position, medium size
                    Positioned(
                      top: 120.0,
                      right: 30.0,
                      child: SvgPicture.asset(
                        'assets/images/pinkstar.svg',
                        width: isMobile ? starSize * 0.95 : starSize * 1.0,
                        height: isMobile ? starSize * 0.95 * 17 / 18 : starSize * 1.0 * 17 / 18,
                      ),
                    ),
                    // Star near "purpose" - moved further away with padding, smaller size
                    Positioned(
                      top: 145.0,
                      right: 35.0,
                      child: SvgPicture.asset(
                        'assets/images/pinkstar.svg',
                        width: isMobile ? starSize * 0.85 : starSize * 0.9,
                        height: isMobile ? starSize * 0.85 * 17 / 18 : starSize * 0.9 * 17 / 18,
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
