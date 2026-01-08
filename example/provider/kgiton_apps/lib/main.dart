/// ============================================================================
/// KGiTON Example App - Provider State Management
/// ============================================================================
/// 
/// File: main.dart
/// Deskripsi: Entry point aplikasi dengan Provider setup
/// 
/// Setup Provider:
/// 1. MultiProvider membungkus seluruh app
/// 2. AuthProvider untuk autentikasi
/// 3. ScaleProvider untuk koneksi BLE
/// 
/// Alur Aplikasi:
/// 1. SplashScreen → cek status login
/// 2. AuthScreen (Login/Register) → jika belum login
/// 3. HomeScreen → dashboard utama
/// 4. DeviceScreen → scan & connect device
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Providers
import 'src/providers/auth_provider.dart';
import 'src/providers/scale_provider.dart';

// Theme
import 'src/config/theme.dart';

// Screens
import 'src/screens/splash_screen.dart';

/// Entry point aplikasi
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const KGiTONApp());
}

/// Root widget aplikasi
/// 
/// Menggunakan MultiProvider untuk menyediakan state ke seluruh widget tree.
/// Urutan provider penting - provider yang bergantung pada provider lain
/// harus dideklarasikan setelahnya.
class KGiTONApp extends StatelessWidget {
  const KGiTONApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ====================================================================
        // AuthProvider
        // Mengelola state autentikasi: login, register, session
        // ====================================================================
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        
        // ====================================================================
        // ScaleProvider
        // Mengelola koneksi BLE, scan device, weight streaming
        // Bergantung pada AuthProvider untuk mendapatkan license key
        // ====================================================================
        ChangeNotifierProxyProvider<AuthProvider, ScaleProvider>(
          create: (_) => ScaleProvider(),
          update: (_, authProvider, scaleProvider) {
            // Update API service di ScaleProvider ketika auth berubah
            scaleProvider?.updateApiService(authProvider.apiService);
            return scaleProvider ?? ScaleProvider();
          },
        ),
      ],
      child: MaterialApp(
        title: 'KGiTON Scale',
        debugShowCheckedModeBanner: false,
        
        // Theme configuration
        theme: KGiTONTheme.lightTheme,
        darkTheme: KGiTONTheme.darkTheme,
        themeMode: ThemeMode.system,
        
        // Initial route
        home: const SplashScreen(),
      ),
    );
  }
}
