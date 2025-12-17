import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/kgiton_theme_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../item/presentation/bloc/item_bloc.dart';
import '../../../transaction/presentation/bloc/transaction_bloc.dart';
import 'scale_weighing_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../item/presentation/pages/item_page.dart';
import '../../../transaction/presentation/pages/transaction_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

/// Main navigation page with bottom navigation bar
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ItemBloc>()),
        BlocProvider.value(value: sl<CartBloc>()),
        BlocProvider.value(value: sl<TransactionBloc>()),
      ],
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: const [ScaleWeighingPage(), CartPage(), ItemPage(), TransactionPage(), ProfilePage()]),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: KgitonThemeColors.cardBackground,
            selectedItemColor: KgitonThemeColors.primaryGreen,
            unselectedItemColor: KgitonThemeColors.textSecondary,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.scale_outlined), activeIcon: Icon(Icons.scale), label: 'Weighing'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
              BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Items'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Transaction'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
