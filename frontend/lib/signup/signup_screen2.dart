import 'package:flutter/material.dart';
import '../main.dart';
import 'signup_data.dart';
import 'signup_screen3.dart';

// Screen 2: Additional Details
class SignupScreen2 extends StatefulWidget {
  final SignupData data;
  
  const SignupScreen2({super.key, required this.data});

  @override
  State<SignupScreen2> createState() => _SignupScreen2State();
}

class _SignupScreen2State extends State<SignupScreen2> {
  final _addressController = TextEditingController();
  final _institutionController = TextEditingController();
  final _referenceCodeController = TextEditingController();
  String? _selectedGrade;
  final tealBackground = MyApp.loginTealBackground;
  final pinkTitle = MyApp.loginPinkTitle;
  final darkNavyButton = MyApp.loginDarkNavyButton;
  final greySubtitle = MyApp.loginGreySubtitle;
  
  @override
  void initState() {
    super.initState();
    _addressController.text = widget.data.address ?? '';
    _selectedGrade = widget.data.grade;
    _institutionController.text = widget.data.institutionSchool ?? '';
    _referenceCodeController.text = widget.data.referenceCode ?? ''; 
    // In case user goes back to page 1 and comes back
  }
  
  @override
  void dispose() {
    _addressController.dispose();
    _institutionController.dispose();
    _referenceCodeController.dispose();
    super.dispose();
  }
  
  String? _validateInputs() {
    if (_addressController.text.trim().isEmpty) {
      return 'Address is required';
    }
    if (_institutionController.text.trim().isEmpty) {
      return 'Institution/School name is required';
    }
    if (_selectedGrade == null || _selectedGrade!.isEmpty) {
      return 'Please select your grade';
    }
    // Reference code is optional, so no validation needed
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
    
    final updatedData = widget.data.copyWith(
      address: _addressController.text.trim(),
      institutionSchool: _institutionController.text.trim(),
      grade: _selectedGrade,
      referenceCode: _referenceCodeController.text.trim().isEmpty 
          ? 'FUTUREMINDG8R1' 
          : _referenceCodeController.text.trim(),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SignupScreen3(data: updatedData)),
    );
  }
  
  void _goBack() {
    Navigator.pop(context);
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
                child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          "Just a few more to go!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 32 : 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        // Instruction text
                        Text(
                          'Your name must match your passport to avoid verification issues.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: greySubtitle,
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: isMobile ? 32 : 40),
                        // Address field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _addressController,
                            style: TextStyle(fontSize: isMobile ? 14 : 16),
                            decoration: InputDecoration(
                              hintText: 'Your Address',
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
                        // Institution/School field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _institutionController,
                            style: TextStyle(fontSize: isMobile ? 14 : 16),
                            decoration: InputDecoration(
                              hintText: 'Institution/School Name',
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
                        // Grade field (NEED TO MAKE A TOGGLE)
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
                              initialValue: _selectedGrade,
                              decoration: InputDecoration(
                                hintText: 'Select Grade',
                                hintStyle: TextStyle(color: greySubtitle, fontSize: isMobile ? 14 : 16),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: isMobile ? 16 : 18,
                                ),
                              ),
                              items: ['5', '6', '7', '8', '9', '10', '11', '12']
                                  .map((grade) => DropdownMenuItem(
                                        value: grade,
                                        child: Text(grade),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedGrade = value;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        // Reference code field (optional)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _referenceCodeController,
                            style: TextStyle(fontSize: isMobile ? 14 : 16),
                            decoration: InputDecoration(
                              hintText: 'Reference code (optional)',
                              hintStyle: TextStyle(color: greySubtitle, fontSize: isMobile ? 14 : 16),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isMobile ? 16 : 18,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 32 : 40),
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
                        SizedBox(height: isMobile ? 24 : 32),
                        // Back link
                        Center(
                          child: TextButton(
                            onPressed: _goBack,
                            child: Text(
                              'back',
                              style: TextStyle(
                                color: greySubtitle,
                                fontSize: isMobile ? 13 : 14,
                                fontFamily: 'serif',
                              ),
                            ),
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
