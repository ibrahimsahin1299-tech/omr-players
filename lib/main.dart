import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const OMRPlayersApp());
}

class OMRPlayersApp extends StatelessWidget {
  const OMRPlayersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OMR Players',
      theme: AppTheme.dark,
      home: const LoginScreen(),
    );
  }
}