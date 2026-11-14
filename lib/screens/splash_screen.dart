
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget next;

  const SplashScreen({
    super.key,
    required this.next,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.65,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) =>
              widget.next,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 145,
                  height: 145,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 24),

            FadeTransition(
              opacity: _fadeAnimation,
              child: const Column(
                children: [
                  Text(
                    'OMR PLAYERS',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 9),

                  Text(
                    'YOUR ENTERTAINMENT HUB',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 3,
                      color: Color(0xFF8193A8),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: 145,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 2500),
                builder: (context, value, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 4,
                      backgroundColor: const Color(0xFF263448),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF45B8FF),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'INITIALIZING...',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: Color(0xFF8193A8),
              ),
            ),

            const SizedBox(height: 55),
          ],
        ),
      ),
    );
  }
}
