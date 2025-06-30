import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // supabase flutter sdk
import 'home.dart';
import 'login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://duvycvfjnirqtqvxkrxz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1dnljdmZqbmlycXRxdnhrcnh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5NjE5MDUsImV4cCI6MjA2NjUzNzkwNX0.YGyw8CvpQTVCADMc7EDv2ez2i2uQ0p0bT6cmI7_ZWxQ',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color bgColor = const Color(0xFFE5ECDF); // #E5ECDF
  final Color txColor = const Color(0xFF2A262A); // #2A262A

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Supabase App',
      // App Theme
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
      home: AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // User is logged in
      return Home();
    } else {
      // User is not logged in
      // Will need to add signup page
      return LoginPage();
    }
  }
}