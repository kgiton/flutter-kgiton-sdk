import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'qr_scanner_page.dart';

/// Register page for new user registration
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _licenseKeyController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();

  // License key formatter: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
  final _licenseKeyFormatter = MaskTextInputFormatter(
    mask: '#####-#####-#####-#####-#####',
    filter: {"#": RegExp(r'[A-Z0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  String _entityType = 'individual'; // Default to individual
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _licenseKeyController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const QRScannerPage()));

    if (result != null && result.isNotEmpty) {
      // Format the scanned result to match XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
      String formattedKey = result.toUpperCase().replaceAll('-', '');

      // Add hyphens at correct positions if not present
      if (formattedKey.length == 25) {
        formattedKey =
            '${formattedKey.substring(0, 5)}-'
            '${formattedKey.substring(5, 10)}-'
            '${formattedKey.substring(10, 15)}-'
            '${formattedKey.substring(15, 20)}-'
            '${formattedKey.substring(20, 25)}';
      }

      setState(() {
        _licenseKeyController.text = formattedKey;
      });
    }
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      // Keep hyphens in license key (backend expects format: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX)
      final licenseKey = _licenseKeyController.text.trim().toUpperCase();

      context.read<AuthBloc>().add(
        RegisterRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          licenseKey: licenseKey,
          entityType: _entityType,
          companyName: _entityType == 'company' ? _companyNameController.text.trim() : null,
        ),
      );
    }
  }

  void _showLicenseKeyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: KgitonThemeColors.cardBackground,
        title: const Text('How to Get License Key', style: TextStyle(color: KgitonThemeColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('License key is obtained from your KGiTON scale device.', style: TextStyle(color: KgitonThemeColors.textSecondary)),
            const SizedBox(height: 16),
            const Text(
              'Contact Information:',
              style: TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.phone, color: KgitonThemeColors.primaryGreen, size: 18),
                SizedBox(width: 8),
                Text('+62 819-9479-0864', style: TextStyle(color: KgitonThemeColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.email, color: KgitonThemeColors.primaryGreen, size: 18),
                SizedBox(width: 8),
                Text('support@kgiton.com', style: TextStyle(color: KgitonThemeColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KgitonThemeColors.backgroundDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Note: Each KGiTON device comes with a unique license key. '
                'Check your device packaging or contact admin.',
                style: TextStyle(color: KgitonThemeColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: KgitonThemeColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KgitonThemeColors.backgroundDark,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: KgitonThemeColors.errorRed));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Image.asset('assets/logo/kgiton-logo.png', height: 100, fit: BoxFit.contain),
                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'Create Account',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Sign up to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // License Key Field (moved to top)
                      CustomTextField(
                        controller: _licenseKeyController,
                        label: 'License Key *',
                        hint: 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX',
                        enabled: !isLoading,
                        inputFormatters: [_licenseKeyFormatter],
                        textCapitalization: TextCapitalization.characters,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: KgitonThemeColors.primaryGreen),
                          onPressed: isLoading ? null : _scanQRCode,
                          tooltip: 'Scan QR Code',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your license key';
                          }
                          // Validate format: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX (29 chars with hyphens)
                          if (value.length != 29) {
                            return 'License key must be in format: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX';
                          }
                          // Check if it has exactly 4 hyphens in correct positions
                          final parts = value.split('-');
                          if (parts.length != 5 || parts.any((part) => part.length != 5)) {
                            return 'Invalid license key format';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // License Key Help Card
                      Card(
                        color: KgitonThemeColors.cardBackground.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: KgitonThemeColors.primaryGreen.withValues(alpha: 0.3), width: 1),
                        ),
                        child: InkWell(
                          onTap: _showLicenseKeyInfo,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: KgitonThemeColors.primaryGreen, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'How to get License Key?',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: KgitonThemeColors.primaryGreen,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Obtained from your KGiTON device or contact admin',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: KgitonThemeColors.textSecondary, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, color: KgitonThemeColors.textSecondary, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name Field
                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name *',
                        hint: 'Enter your full name',
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.length < 3) {
                            return 'Name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email *',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
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
                      const SizedBox(height: 16),

                      // Entity Type Selector
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Entity Type *',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: KgitonThemeColors.cardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: KgitonThemeColors.borderDefault, width: 1),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: isLoading ? null : () => setState(() => _entityType = 'individual'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _entityType == 'individual' ? KgitonThemeColors.primaryGreen : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Individual',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _entityType == 'individual' ? KgitonThemeColors.backgroundDark : KgitonThemeColors.textSecondary,
                                          fontWeight: _entityType == 'individual' ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: isLoading ? null : () => setState(() => _entityType = 'company'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _entityType == 'company' ? KgitonThemeColors.primaryGreen : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Company',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _entityType == 'company' ? KgitonThemeColors.backgroundDark : KgitonThemeColors.textSecondary,
                                          fontWeight: _entityType == 'company' ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Company Name Field (only show if entity type is company)
                      if (_entityType == 'company') ...[
                        CustomTextField(
                          controller: _companyNameController,
                          label: 'Company Name *',
                          hint: 'Enter your company name',
                          enabled: !isLoading,
                          validator: (value) {
                            if (_entityType == 'company' && (value == null || value.isEmpty)) {
                              return 'Please enter your company name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        obscureText: _obscurePassword,
                        enabled: !isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: KgitonThemeColors.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
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
                        hint: 'Confirm your password',
                        obscureText: _obscureConfirmPassword,
                        enabled: !isLoading,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: KgitonThemeColors.textSecondary,
                          ),
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

                      // Register Button
                      CustomButton(text: 'Sign Up', onPressed: isLoading ? null : _handleRegister, isLoading: isLoading),
                      const SizedBox(height: 24),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: isLoading ? null : () => context.go('/login'),
                            child: Text(
                              'Sign In',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(color: KgitonThemeColors.primaryGreen, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
