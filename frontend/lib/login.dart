class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService api = ApiService();

  void _handleLogin() async {
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
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Test')),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleLogin,
          child: const Text('Login'),
        ),
      ),
    );
  }
}
