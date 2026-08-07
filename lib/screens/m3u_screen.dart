import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class M3UScreen extends StatefulWidget {
  const M3UScreen({super.key});

  @override
  State<M3UScreen> createState() => _M3UScreenState();
}

class _M3UScreenState extends State<M3UScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUrl();
  }

  Future<void> loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _urlController.text = prefs.getString("m3u_url") ?? "";
  }

  Future<void> saveUrl() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      "m3u_url",
      _urlController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("M3U adresi kaydedildi."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("M3U Playlist"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: "M3U URL",
                hintText: "https://example.com/playlist.m3u",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: saveUrl,
                child: const Text("Kaydet"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}