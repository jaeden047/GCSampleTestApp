import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color bgColor = const Color(0xFFE5ECDF); // #E5ECDF
  final Color txColor = const Color(0xFF2A262A); // #2A262A

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Future Mind Challenges',
      home: LoginScreen(), // Set your login screen as the start point
      theme: ThemeData(
        scaffoldBackgroundColor: bgColor,
        primaryColor: txColor,
        appBarTheme: AppBarTheme(
          backgroundColor: bgColor,
          foregroundColor: txColor,
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: txColor, fontSize: 16),
          bodyLarge: TextStyle(color: txColor, fontSize: 18),
          titleLarge: TextStyle(color: txColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: txColor),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF103713),       // for buttons, active elements
          onPrimary: Color(0xFFE5ECDF),     // text on primary
          secondary: Color(0xFF7E9C92),     // accent elements
          onSecondary: Color(0xFFE2DBD0),
          error: Color(0xFFBD433E),
          onError: Colors.white,
          surface: Color(0xFFE2DBD0),
          onSurface: Color(0xFF2A262A),
        ),
      ),
    );
  }
}
