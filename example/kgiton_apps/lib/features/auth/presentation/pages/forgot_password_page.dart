import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Forgot password page to request password reset link
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        context.read<AuthBloc>().add(ForgotPasswordRequested(email: _emailController.text.trim()));

        // Show success message
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to send reset link: $e'), backgroundColor: KgitonThemeColors.errorRed));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgitonThemeColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: KgitonThemeColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: KgitonThemeColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(padding: const EdgeInsets.all(24.0), child: _emailSent ? _buildSuccessView() : _buildFormView()),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          const Icon(Icons.lock_reset, size: 80, color: KgitonThemeColors.primaryGreen),
          const SizedBox(height: 32),

          // Title
          Text(
            'Forgot Password?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Email Field
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Send Reset Link Button
          CustomButton(text: 'Send Reset Link', onPressed: _isLoading ? null : _handleForgotPassword, isLoading: _isLoading),
          const SizedBox(height: 24),

          // Back to Login Link
          Center(
            child: GestureDetector(
              onTap: _isLoading ? null : () => context.pop(),
              child: Text(
                'Back to Login',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.primaryGreen, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Icon
        const Icon(Icons.email_outlined, size: 80, color: KgitonThemeColors.primaryGreen),
        const SizedBox(height: 32),

        // Title
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        Text(
          'If an account with that email exists, a password reset link has been sent to:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        Text(
          _emailController.text.trim(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: KgitonThemeColors.primaryGreen, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        Text(
          'Please check your inbox and spam folder. The link will expire in 1 hour.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: KgitonThemeColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // Back to Login Button
        CustomButton(text: 'Back to Login', onPressed: () => context.pop()),
      ],
    );
  }
}
