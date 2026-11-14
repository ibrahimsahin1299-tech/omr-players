import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/channel.dart';

class M3UService {
  Future<List<Channel>> loadPlaylist(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Playlist indirilemedi.');
    }

    return parsePlaylist(response.body);
  }

  List<Channel> parsePlaylist(String text) {
    text = text.replaceFirst('\uFEFF', '');

    final List<Channel> channels = [];

    final lines = const LineSplitter().convert(text);

    String name = '';
    String logo = '';
    String group = '';

    for (final line in lines) {
      if (line.startsWith('#EXTINF')) {
        final logoMatch =
            RegExp(r'tvg-logo="([^"]*)"').firstMatch(line);

        final groupMatch =
            RegExp(r'group-title="([^"]*)"').firstMatch(line);

        logo = logoMatch?.group(1) ?? '';
        group = groupMatch?.group(1) ?? '';

        name = line.split(',').last.trim();
      } else if (!line.startsWith('#') &&
          line.trim().isNotEmpty) {
        if (name.isEmpty) continue;

        channels.add(
          Channel(
            name: name,
            url: line.trim(),
            logo: logo,
            group: group,
          ),
        );

        name = '';
        logo = '';
        group = '';
      }
    }

    return channels;
  }
}