import 'package:flutter/material.dart';

import '../models/channel.dart';
import 'player_screen.dart';

const _bg = Color(0xFF0B0B0F);
const _surface = Color(0xFF1C1C22);
const _surfaceHigh = Color(0xFF2C2C32);
const _textSecondary = Color(0xFF8E8E93);

class ChannelsScreen extends StatefulWidget {
  final List<Channel> channels;

  const ChannelsScreen({
    super.key,
    required this.channels,
  });

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  static const _allLabel = 'Tümü';

  late final List<String> _groups;
  late List<Channel> _visible;
  String _selected = _allLabel;

  String _groupOf(Channel c) => c.group.trim().isEmpty ? 'Diğer' : c.group.trim();

  @override
  void initState() {
    super.initState();
    final set = <String>{};
    for (final c in widget.channels) {
      set.add(_groupOf(c));
    }
    _groups = [_allLabel, ...set];
    _visible = widget.channels;
  }

  void _select(String group) {
    if (group == _selected) return;
    setState(() {
      _selected = group;
      _visible = group == _allLabel
          ? widget.channels
          : widget.channels.where((c) => _groupOf(c) == group).toList();
    });
  }

  void _open(Channel channel) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => PlayerScreen(
          url: channel.url,
          title: channel.name,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: widget.channels.isEmpty
            ? const Center(
                child: Text(
                  'Kanal bulunamadı',
                  style: TextStyle(fontSize: 20, color: _textSecondary),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(56, 32, 56, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          'Kanallar',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${_visible.length}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Grup seçici
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 56,
                        vertical: 18,
                      ),
                      itemCount: _groups.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (_, i) {
                        final g = _groups[i];
                        final selected = g == _selected;
                        return _TvFocusable(
                          onTap: () => _select(g),
                          scale: 1.08,
                          builder: (context, focused) => AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            decoration: BoxDecoration(
                              color: selected || focused
                                  ? Colors.white
                                  : _surfaceHigh,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: focused ? _focusShadow : const [],
                            ),
                            child: Text(
                              g,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: selected || focused
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Kanal ızgarası
                  Expanded(
                    child: _visible.isEmpty
                        ? const Center(
                            child: Text(
                              'Bu grupta kanal yok',
                              style: TextStyle(
                                fontSize: 18,
                                color: _textSecondary,
                              ),
                            ),
                          )
                        : GridView.builder(
                            clipBehavior: Clip.none,
                            padding: const EdgeInsets.fromLTRB(56, 20, 56, 48),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 230,
                              mainAxisSpacing: 28,
                              crossAxisSpacing: 28,
                              childAspectRatio: 1.15,
                            ),
                            itemCount: _visible.length,
                            itemBuilder: (_, i) {
                              final channel = _visible[i];
                              return _ChannelCard(
                                key: ValueKey('${_selected}_$i'),
                                channel: channel,
                                autofocus: i == 0,
                                onTap: () => _open(channel),
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

final _focusShadow = [
  BoxShadow(
    color: Colors.black.withOpacity(0.55),
    blurRadius: 30,
    offset: const Offset(0, 16),
  ),
];

/// Kumanda, klavye ve dokunmayı destekleyen, odaklanınca büyüyen sarmalayıcı.
class _TvFocusable extends StatefulWidget {
  final Widget Function(BuildContext context, bool focused) builder;
  final VoidCallback onTap;
  final bool autofocus;
  final double scale;

  const _TvFocusable({
    required this.builder,
    required this.onTap,
    this.autofocus = false,
    this.scale = 1.07,
  });

  @override
  State<_TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<_TvFocusable> {
  bool _focused = false;

  void _onFocus(bool value) {
    setState(() => _focused = value);
    if (value) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: widget.autofocus,
      onShowFocusHighlight: _onFocus,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _focused ? widget.scale : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: widget.builder(context, _focused),
        ),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final Channel channel;
  final bool autofocus;
  final VoidCallback onTap;

  const _ChannelCard({
    super.key,
    required this.channel,
    required this.onTap,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return _TvFocusable(
      autofocus: autofocus,
      onTap: onTap,
      builder: (context, focused) => AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: focused ? Colors.white.withOpacity(0.9) : Colors.transparent,
            width: 2,
          ),
          boxShadow: focused ? _focusShadow : const [],
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(child: _Logo(url: channel.logo)),
            ),
            const SizedBox(height: 10),
            Text(
              channel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  final String url;

  const _Logo({required this.url});

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(Icons.tv_rounded, size: 40, color: _textSecondary);

    if (url.isEmpty) return fallback;

    return Image.network(
      url,
      fit: BoxFit.contain,
      cacheWidth: 200, // bellekte küçük tut, kaydırma akıcı kalsın
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSync) {
        if (wasSync) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
