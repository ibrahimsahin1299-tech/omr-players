import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/channel.dart';
import '../services/m3u_service.dart';

class M3UScreen extends StatefulWidget {
  const M3UScreen({super.key});

  @override
  State<M3UScreen> createState() => _M3UScreenState();
}

class _M3UScreenState extends State<M3UScreen> {
  final TextEditingController _urlController = TextEditingController();

  final M3UService _service = M3UService();

  List<Channel> channels = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();

    _urlController.text = prefs.getString("m3u_url") ?? "";
  }

  Future<void> _connect() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      "m3u_url",
      _urlController.text,
    );

    setState(() {
      loading = true;
    });

    try {
      final result = await _service.loadPlaylist(
        _urlController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        channels = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${result.length} kanal bulundu"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
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
                labelText: "Playlist URL",
                hintText: "https://example.com/playlist.m3u",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : _connect,
                child: const Text("Bağlan"),
              ),
            ),

            const SizedBox(height: 20),

            if (loading)
              const CircularProgressIndicator(),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: channels.length,
                itemBuilder: (context, index) {
                  final channel = channels[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.live_tv),
                      title: Text(channel.name),
                      subtitle: Text(channel.group),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(channel.name),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}