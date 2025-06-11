// login_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // JWT Authentication Token
import 'api_service.dart';
import 'home.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final ApiService api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            print('Sending request...');

            try {
              final token = await api.loginUser(
                'Test User',
                'test@example.com',
                '1234567890',
              );
              // Store the JWT token in SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('jwt_token', token);  // Save token
              print('Token: $token');

              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const Home()),
              );
            } catch (error){
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login failed')),
              );
            }
          },
          child: Text('Login'),
        ),
      ),
    );
  }
}
