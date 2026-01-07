import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget { // New Widget Created
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState(); // First state is created
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final newPassController = TextEditingController(); // text controller for new password
  final confirmController = TextEditingController(); // text controller for confirmed password
  bool loading = false; // loading between states

  @override
  void initState() {
    super.initState();
    final code = Uri.base.queryParameters['code'];
    print(code);
    Supabase.instance.client.auth.exchangeCodeForSession(code.toString());

    // For PKCE recovery (?code=...), the flow must be initiated and completed in the same browser storage context — practically: the same “site origin” setup you used when you started it.
    // Basically: if you click reset from https://future-minds-challenge.web.app
    // Then the link you should click must be reaching: https://future-minds-challenge.web.app
    // You should not go from local -> future-minds or future-minds -> local. This is only relevant for developer.
  }

  Future<void> _setNewPassword() async {
    final newPass = newPassController.text;
    final confirm = confirmController.text;

    if (newPass.isEmpty || confirm.isEmpty) { // Ensures that text must be created
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter and confirm your new password.')),
      );
      return;
    }
    if (newPass != confirm) { // Ensures that confirm matches new-pass
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }
    // If no error, then setState matches to loading => true, state transition.

    setState(() => loading = true);

    try {
    // IMPORTANT: ensure we actually have a session
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception(
        'No recovery session. This usually means your app did not process the reset link into a session.',
      );
    }
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPass),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated. Please log in.')),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false); // Back to login page
  } on AuthException catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Auth error: ${e.message}')),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reset failed: $e')),
    );
  } finally {
    if (mounted) setState(() => loading = false);
  }
}

  @override
  void dispose() {
    newPassController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : _setNewPassword,
              child: Text(loading ? 'Saving...' : 'Set new password'),
            ),
          ],
        ),
      ),
    );
  }
}
