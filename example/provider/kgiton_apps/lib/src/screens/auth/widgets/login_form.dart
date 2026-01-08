/// ============================================================================
/// Login Form Widget
/// ============================================================================
///
/// File: src/screens/auth/widgets/login_form.dart
/// Deskripsi: Form widget untuk login
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
// import '../../../config/theme.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginForm({super.key, required this.onLoginSuccess});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined), hintText: 'Masukkan email Anda'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!value.contains('@')) {
                  return 'Email tidak valid';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                hintText: 'Masukkan password Anda',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                return null;
              },
            ),

            const SizedBox(height: 8),

            // Forgot password link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur reset password akan datang')));
                },
                child: const Text('Lupa Password?'),
              ),
            ),

            const SizedBox(height: 16),

            // Login button
            /// Menggunakan Consumer untuk listen loading state
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  child: authProvider.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Login'),
                );
              },
            ),

            const SizedBox(height: 16),

            /*
            // Demo account info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KGiTONColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo Account:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: KGiTONColors.info,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Email: demo@kgiton.com',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Password: demo123',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            */
          ],
        ),
      ),
    );
  }

  /// Handle login action
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Menggunakan context.read untuk akses method (tidak perlu listen)
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(email: _emailController.text.trim(), password: _passwordController.text);

    if (success && mounted) {
      widget.onLoginSuccess();
    }
  }
}
