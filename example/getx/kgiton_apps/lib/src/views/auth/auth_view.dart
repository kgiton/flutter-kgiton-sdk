/// ============================================================================
/// Auth View - GetX UI
/// ============================================================================
///
/// File: src/views/auth/auth_view.dart
/// Deskripsi: Halaman login dan register
///
/// GetX UI Features:
/// - Obx(() => ...) untuk reactive UI
/// - Get.find<Controller>() untuk access controller
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Logo
              _buildLogo(),
              const SizedBox(height: 32),

              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: KGiTONColors.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Login'),
                    Tab(text: 'Register'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _LoginForm(controller: _authController),
                    _RegisterForm(
                      controller: _authController,
                      onSuccess: () => _tabController.animateTo(0),
                    ),
                  ],
                ),
              ),
            ],
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
}

/// Login Form Widget
class _LoginForm extends StatelessWidget {
  final AuthController controller;

  _LoginForm({required this.controller});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
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

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Login Button
          // =================================================================
          // Obx - Reactive Widget
          // Akan rebuild otomatis saat isLoading berubah
          // =================================================================
          Obx(() => SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _onLogin,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Login'),
                ),
              )),
        ],
      ),
    );
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      controller.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }
}

/// Register Form Widget
class _RegisterForm extends StatelessWidget {
  final AuthController controller;
  final VoidCallback? onSuccess;

  _RegisterForm({required this.controller, this.onSuccess});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          // Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
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

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outlined),
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
          const SizedBox(height: 16),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Konfirmasi Password',
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Password tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // License Key
          TextFormField(
            controller: _licenseKeyController,
            decoration: const InputDecoration(
              labelText: 'License Key',
              prefixIcon: Icon(Icons.vpn_key_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'License key tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Register Button
          Obx(() => SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _onRegister,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Register'),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _onRegister() async {
    if (_formKey.currentState!.validate()) {
      final success = await controller.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        licenseKey: _licenseKeyController.text.trim(),
      );
      if (success) {
        onSuccess?.call();
      }
    }
  }
}
