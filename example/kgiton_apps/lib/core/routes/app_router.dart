import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
import '../../features/item/domain/entities/item.dart';
import '../../features/item/presentation/bloc/item_bloc.dart';
import '../../features/item/presentation/pages/create_item_page.dart';
import '../../features/item/presentation/pages/edit_item_page.dart';
import '../../features/item/presentation/pages/item_list_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
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

      // Home route (Main Navigation with Bottom Nav Bar)
      GoRoute(path: '/home', name: 'home', builder: (context, state) => const MainNavigationPage()),

      // Item routes
      GoRoute(
        path: '/items',
        name: 'items',
        builder: (context, state) {
          return BlocProvider(create: (context) => sl<ItemBloc>(), child: const ItemListPage());
        },
      ),
      GoRoute(
        path: '/items/create',
        name: 'create-item',
        builder: (context, state) {
          return BlocProvider(create: (context) => sl<ItemBloc>(), child: const CreateItemPage());
        },
      ),
      GoRoute(
        path: '/items/:id/edit',
        name: 'edit-item',
        builder: (context, state) {
          final item = state.extra as Item;
          return BlocProvider(
            create: (context) => sl<ItemBloc>(),
            child: EditItemPage(item: item),
          );
        },
      ),
    ],

    // Error page
    errorBuilder: (context, state) => const SplashPage(),
  );
}
