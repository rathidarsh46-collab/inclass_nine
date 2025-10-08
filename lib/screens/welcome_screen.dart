import 'dart:math';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.96, end: 1.04)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_pulse);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final shortest = size.shortestSide;
    final titleSize = shortest * 0.085;

    return Scaffold(
      body: Stack(
        children: [
          // Spooky gradient sky
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B0F1A), Color(0xFF1A1030)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Faint moon
          Positioned(
            right: size.width * 0.15,
            top: size.height * 0.12,
            child: Container(
              width: shortest * 0.22,
              height: shortest * 0.22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x44FFFFFF),
                    blurRadius: 40,
                    spreadRadius: 8,
                  )
                ],
                color: Color(0x33FFFFFF),
              ),
            ),
          ),
          // Title
          Center(
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome to my',
                    style: TextStyle(
                      fontSize: titleSize * 0.6,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [Color(0xFFFF6A00), Color(0xFFFFC107)],
                    ).createShader(rect),
                    child: Text(
                      'Spooky World',
                      style: TextStyle(
                        fontSize: titleSize * 1.1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // “Continue” arrow (Hero -> next screen)
          Positioned(
            right: 24,
            bottom: 24 + MediaQuery.of(context).padding.bottom,
            child: Hero(
              tag: 'arrow-next',
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: () => Navigator.of(context).pushNamed('/game'),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Enter the story'),
              ),
            ),
          ),
          // Tiny drifting stars (just for vibe)
          ...List.generate(24, (i) => _StarDot(key: ValueKey(i))),
        ],
      ),
    );
  }
}

class _StarDot extends StatefulWidget {
  const _StarDot({super.key});

  @override
  State<_StarDot> createState() => _StarDotState();
}

class _StarDotState extends State<_StarDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _anim;
  final rnd = Random();

  late double left;
  late double top;
  late double size;

  @override
  void initState() {
    super.initState();
    left = rnd.nextDouble() * 360 + rnd.nextDouble() * 200;
    top = rnd.nextDouble() * 640;
    size = rnd.nextDouble() * 2.5 + 1;

    _ctl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 4000 + rnd.nextInt(3000)),
    )..repeat(reverse: true);

    _anim = CurvedAnimation(parent: _ctl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Positioned(
        left: left + (sin(_anim.value * 2 * pi) * 6),
        top: top + (cos(_anim.value * 2 * pi) * 3),
        child: Opacity(
          opacity: 0.6 + 0.4 * _anim.value,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}