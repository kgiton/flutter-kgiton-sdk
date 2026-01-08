/// ============================================================================
/// KGiTON Example App - Clean Architecture
/// ============================================================================
///
/// File: main.dart
/// Deskripsi: Entry point aplikasi dengan dependency injection setup
///
/// Clean Architecture Layer:
/// 1. Domain Layer - Entities, Use Cases, Repository Interfaces
/// 2. Data Layer - Repository Implementations, Data Sources
/// 3. Presentation Layer - UI, BLoC, Widgets
///
/// Dependency Flow:
/// Presentation → Domain ← Data
/// (Data implements Domain interfaces)
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Dependency Injection
import 'src/injection/injection.dart';

// Presentation Layer
import 'src/presentation/bloc/auth/auth_bloc.dart';
import 'src/presentation/bloc/scale/scale_bloc.dart';
import 'src/presentation/pages/splash_page.dart';
import 'src/core/theme/theme.dart';

/// Entry point aplikasi
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const KGiTONApp());
}

/// Root widget aplikasi
///
/// Clean Architecture menggunakan Dependency Injection untuk
/// menyediakan dependencies ke seluruh layer.
class KGiTONApp extends StatelessWidget {
  const KGiTONApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ====================================================================
        // AuthBloc
        // Menggunakan Use Case dari Domain Layer via Dependency Injection
        // ====================================================================
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>(),
        ),

        // ====================================================================
        // ScaleBloc
        // Shared state untuk koneksi scale di seluruh app
        // ====================================================================
        BlocProvider<ScaleBloc>(
          create: (_) => getIt<ScaleBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'KGiTON Scale',
        debugShowCheckedModeBanner: false,
        theme: KGiTONTheme.lightTheme,
        darkTheme: KGiTONTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashPage(),
      ),
    );
  }
}
