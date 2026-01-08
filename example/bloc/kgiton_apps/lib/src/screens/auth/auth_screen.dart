/// ============================================================================
/// Auth Screen - BLoC Version
/// ============================================================================
/// 
/// Menggunakan BlocBuilder dan BlocListener untuk state management.
/// 
/// Pattern BLoC di UI:
/// - BlocBuilder: Untuk rebuild UI berdasarkan state
/// - BlocListener: Untuk side effects (navigasi, snackbar, dll)
/// - BlocConsumer: Kombinasi keduanya
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../config/theme.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Form controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerLicenseController = TextEditingController();
  
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerLicenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// BlocListener untuk handle side effects
    /// Navigasi ke HomeScreen saat authenticated
    /// Show snackbar saat error atau registration success
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (state is AuthRegistrationSuccess) {
          _tabController.animateTo(0);
          _showSnackBar(state.message, KGiTONColors.success);
        } else if (state is AuthError) {
          _showSnackBar(state.message, KGiTONColors.error);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 40),
                _buildTabBar(),
                const SizedBox(height: 24),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoginForm(),
                      _buildRegisterForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: KGiTONColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.scale, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'KGiTON',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: KGiTONColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text('Smart Scale Solution', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: KGiTONColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: KGiTONColors.textSecondaryLight,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Login'),
          Tab(text: 'Register'),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _loginPasswordController,
          obscureText: _obscureLoginPassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscureLoginPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        /// BlocBuilder untuk rebuild button berdasarkan loading state
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            
            return ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Login'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _registerNameController,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: Icon(Icons.person_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _registerEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _registerPasswordController,
            obscureText: _obscureRegisterPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(_obscureRegisterPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureRegisterPassword = !_obscureRegisterPassword),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _registerLicenseController,
            decoration: InputDecoration(
              labelText: 'License Key',
              prefixIcon: const Icon(Icons.vpn_key_outlined),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanQRCode,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              
              return ElevatedButton(
                onPressed: isLoading ? null : _handleRegister,
                child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Register'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleLogin() {
    /// Kirim LoginEvent ke AuthBloc
    context.read<AuthBloc>().add(LoginEvent(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text,
    ));
  }

  void _handleRegister() {
    /// Kirim RegisterEvent ke AuthBloc
    context.read<AuthBloc>().add(RegisterEvent(
      name: _registerNameController.text.trim(),
      email: _registerEmailController.text.trim(),
      password: _registerPasswordController.text,
      licenseKey: _registerLicenseController.text.trim(),
    ));
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _QRScannerScreen()),
    );
    if (result != null) {
      _registerLicenseController.text = result;
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}

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
      appBar: AppBar(title: const Text('Scan License Key')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_hasScanned) return;
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null) {
                  _hasScanned = true;
                  Navigator.pop(context, barcode.rawValue);
                  return;
                }
              }
            },
          ),
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
        ],
      ),
    );
  }
}
