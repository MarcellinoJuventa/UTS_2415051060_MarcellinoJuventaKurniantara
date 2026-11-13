import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const NorthApp());
}

class NorthApp extends StatelessWidget {
  const NorthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${AppConfig.appName} - ${AppConfig.appTagline}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ProfileScreen(),
    );
  }
}
