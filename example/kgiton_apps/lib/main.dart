import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/kgiton_theme_colors.dart';
import 'core/di/injection_container.dart';
import 'core/routes/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize dependencies
  await initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: MaterialApp.router(
        title: 'KGiTON Apps',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: KgitonThemeColors.backgroundDark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: KgitonThemeColors.primaryGreen,
            brightness: Brightness.dark,
            primary: KgitonThemeColors.primaryGreen,
            secondary: KgitonThemeColors.primaryGreenHover,
            surface: KgitonThemeColors.cardBackground,
            error: KgitonThemeColors.errorRed,
          ),
          cardTheme: const CardThemeData(
            color: KgitonThemeColors.cardBackground,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              side: BorderSide(color: KgitonThemeColors.borderDefault),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: KgitonThemeColors.cardBackground,
            foregroundColor: KgitonThemeColors.textPrimary,
            elevation: 0,
            centerTitle: true,
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
            headlineSmall: TextStyle(color: KgitonThemeColors.textPrimary, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(color: KgitonThemeColors.textPrimary),
            bodyMedium: TextStyle(color: KgitonThemeColors.textPrimary),
            bodySmall: TextStyle(color: KgitonThemeColors.textSecondary),
          ),
          dividerTheme: const DividerThemeData(color: KgitonThemeColors.divider),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
