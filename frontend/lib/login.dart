import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // JWT Authentication Token
import 'api_service.dart';
import 'home.dart';

// Student Access Login Page
// class LoginScreen extends StatelessWidget {
//   LoginScreen({super.key});
//   final ApiService api = ApiService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Login')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             print('Sending request...');

//             try {
//               final token = await api.loginUser(
//                 'Test User',
//                 'test@example.com',
//                 '1234567890',
//               );
//               // Store the JWT token in SharedPreferences
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               await prefs.setString('jwt_token', token);  // Save token
//               print('Token: $token');

//               Navigator.of(context).push(
//                 MaterialPageRoute(builder: (context) => const Home()),
//               );
//             } catch (error){
//               ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Login failed')),
//               );
//             }
//           },
//           child: Text('Login'),
//         ),
//       ),
//     );
//   }
// }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final email = _emailController.text;
      final phone = _phoneController.text;

      try {
        final token = await api.loginUser(name, email, phone);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Home()));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Access')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Enter your email' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone (Optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('Enter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
