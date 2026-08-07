import 'package:flutter/material.dart';

import 'm3u_screen.dart';
import 'xtream_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_circle_fill_rounded,
                color: Color(0xFF00D9FF),
                size: 120,
              ),

              const SizedBox(height: 25),

              const Text(
                "OMR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),

              const Text(
                "PLAYERS",
                style: TextStyle(
                  color: Color(0xFF00D9FF),
                  fontSize: 22,
                  letterSpacing: 8,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Your Media. Your Control.",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.language),
                  label: const Text("M3U ile Giriş"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const M3UScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.lock_outline),
                  label: const Text("Xtream Giriş"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const XtreamScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text("Dosyadan Yükle"),
                  onPressed: () {},
                ),
              ),

              const SizedBox(height: 60),

              const Text(
                "OMR Players v0.0.1",
                style: TextStyle(color: Colors.white30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}