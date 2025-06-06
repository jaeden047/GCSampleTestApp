// login_screen.dart
import 'package:flutter/material.dart';
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
            final response = await api.loginUser(
              'Test User',
              'test@example.com',
              '1234567890',
            );

            print('Status: ${response.statusCode}');
            print('Body: ${response.body}');

            if (response.statusCode == 200) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const Home()),
              );
            } else {
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
