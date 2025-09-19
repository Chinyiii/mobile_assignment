import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';
import '../main.dart'; // for supabase instance
import '../auth/auth_service.dart';
import '../services/supabase_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final authService = AuthService();

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final current = _currentController.text;
    final newPassword = _newController.text;
    final confirm = _confirmController.text;

    if (newPassword != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New passwords do not match")),
      );
      setState(() => _loading = false);
      return;
    }

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'No logged-in user';

      // Step 1: Verify current password against Supabase Auth
      final response = await supabase.auth.signInWithPassword(
        email: user.email!,
        password: current,
      );

      if (response.user == null) {
        throw 'Current password is incorrect';
      }

      // Step 2: Update password in Supabase Auth
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      // Step 3: Update password in custom users table (hashed)
      final hashed = BCrypt.hashpw(newPassword, BCrypt.gensalt());
      await supabase
          .from('users')
          .update({'password': hashed})
          .eq('email', user.email!);

      // Step 4: Log user out
      await authService.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset successfully! Please log in again.")),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0xFFF0F2F5),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF121417),
                        size: 24,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121417),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer for centering
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          controller: _currentController,
                          labelText: "Current Password",
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          controller: _newController,
                          labelText: "New Password",
                          validator: (v) => v == null || v.length < 6 ? 'Enter at least 6 chars' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          controller: _confirmController,
                          labelText: "Confirm New Password",
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _resetPassword,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: const Color(0xFFDEE8F2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Change Password"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: const Icon(Icons.lock, color: Color(0xFF61758A)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator ?? (v) => v == null || v.isEmpty ? 'Please enter the password' : null,
      ),
    );
  }
}