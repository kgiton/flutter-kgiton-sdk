import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/kgiton_theme_colors.dart';
import 'core/di/injection_container.dart';
import 'core/observer/global_bloc_observer.dart';
import 'core/routes/app_router.dart';
import 'core/services/deep_link_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize dependencies
  await initializeDependencies();

  // Setup global BLoC observer for auto logout on session expired
  final authBloc = sl<AuthBloc>();
  Bloc.observer = GlobalBlocObserver(authBloc: authBloc);

  // Initialize deep link service
  final deepLinkService = DeepLinkService();
  await deepLinkService.initDeepLinks();

  runApp(MyApp(authBloc: authBloc, deepLinkService: deepLinkService));
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;
  final DeepLinkService deepLinkService;

  const MyApp({super.key, required this.authBloc, required this.deepLinkService});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Auto redirect to login when logged out (including session expired)
          if (state is Unauthenticated) {
            // Show snackbar notification for session expiry
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesi telah berakhir, silakan login kembali'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );

            // Redirect to login
            AppRouter.router.go('/login');
          }
        },
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
      ),
    );
  }
}
