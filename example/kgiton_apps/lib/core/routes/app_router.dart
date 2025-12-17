import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
import '../../features/home/presentation/pages/scale_connection_page.dart';
import '../../features/item/domain/entities/item.dart';
import '../../features/item/presentation/bloc/item_bloc.dart';
import '../../features/item/presentation/pages/create_item_page.dart';
import '../../features/item/presentation/pages/edit_item_page.dart';
import '../../features/item/presentation/pages/item_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/transaction/presentation/bloc/transaction_bloc.dart';
import '../../features/transaction/presentation/pages/transaction_page.dart';
import '../di/injection_container.dart';

/// App router configuration using go_router
class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash route
      GoRoute(path: '/', name: 'splash', builder: (context, state) => const SplashPage()),

      // Login route
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginPage()),

      // Register route
      GoRoute(path: '/register', name: 'register', builder: (context, state) => const RegisterPage()),

      // Forgot password route
      GoRoute(path: '/forgot-password', name: 'forgot-password', builder: (context, state) => const ForgotPasswordPage()),

      // Reset password route
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return ResetPasswordPage(token: token);
        },
      ),

      // Change password route
      GoRoute(path: '/change-password', name: 'change-password', builder: (context, state) => const ChangePasswordPage()),

      // Scale connection route (after login, before home)
      GoRoute(path: '/scale-connection', name: 'scale-connection', builder: (context, state) => const ScaleConnectionPage()),

      // Home route (Main Navigation with Bottom Nav Bar)
      GoRoute(path: '/home', name: 'home', builder: (context, state) => const MainNavigationPage()),

      // Item routes (removed separate BlocProvider, will use existing from MainNavigationPage)
      GoRoute(
        path: '/items',
        name: 'items',
        builder: (context, state) {
          return BlocProvider.value(value: sl<ItemBloc>(), child: const ItemPage());
        },
      ),
      GoRoute(
        path: '/items/create',
        name: 'create-item',
        builder: (context, state) {
          return BlocProvider.value(value: sl<ItemBloc>(), child: const CreateItemPage());
        },
      ),
      GoRoute(
        path: '/items/:id/edit',
        name: 'edit-item',
        builder: (context, state) {
          final item = state.extra as Item;
          return BlocProvider.value(
            value: sl<ItemBloc>(),
            child: EditItemPage(item: item),
          );
        },
      ),

      // Transaction route
      GoRoute(
        path: '/transaction',
        name: 'transaction',
        builder: (context, state) {
          return BlocProvider.value(value: sl<TransactionBloc>(), child: const TransactionPage());
        },
      ),
    ],

    // Error page
    errorBuilder: (context, state) => const SplashPage(),
  );
}
