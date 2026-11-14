import 'package:flutter/material.dart';

import '../models/channel.dart';
import 'player_screen.dart';

class ChannelsScreen extends StatelessWidget {
  final List<Channel> channels;

  const ChannelsScreen({
    super.key,
    required this.channels,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kanallar (${channels.length})'),
      ),
      body: channels.isEmpty
          ? const Center(
              child: Text('Kanal bulunamadı'),
            )
          : ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];

                return ListTile(
                  leading: channel.logo.isNotEmpty
                      ? Image.network(
                          channel.logo,
                          width: 50,
                          height: 50,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.tv),
                        )
                      : const Icon(Icons.tv),

                  title: Text(channel.name),

                  subtitle: Text(channel.group),

                  trailing: const Icon(Icons.play_arrow),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                          url: channel.url,
                          title: channel.name,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}