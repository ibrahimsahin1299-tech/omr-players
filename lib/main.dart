
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'screens/splash_screen.dart';
import 'screens/playlist_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(const OMRPlayersApp());
}

class OMRPlayersApp extends StatelessWidget {
  const OMRPlayersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      ),
      home: SplashScreen(
        next: PlaylistScreen(),
      ),
    );
  }
}
