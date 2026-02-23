import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/bird_detail_screen.dart';
import '../../features/home/data/bird_model.dart';
import '../../features/add_listing/presentation/add_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/shop/presentation/shop_screen.dart';
import '../../features/profile/presentation/orders_screen.dart';

class CustomAnimatedPage extends CustomTransitionPage {
  CustomAnimatedPage({required Widget child})
      : super(
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
}

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavBar({required this.child, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Bosh sahifa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              activeIcon: Icon(Icons.add_circle),
              label: "E'lon berish"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/add')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0; // standard home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/add');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              CustomAnimatedPage(child: const HomeScreen()),
        ),
        GoRoute(
          path: '/home/detail',
          pageBuilder: (context, state) {
            final bird = state.extra as BirdModel;
            return CustomAnimatedPage(child: BirdDetailScreen(bird: bird));
          },
        ),
        GoRoute(
          path: '/shop',
          pageBuilder: (context, state) =>
              CustomAnimatedPage(child: const ShopScreen()),
        ),
        GoRoute(
          path: '/add',
          pageBuilder: (context, state) =>
              CustomAnimatedPage(child: const AddScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              CustomAnimatedPage(child: const ProfileScreen()),
        ),
        GoRoute(
          path: '/profile/settings',
          pageBuilder: (context, state) =>
              CustomAnimatedPage(child: const SettingsScreen()),
        ),
        GoRoute(
          path: '/orders',
          pageBuilder: (context, state) =>
              CustomAnimatedPage(child: const OrdersScreen()),
        ),
      ],
    ),
  ],
);
