import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'screens/playlist_screen.dart';

void main() {
  MediaKit.ensureInitialized();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlaylistScreen(),
    ),
  );
}