/// ============================================================================
/// KGiTON Example App - BLoC State Management
/// ============================================================================
/// 
/// File: main.dart
/// Deskripsi: Entry point aplikasi dengan BLoC setup
/// 
/// Setup BLoC:
/// 1. MultiBlocProvider membungkus seluruh app
/// 2. AuthBloc untuk autentikasi (events & states)
/// 3. ScaleBloc untuk koneksi BLE
/// 
/// Alur BLoC:
/// Event → Bloc → State → UI
/// UI mengirim Event, Bloc memproses dan emit State baru
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// BLoCs
import 'src/bloc/auth/auth_bloc.dart';
import 'src/bloc/auth/auth_event.dart';
import 'src/bloc/scale/scale_bloc.dart';

// Theme
import 'src/config/theme.dart';

// Screens
import 'src/screens/splash_screen.dart';

/// BLoC Observer untuk debugging
/// Memonitor semua event dan state changes di aplikasi
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

/// Entry point aplikasi
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup BLoC observer untuk debugging
  Bloc.observer = AppBlocObserver();
  
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
/// Menggunakan MultiBlocProvider untuk menyediakan BLoC ke seluruh widget tree.
/// Setiap BLoC mengelola state domain-nya masing-masing.
class KGiTONApp extends StatelessWidget {
  const KGiTONApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ====================================================================
        // AuthBloc
        // Mengelola state autentikasi: login, register, session
        // Events: LoginEvent, RegisterEvent, LogoutEvent, CheckAuthEvent
        // States: AuthInitial, AuthLoading, AuthAuthenticated, AuthUnauthenticated
        // ====================================================================
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(CheckAuthStatusEvent()),
        ),
        
        // ====================================================================
        // ScaleBloc
        // Mengelola koneksi BLE, scan device, weight streaming
        // Events: StartScanEvent, ConnectDeviceEvent, DisconnectEvent
        // States: ScaleInitial, ScaleScanning, ScaleConnected, etc.
        // ====================================================================
        BlocProvider<ScaleBloc>(
          create: (context) => ScaleBloc(
            // Inject AuthBloc untuk akses API service
            authBloc: context.read<AuthBloc>(),
          ),
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
