/// ============================================================================
/// Register Form Widget
/// ============================================================================
///
/// File: src/screens/auth/widgets/register_form.dart
/// Deskripsi: Form widget untuk registrasi dengan license key
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../providers/auth_provider.dart';
import '../../../config/theme.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onRegisterSuccess;

  const RegisterForm({super.key, required this.onRegisterSuccess});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseKeyController = TextEditingController();
  final _referralController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseKeyController.dispose();
    _referralController.dispose();
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
            // Name field
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outlined),
                hintText: 'Masukkan nama lengkap Anda',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

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

            const SizedBox(height: 12),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                hintText: 'Minimal 6 karakter',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Confirm Password field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                hintText: 'Ulangi password Anda',
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Password tidak cocok';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // License Key field with QR scan
            TextFormField(
              controller: _licenseKeyController,
              decoration: InputDecoration(
                labelText: 'License Key',
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                hintText: 'XXXX-XXXX-XXXX-XXXX',
                suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scanQRCode, tooltip: 'Scan QR Code'),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'License key tidak boleh kosong';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            // Referral code (optional)
            TextFormField(
              controller: _referralController,
              decoration: const InputDecoration(
                labelText: 'Kode Referral (Opsional)',
                prefixIcon: Icon(Icons.card_giftcard),
                hintText: 'Masukkan kode referral jika ada',
              ),
            ),

            const SizedBox(height: 24),

            // Register button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleRegister,
                  child: authProvider.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Register'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Handle register action
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      licenseKey: _licenseKeyController.text.trim(),
      referralCode: _referralController.text.trim().isNotEmpty ? _referralController.text.trim() : null,
    );

    if (success && mounted) {
      widget.onRegisterSuccess();
    }
  }

  /// Scan QR code untuk license key
  Future<void> _scanQRCode() async {
    final result = await Navigator.push<String>(context, MaterialPageRoute(builder: (context) => const _QRScannerScreen()));

    if (result != null) {
      _licenseKeyController.text = result;
    }
  }
}

/// QR Scanner screen
class _QRScannerScreen extends StatefulWidget {
  const _QRScannerScreen();

  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan License Key'), backgroundColor: KGiTONColors.primary),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_hasScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _hasScanned = true;
                  Navigator.pop(context, barcode.rawValue);
                  return;
                }
              }
            },
          ),

          // Scan overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: KGiTONColors.primary, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Arahkan kamera ke QR Code\nLicense Key',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
