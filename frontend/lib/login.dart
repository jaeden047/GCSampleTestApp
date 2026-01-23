import 'package:flutter/material.dart';

// Page Imports
import 'home.dart';
import 'main.dart';
import 'api_service.dart';
import 'signup/signup_screen1.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState(); // creates a state object per function declaration
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
 } // Return child without scrollbar }
  @override Widget buildOverscrollIndicator( 
    BuildContext context,
    Widget child, 
    ScrollableDetails details, 
    ) { return child; 
    }
  }// Return child without overscroll indicator } }
//Main errors: no submit function; validate inputs is not called, so aren't other functions.

class _LoginPageState extends State<LoginPage> { // stateful because transitions between login state and signup state & show a spinner
  // each controller holds the current value of a text field and lets you read it.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  //--
  final institutionController = TextEditingController();
  final addressController = TextEditingController();
  final countryController = TextEditingController();
  final genderController = TextEditingController();
  final gradeController = TextEditingController();
  final userTypeController = TextEditingController();
  final referenceCodeController = TextEditingController();  
  //--
  final studentTypeController = TextEditingController();
  final interestedProgramController = TextEditingController(); // "69598383bfc1a2a7926b46f6"
  final photoController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    institutionController.dispose();
    addressController.dispose();
    countryController.dispose();
    genderController.dispose();
    gradeController.dispose();
    userTypeController.dispose();
    referenceCodeController.dispose();
    studentTypeController.dispose();
    interestedProgramController.dispose();
    photoController.dispose();
    super.dispose();
  }

  bool _isLogin = true; // login?
  bool _isLoading = false; // prevent spam tapping and show the spinner.
  bool _passwordVisible = false; // Password visibility toggle

  // (login only)
  String? _validateInputs() { // checks user input
    final email = emailController.text.trim();
    final password = passwordController.text;
    
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Please enter a valid email address';
    }
    //Email Checks
    
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    //Password Checks

    final specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!specialCharRegex.hasMatch(password)) {
      return r'Password must contain at least one special character: [!@#$%^&*(),.?":{}|<>]';
    }
    //Special Char Checks
    if (!_isLogin) {
      final name = nameController.text.trim();
      if (name.isEmpty) {
        return 'Name is required';
      }
    }
    //This check is an extra check used for sign-up only (additional check for Name)
    return null; // when all validations passed
  } 

    Future<void> _onTap() async { // User Taps Login
    final error = _validateInputs();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
  setState(() => _isLoading = true); // loading wheel
  try { // After inputs validated, we send to api
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (_isLogin) {
      await ApiService.instance.login( // use apiservice login function
        email: email,
        password: password,
      );
    } else {
      await ApiService.instance.register( // use apiservice register function
        email: email,
        password: password,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        institution: institutionController.text.trim(),
        address: addressController.text.trim(),
        country: countryController.text.trim(),
        gender: genderController.text.trim(),
        grade: gradeController.text.trim(),
        photo: "https://example.com/profile.jpg",
        userType: userTypeController.text.trim(),
        referenceCode: referenceCodeController.text.trim(),
        studentType: "school",
        interestedProgram: "69598383bfc1a2a7926b46f6",
      );
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Home()),
    );
  } catch (e, st) {
    print('AUTH ERROR: $e');
    print('STACK: $st');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Auth failed: $e')),
    );
  } finally {
  if (!mounted) return;
  setState(() => _isLoading = false);
}
}  

  @override
  Widget build(BuildContext context) { 
    // Get colors from MyApp theme
    final tealBackground = MyApp.loginTealBackground;
    final pinkTitle = MyApp.loginPinkTitle;
    final darkNavyButton = MyApp.loginDarkNavyButton;
    final greySubtitle = MyApp.loginGreySubtitle;
    
    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final horizontalPadding = isMobile ? 24.0 : 40.0;
    final verticalPadding = isMobile ? 32.0 : 48.0;
    final titleFontSize = isMobile ? 28.0 : 36.0;
    final subtitleFontSize = isMobile ? 14.0 : 16.0;
    final logoHeight = isMobile ? 80.0 : 120.0;
    
//--
// The following is the fields for the login screen, signup fields are on signup page.
//--
    return Scaffold(
      backgroundColor: tealBackground,
      body: SafeArea(
        child: Center( // keeps widgets centered
          child: ScrollConfiguration(
            behavior: _NoScrollbarScrollBehavior(),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ), 
            child: ConstrainedBox(
            constraints: BoxConstraints(
              // desktop/tablet: cap width to 500
              // mobile: no cap (use available width)
            maxWidth: isMobile ? double.infinity : 500, 
            minHeight: screenHeight - (verticalPadding * 2)
            - MediaQuery.of(context).padding.top
            - MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Center(
                  child: Image.asset(
                  'assets/images/gcFuture.png',
                  height: logoHeight,
                  fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: isMobile ? 32 : 40),
                Text(
                  'Login to your account!', 
                  style: TextStyle(
                    color: pinkTitle,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                'Enter your verified account details to start the quiz.',
                style: TextStyle(
                color: greySubtitle,
                fontSize: subtitleFontSize,
                fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: isMobile ? 32 : 40),
              // Title & Subtitle Above
              // -- Text Field Container --
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField( // User Fields Begin Here
                  controller: emailController, 
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                  decoration: InputDecoration(
                    hintText: 'Email',
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
      // -- Text Field Box Template Above (Email); will be used for all textboxes 

      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: passwordController,
          obscureText: !_passwordVisible,
          style: TextStyle(fontSize: isMobile ? 14 : 16),
          decoration: InputDecoration(
            hintText: 'Enter password',
            hintStyle: TextStyle(color: greySubtitle, fontSize: isMobile ? 14 : 16),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isMobile ? 16 : 18,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
                color: greySubtitle,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
        ),
      ),
      SizedBox(height: isMobile ? 32 : 40),
      // Loading Spinner; for whenever 'loading' is triggered.
      if (_isLoading) ...[
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
        ),
        SizedBox(height: isMobile ? 24 : 32),
      ],
      // Login / Signup Button
      SizedBox(
        width: double.infinity,
        child: ElevatedButton( // BUTTON
          // If loading true -> disable button, 
          // If loading false -> when pressed (onPressed) to the submit function
          onPressed: _isLoading ? null : _onTap,
          // -- More Styling
          style: ElevatedButton.styleFrom( 
            backgroundColor: darkNavyButton,
            foregroundColor: Colors.white,
            disabledBackgroundColor: darkNavyButton.withOpacity(0.6),
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 16 : 18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text( 
            // If _isLoading == true → the button shows "processing..."
            // If _isLoading == false → the button shows "Login"
            _isLoading
              ? 'processing...'
              : 'Login',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SizedBox(height: isMobile ? 24 : 32),
      // Sign Up
      Center(
        child: TextButton( // Button
          onPressed: _isLoading
            ? null //  if loading is already happening, do nothing
            : () { //  if not, nav. to signup
              // Signup Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SignupScreen1()),
              );
            },
        child: Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w400,
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