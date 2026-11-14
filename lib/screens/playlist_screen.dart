import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/channel.dart';
import '../services/m3u_service.dart';
import 'channels_screen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  static const _prefsKey = 'playlist_url';

  final TextEditingController _urlController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _restoreSavedUrl();
  }

  Future<void> _restoreSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == null || saved.isEmpty || !mounted) return;

    _urlController.text = saved;

    // Açılışta kayıtlı listeyi otomatik yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadPlaylist();
    });
  }

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
      final List<Channel> channels = await M3UService().loadPlaylist(url);

      // Başarılı yüklemeden sonra linki hatırla
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, url);

      if (!mounted) return;

      // Sert kayma yerine yumuşak geçiş (fade)
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => ChannelsScreen(channels: channels),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
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
      backgroundColor: const Color(0xFF0B0B0F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'OMR Player',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Oynatma listeni ekle',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _TvTextField(
                    controller: _urlController,
                    hint: 'https://example.com/playlist.m3u',
                    onSubmitted: (_) => _loading ? null : _loadPlaylist(),
                  ),
                  const SizedBox(height: 24),
                  _TvButton(
                    label: 'Yükle',
                    loading: _loading,
                    onPressed: _loading ? null : _loadPlaylist,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Odaklanınca hafifçe büyüyen, çerçevesi parlayan metin alanı.
class _TvTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  const _TvTextField({
    required this.controller,
    required this.hint,
    this.onSubmitted,
  });

  @override
  State<_TvTextField> createState() => _TvTextFieldState();
}

class _TvTextFieldState extends State<_TvTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      child: AnimatedScale(
        scale: _focused ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C22),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _focused
                  ? Colors.white.withOpacity(0.9)
                  : Colors.transparent,
              width: 2,
            ),
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
          child: TextField(
            controller: widget.controller,
            onSubmitted: widget.onSubmitted,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.go,
            style: const TextStyle(fontSize: 18, color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: Color(0xFF636366)),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// tvOS tarzı: normalde yarı saydam gri, odaklanınca beyaz ve büyük.
class _TvButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const _TvButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  State<_TvButton> createState() => _TvButtonState();
}

class _TvButtonState extends State<_TvButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final bg = _focused ? Colors.white : const Color(0xFF2C2C32);
    final fg = _focused ? Colors.black : Colors.white;

    return FocusableActionDetector(
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      onShowHoverHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _focused ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
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
            child: widget.loading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: fg,
                    ),
                  )
                : Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
