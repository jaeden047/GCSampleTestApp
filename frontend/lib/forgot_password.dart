import 'package:flutter/material.dart';
import 'main.dart';
import 'api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    setState(() => _sending = true);
    //const redirectUrl = 'https://greencontributor.org/reset-password';

    try {
      await ApiService.instance.forgotPassword( // use apiservice login function
        email: email,
      );
      //await Supabase.instance.client.auth.resetPasswordForEmail(
        //email,
        //redirectTo: redirectUrl,
      //);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Check your email. We have sent you a verification link to the address you provided.'),
          backgroundColor: MyApp.homeTealGreen,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final greySubtitle = MyApp.loginGreySubtitle;
    return Scaffold(
      backgroundColor: MyApp.homeTealGreen,
      appBar: AppBar(
        backgroundColor: MyApp.homeTealGreen,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyApp.homeWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 34,
                      fontWeight: FontWeight.bold,
                      color: MyApp.homeWhite,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your email and we’ll send a reset link.',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: MyApp.loginGreySubtitle,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _emailController,
                      style: TextStyle(fontSize: isMobile ? 14 : 16),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        hintStyle: TextStyle(color: greySubtitle, fontSize: isMobile ? 14 : 16),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isMobile ? 16 : 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sending ? null : _sendReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyApp.loginDarkNavyButton,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(_sending ? 'Sending...' : 'Send Reset Link'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
