import 'package:flutter/material.dart';

class XtreamScreen extends StatelessWidget {
  const XtreamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xtream Login"),
      ),
      body: const Center(
        child: Text(
          "Buraya Xtream giriş ekranı gelecek.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}