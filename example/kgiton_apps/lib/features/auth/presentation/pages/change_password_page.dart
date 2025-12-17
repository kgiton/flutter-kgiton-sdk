import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

/// Change password page for authenticated users
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _changeSuccess = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        context.read<AuthBloc>().add(ChangePasswordRequested(oldPassword: _oldPasswordController.text, newPassword: _newPasswordController.text));

        setState(() {
          _changeSuccess = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to change password: $e'), backgroundColor: KgitonThemeColors.errorRed));
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
        title: const Text('Change Password', style: TextStyle(color: KgitonThemeColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: KgitonThemeColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(padding: const EdgeInsets.all(24.0), child: _changeSuccess ? _buildSuccessView() : _buildFormView()),
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
          const Icon(Icons.lock_outline, size: 80, color: KgitonThemeColors.primaryGreen),
          const SizedBox(height: 32),

          // Title
          Text(
            'Change Your Password',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            'Enter your current password and choose a new one',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Old Password Field
          CustomTextField(
            controller: _oldPasswordController,
            label: 'Current Password',
            hint: 'Enter current password',
            obscureText: _obscureOldPassword,
            enabled: !_isLoading,
            suffixIcon: IconButton(
              icon: Icon(_obscureOldPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: KgitonThemeColors.textSecondary),
              onPressed: () {
                setState(() {
                  _obscureOldPassword = !_obscureOldPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter current password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // New Password Field
          CustomTextField(
            controller: _newPasswordController,
            label: 'New Password',
            hint: 'Enter new password',
            obscureText: _obscureNewPassword,
            enabled: !_isLoading,
            suffixIcon: IconButton(
              icon: Icon(_obscureNewPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: KgitonThemeColors.textSecondary),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
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
              if (value == _oldPasswordController.text) {
                return 'New password must be different from current password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
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
                return 'Please confirm your new password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Change Password Button
          CustomButton(text: 'Change Password', onPressed: _isLoading ? null : _handleChangePassword, isLoading: _isLoading),
          const SizedBox(height: 24),

          // Cancel Link
          Center(
            child: GestureDetector(
              onTap: _isLoading ? null : () => context.pop(),
              child: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary, fontWeight: FontWeight.bold),
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
          'Password Changed',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        Text(
          'Your password has been changed successfully.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // Done Button
        CustomButton(text: 'Done', onPressed: () => context.pop()),
      ],
    );
  }
}
