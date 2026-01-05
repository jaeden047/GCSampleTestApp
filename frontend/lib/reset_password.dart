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
      await Supabase.instance.client.auth.updateUser( // User updated
        UserAttributes(password: newPass),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated. Please log in.')),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
          },
        ),
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
