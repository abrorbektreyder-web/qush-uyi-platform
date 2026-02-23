import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ProviderScope stores the state of Riverpod providers
    const ProviderScope(
      child: QushUyiApp(),
    ),
  );
}

class QushUyiApp extends ConsumerWidget {
  const QushUyiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Qush Uyi Platform',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Enforce dark theme for premium look
      theme: AppTheme.premiumDark,
      darkTheme: AppTheme.premiumDark,
      routerConfig: appRouter,
    );
  }
}
