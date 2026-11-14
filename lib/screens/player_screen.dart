import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PlayerScreen extends StatefulWidget {
  final String url;
  final String title;

  const PlayerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final Player player;
  late final VideoController controller;

  final FocusNode _rootFocus = FocusNode(debugLabel: 'player-root');
  final FocusNode _playFocus = FocusNode(debugLabel: 'player-play');

  final List<StreamSubscription> _subs = [];
  Timer? _hideTimer;

  bool _playing = true;
  bool _buffering = true;
  double _volume = 100;
  String? _error;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();

    // Tam ekran, sistem çubukları gizli
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    player = Player();
    controller = VideoController(player);

    _subs.addAll([
      player.stream.playing.listen((v) {
        if (!mounted) return;
        setState(() => _playing = v);
        if (!v) {
          _show(); // duraklatılınca kontroller açık kalsın
        } else {
          _scheduleHide();
        }
      }),
      player.stream.buffering.listen((v) {
        if (mounted) setState(() => _buffering = v);
      }),
      player.stream.volume.listen((v) {
        if (mounted) setState(() => _volume = v);
      }),
      player.stream.error.listen((e) {
        if (!mounted) return;
        setState(() => _error = e);
        _show();
      }),
    ]);

    player.open(Media(widget.url));

    _scheduleHide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _playFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _rootFocus.dispose();
    _playFocus.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    player.dispose();
    super.dispose();
  }

  // ---------- Kontrollerin görünürlüğü ----------

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !_playing || _error != null) return;
      _hide();
    });
  }

  void _hide() {
    if (!_controlsVisible) return;
    setState(() => _controlsVisible = false);
    _rootFocus.requestFocus();
  }

  void _show() {
    if (!mounted) return;
    if (!_controlsVisible) {
      setState(() => _controlsVisible = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _playFocus.requestFocus();
      });
    }
    _scheduleHide();
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hide();
    } else {
      _show();
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;

    // Geri tuşu normal çalışsın
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.goBack) {
      return KeyEventResult.ignored;
    }

    if (key == LogicalKeyboardKey.mediaPlayPause) {
      player.playOrPause();
      _show();
      return KeyEventResult.handled;
    }

    if (_controlsVisible) {
      _scheduleHide();
      return KeyEventResult.ignored;
    }

    // Kontroller gizliyken herhangi bir tuş sadece onları açar
    _show();
    return KeyEventResult.handled;
  }

  void _toggleMute() {
    player.setVolume(_volume == 0 ? 100 : 0);
    _scheduleHide();
  }

  void _retry() {
    setState(() {
      _error = null;
      _buffering = true;
    });
    player.open(Media(widget.url));
    _scheduleHide();
  }

  // ---------- Arayüz ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: _rootFocus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: MouseRegion(
          onHover: (_) {
            if (_controlsVisible) {
              _scheduleHide();
            } else {
              _show();
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleControls,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Video(
                    controller: controller,
                    controls: NoVideoControls,
                    fill: Colors.black,
                  ),
                ),

                if (_buffering && _error == null)
                  const Center(
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                  ),

                if (_error != null) _buildError(),

                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: ExcludeFocus(
                      excluding: !_controlsVisible,
                      child: AnimatedOpacity(
                        opacity: _controlsVisible ? 1 : 0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        child: _buildControls(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Stack(
      children: [
        // Üst gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 180,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.75),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Alt gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 220,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Üst çubuk: geri + kanal adı
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(48, 28, 48, 0),
              child: Row(
                children: [
                  _PlayerButton(
                    icon: Icons.arrow_back_rounded,
                    size: 56,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 12, color: Colors.black54),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Alt çubuk: oynat/duraklat + ses
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PlayerButton(
                    focusNode: _playFocus,
                    icon: _playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 76,
                    onPressed: () {
                      player.playOrPause();
                      _scheduleHide();
                    },
                  ),
                  const SizedBox(width: 28),
                  _PlayerButton(
                    icon: _volume == 0
                        ? Icons.volume_off_rounded
                        : Icons.volume_up_rounded,
                    size: 56,
                    onPressed: _toggleMute,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Color(0xFF8E8E93),
          ),
          const SizedBox(height: 16),
          const Text(
            'Yayın açılamadı',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bağlantıyı kontrol edip tekrar deneyin.',
            style: TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
          ),
          const SizedBox(height: 28),
          _PlayerButton(
            icon: Icons.refresh_rounded,
            label: 'Tekrar dene',
            size: 56,
            onPressed: _retry,
          ),
        ],
      ),
    );
  }
}

/// tvOS tarzı buton: normalde yarı saydam, odaklanınca beyaz ve büyük.
/// `label` verilirse hap (pill) şeklinde, yoksa daire olur.
class _PlayerButton extends StatefulWidget {
  final IconData icon;
  final String? label;
  final double size;
  final VoidCallback onPressed;
  final FocusNode? focusNode;

  const _PlayerButton({
    required this.icon,
    required this.onPressed,
    this.label,
    this.size = 64,
    this.focusNode,
  });

  @override
  State<_PlayerButton> createState() => _PlayerButtonState();
}

class _PlayerButtonState extends State<_PlayerButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final fg = _focused ? Colors.black : Colors.white;
    final bg = _focused ? Colors.white : Colors.white.withOpacity(0.16);
    final hasLabel = widget.label != null;

    return FocusableActionDetector(
      focusNode: widget.focusNode,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      onShowHoverHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _focused ? 1.12 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: widget.size,
            width: hasLabel ? null : widget.size,
            padding: hasLabel
                ? const EdgeInsets.symmetric(horizontal: 28)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(widget.size / 2),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: widget.size * 0.5, color: fg),
                if (hasLabel) ...[
                  const SizedBox(width: 10),
                  Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
