import 'package:flutter/material.dart'; // flutter widgets
import 'package:flutter_svg/svg.dart'; // login/signup button
import 'api_service.dart'; //network calls
import 'home.dart';// page to navigate to after login

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState(); // creates a state object per function declaration
}

//Main errors: no submit function; validate inputs is not called, so aren't other functions.

class _LoginPageState extends State<LoginPage> { // stateful because transitions between login state and signup state & show a spinner
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
  final photoController = TextEditingController();
  final userTypeController = TextEditingController();
  final referenceCodeController = TextEditingController();  

  bool _isLogin = true; // true = Login, false = Sign Up
  bool _isLoading = false; // prevent spam tapping and show the spinner.

  // Input validation function
  String? _validateInputs() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')), // if Login is true title shows "Login", if not, "Sign Up"
      body: SingleChildScrollView( //scrollable
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/gcFuture.png', // logo from file
            ),
            if (_isLogin == false)...[ // if SignUp, adds a new field; Full Name
              const SizedBox(height: 12),
              TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
              controller: institutionController,
              decoration: const InputDecoration(labelText: 'Institute'),
              ),
              const SizedBox(height: 12),
              TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
              ),
              const SizedBox(height: 12),
              TextField(
              controller: countryController,
              decoration: const InputDecoration(labelText: 'Country'),
              ),
              const SizedBox(height: 12),
              TextField(
              controller: genderController,
              decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 12),
              TextField(
              controller: gradeController,
              decoration: const InputDecoration(labelText: 'Grade'),
              ),
              const SizedBox(height: 12),
              TextField(
              controller: photoController,
              decoration: const InputDecoration(labelText: 'Photo'),
              ),
              const SizedBox(height: 12),
              TextField(
              controller: userTypeController,
              decoration: const InputDecoration(labelText: 'User Type'),
              ),
              const SizedBox(height: 12),
              TextField(
              controller: referenceCodeController,
              decoration: const InputDecoration(labelText: 'Reference Code'),
              ),
            ],
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            if (_isLogin == false)...[
              const SizedBox(height: 12),
              TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number (Optional)'),
              ),
            ],
            const SizedBox(height: 20),
            _isLoading ? const SizedBox( // if Is Loading is true, show a progress wheel
                  height: 70,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                )
              : GestureDetector(
                  child: SvgPicture.asset(
                    _isLogin ? 'assets/images/login_button.svg' : 'assets/images/signup_button.svg',
                  ),
                ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin
                  ? "Don't have an account? Sign up"
                  : "Already have an account? Login"),
            ),
          ],
        ),
      ),
      ),
    );
  }
}