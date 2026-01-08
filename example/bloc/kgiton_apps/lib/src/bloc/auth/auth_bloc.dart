/// ============================================================================
/// Auth BLoC - Business Logic Component
/// ============================================================================
/// 
/// File: src/bloc/auth/auth_bloc.dart
/// Deskripsi: BLoC untuk mengelola logika autentikasi
/// 
/// BLoC Pattern:
/// 1. UI mengirim Event (LoginEvent, RegisterEvent, dll)
/// 2. BLoC memproses Event di handler
/// 3. BLoC emit State baru (AuthLoading, AuthAuthenticated, dll)
/// 4. UI rebuild berdasarkan State baru
/// 
/// Keuntungan BLoC:
/// - Separation of concerns (UI terpisah dari logic)
/// - Testable (mudah di-unit test)
/// - Predictable state changes
/// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kgiton_sdk/kgiton_sdk.dart';

import '../../config/constants.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc - mengelola state autentikasi
/// 
/// Cara menggunakan di UI:
/// ```dart
/// // Kirim event
/// context.read<AuthBloc>().add(LoginEvent(email: email, password: password));
/// 
/// // Listen state
/// BlocBuilder<AuthBloc, AuthState>(
///   builder: (context, state) {
///     if (state is AuthLoading) return CircularProgressIndicator();
///     if (state is AuthAuthenticated) return HomeScreen();
///     return LoginScreen();
///   },
/// )
/// ```
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // API Service
  KgitonApiService? _apiService;
  
  // Getter untuk API service (digunakan oleh ScaleBloc)
  KgitonApiService? get apiService => _apiService;
  
  /// Constructor
  /// 
  /// Mendaftarkan semua event handlers.
  /// Initial state adalah AuthInitial.
  AuthBloc() : super(AuthInitial()) {
    // Register event handlers
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<RefreshUserDataEvent>(_onRefreshUserData);
    on<ClearAuthErrorEvent>(_onClearError);
    
    // Initialize API service
    _initializeApiService();
  }
  
  /// Initialize API service
  void _initializeApiService() {
    _apiService = KgitonApiService(baseUrl: AppConstants.apiBaseUrl);
  }
  
  // ==========================================================================
  // EVENT HANDLERS
  // ==========================================================================
  
  /// Handler untuk CheckAuthStatusEvent
  /// 
  /// Mengecek apakah ada session tersimpan di local storage.
  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(AppConstants.userDataKey);
      final accessToken = prefs.getString(AppConstants.tokenKey);
      
      if (userData != null && accessToken != null) {
        // Restore user data
        final user = User.fromJson(json.decode(userData));
        
        // Set token ke API service
        _apiService?.setAccessToken(accessToken);
        
        // Load licenses
        final licenses = await _loadUserLicenses();
        
        emit(AuthAuthenticated(
          user: user,
          licenses: licenses,
          apiService: _apiService!,
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('Check auth error: $e');
      emit(AuthUnauthenticated());
    }
  }
  
  /// Handler untuk LoginEvent
  /// 
  /// Proses login dan simpan session jika berhasil.
  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // Call API login
      final authData = await _apiService!.auth.login(
        email: event.email,
        password: event.password,
      );
      
      // Save session
      await _saveSession(authData);
      
      // Load licenses
      final licenses = await _loadUserLicenses();
      
      emit(AuthAuthenticated(
        user: authData.user,
        licenses: licenses,
        apiService: _apiService!,
      ));
    } catch (e) {
      emit(AuthError(message: 'Login gagal: ${_parseError(e)}'));
    }
  }
  
  /// Handler untuk RegisterEvent
  /// 
  /// Proses registrasi dengan license key.
  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // Call API register
      final message = await _apiService!.auth.register(
        email: event.email,
        password: event.password,
        name: event.name,
        licenseKey: event.licenseKey,
        referralCode: event.referralCode,
      );
      
      emit(AuthRegistrationSuccess(message: message));
    } catch (e) {
      emit(AuthError(message: 'Register gagal: ${_parseError(e)}'));
    }
  }
  
  /// Handler untuk LogoutEvent
  /// 
  /// Logout dan clear session.
  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // Call API logout
      await _apiService?.auth.logout();
    } catch (e) {
      // Ignore error, tetap logout
    } finally {
      // Clear session
      await _clearSession();
      emit(AuthUnauthenticated());
    }
  }
  
  /// Handler untuk RefreshUserDataEvent
  Future<void> _onRefreshUserData(
    RefreshUserDataEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;
    
    try {
      final profile = await _apiService?.user.getProfile();
      final licenses = await _loadUserLicenses();
      
      if (profile != null) {
        // Convert UserProfileData to User for state compatibility
        final user = User(
          id: profile.id,
          name: profile.name,
          email: profile.email,
          role: profile.role,
          apiKey: profile.apiKey,
          referralCode: '',
          createdAt: profile.createdAt,
          updatedAt: profile.createdAt,
        );
        emit((state as AuthAuthenticated).copyWith(
          user: user,
          licenses: licenses,
        ));
      }
    } catch (e) {
      debugPrint('Refresh user data error: $e');
    }
  }
  
  /// Handler untuk ClearAuthErrorEvent
  void _onClearError(
    ClearAuthErrorEvent event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthError) {
      emit(AuthUnauthenticated());
    }
  }
  
  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================
  
  /// Save session ke local storage
  Future<void> _saveSession(AuthData authData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, authData.accessToken);
    await prefs.setString(AppConstants.userDataKey, json.encode(authData.user.toJson()));
    if (authData.user.apiKey.isNotEmpty) {
      await prefs.setString(AppConstants.apiKeyKey, authData.user.apiKey);
    }
  }
  
  /// Clear session dari local storage
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.apiKeyKey);
    await prefs.remove(AppConstants.userDataKey);
  }
  
  /// Load user's license keys
  Future<List<LicenseKey>> _loadUserLicenses() async {
    try {
      final profile = await _apiService?.user.getProfile();
      return profile?.licenseKeys ?? [];
    } catch (e) {
      debugPrint('Load licenses error: $e');
      return [];
    }
  }
  
  /// Parse error message
  String _parseError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}
