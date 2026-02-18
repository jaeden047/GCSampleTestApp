import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'login.dart';
import 'platform_terms.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

   await Supabase.initialize(
    url: 'https://duvycvfjnirqtqvxkrxz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR1dnljdmZqbmlycXRxdnhrcnh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5NjE5MDUsImV4cCI6MjA2NjUzNzkwNX0.YGyw8CvpQTVCADMc7EDv2ez2i2uQ0p0bT6cmI7_ZWxQ',
    authOptions: const FlutterAuthClientOptions(localStorage: EmptyLocalStorage(), // <- session NOT persisted
  ),
  );
  // Initialize timezone data
  tz_data.initializeTimeZones();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  final Color bgColor = const Color(0xFFE5ECDF); // #E5ECDF
  final Color txColor = const Color(0xFF2A262A); // #2A262A

  // Login page colors (from Figma design - testing phase)
  static const Color loginTealBackground = Color(0xFF439D93); // Teal background
  static const Color loginPinkTitle = Color(0xFFFFBEF4); // Pink title
  static const Color loginDarkNavyButton = Color(0xFF14172D); // Dark navy button
  static const Color loginGreySubtitle = Color(0xFFC8C8C8); // Grey subtitle
  static const Color loginLightGreyHeader = Color(0xFFF5F5F5); // Light grey header

  // Home screen colors (from new Figma design)
  static const Color homeLightGreyBackground = Color(0xFFF5F5F5); // Light grey background
  static const Color homeTealGreen = Color(0xFF439D93); // Teal-green for cards and accents
  static const Color homeDarkTealGreen = Color(0xFF2A7A72); // Dark teal-green for card edges
  static const Color homeLightPink = Color(0xFFFFBEF4); // Light pink for decorative elements
  static const Color homeYellow = Color(0xFFFFD700); // Yellow for accents
  static const Color homePurple = Color(0xFF9B59B6); // Purple for decorative elements
  static const Color homeGreyText = Color(0xFF808080); // Grey text color
  static const Color homeDarkGreyText = Color(0xFF2A262A); // Dark grey text
  static const Color homeWhite = Color(0xFFFFFFFF); // White for buttons and overlays

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Future Mind Challenges',
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
      initialRoute: '/',
      routes: {
        '/': (_) => const AuthGate()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}


class AuthGate extends StatelessWidget { // “When the app starts, decide whether to show Home or Login.”
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ApiService.instance.getToken(), // start reading the saved token from secure storage
      builder: (context, snapshot) { // build the result while token being read
        // simple loading
        if (snapshot.connectionState != ConnectionState.done) { // still waiting for the token read to finish
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final apiToken = snapshot.data;
        final supaUser = Supabase.instance.client.auth.currentUser;

        final hasApi = apiToken != null && apiToken.isNotEmpty;
        final hasSupa = supaUser != null;
        
        if (hasApi && hasSupa) {
          return const PlatformTermsScreen();
        }
        return const LoginPage(); // if no token exists, go to login page
      },
    );
  }
}