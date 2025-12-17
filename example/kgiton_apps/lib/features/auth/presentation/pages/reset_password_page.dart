import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Reset password page using token from email
class ResetPasswordPage extends StatefulWidget {
  final String? token;

  const ResetPasswordPage({super.key, this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _resetSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      if (widget.token == null || widget.token!.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid or missing reset token'), backgroundColor: KgitonThemeColors.errorRed));
        return;
      }

      setState(() => _isLoading = true);

      try {
        context.read<AuthBloc>().add(ResetPasswordRequested(token: widget.token!, newPassword: _passwordController.text));

        setState(() {
          _resetSuccess = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to reset password: $e'), backgroundColor: KgitonThemeColors.errorRed));
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
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(padding: const EdgeInsets.all(24.0), child: _resetSuccess ? _buildSuccessView() : _buildFormView()),
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
            'Reset Password',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Enter your new password',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // New Password Field
          CustomTextField(
            controller: _passwordController,
            label: 'New Password',
            hint: 'Enter new password',
            obscureText: _obscurePassword,
            enabled: !_isLoading,
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: KgitonThemeColors.textSecondary),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter new password',
            obscureText: _obscureConfirmPassword,
            enabled: !_isLoading,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: KgitonThemeColors.textSecondary),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Reset Password Button
          CustomButton(text: 'Reset Password', onPressed: _isLoading ? null : _handleResetPassword, isLoading: _isLoading),
          const SizedBox(height: 24),

          // Back to Login Link
          Center(
            child: GestureDetector(
              onTap: _isLoading ? null : () => context.go('/login'),
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
        const Icon(Icons.check_circle_outline, size: 80, color: KgitonThemeColors.primaryGreen),
        const SizedBox(height: 32),

        // Title
        Text(
          'Password Reset Successful',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        Text(
          'Your password has been reset successfully. You can now log in with your new password.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // Go to Login Button
        CustomButton(text: 'Go to Login', onPressed: () => context.go('/login')),
      ],
    );
  }
}
