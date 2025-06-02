import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService api = ApiService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Future Mind Challenges',
      home: Scaffold(
        appBar: AppBar(title: Text('Login Test')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final response = await api.loginUser(
                'Test User',
                'test@example.com',
                '1234567890',
              );

              print('Status: ${response.statusCode}');
              print('Body: ${response.body}');
            },
            child: Text('Login'),
          ),
        ),
      ),
    );
  }
}
