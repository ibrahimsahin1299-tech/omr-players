import 'package:flutter/material.dart';

import '../models/channel.dart';
import '../services/m3u_service.dart';
import 'channels_screen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final TextEditingController _urlController = TextEditingController();

  bool _loading = false;

  Future<void> _loadPlaylist() async {
    final url = _urlController.text.trim();

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('M3U URL giriniz'),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final List<Channel> channels =
          await M3UService().loadPlaylist(url);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChannelsScreen(
            channels: channels,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
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
        title: const Text('OMR Player'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'M3U URL',
                hintText: 'https://example.com/playlist.m3u',
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _loadPlaylist,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('YÜKLE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}