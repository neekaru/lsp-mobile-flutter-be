import 'package:flutter/material.dart';

import 'core/navigation/main_navigator.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'LSP Monitoring',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
