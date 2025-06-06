import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home.dart'; // navigate our home page screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ApiService api = ApiService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Future Mind Challenges',
      home: Scaffold(
        appBar: AppBar(title: Text('Login Test')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async { //add a text box for user
              print('Sending request...');
              final response = await api.loginUser(
                'Test User',
                'test@example.com',
                '1234567890',
              );

              print('Status: ${response.statusCode}');
              print('Body: ${response.body}');

              if (response.statusCode == 200) {
                // Navigate to Home page
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Home()),
                );
              } else {
                // Show error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Login failed: ${response.statusCode}')),
                );
              }
            },
            child: Text('Login'),
          ),
        ),
      ),
    );
  }
}
