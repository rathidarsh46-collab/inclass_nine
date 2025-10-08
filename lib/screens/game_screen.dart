// lib/screens/game_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../painters/bat_painter.dart';
import '../painters/ghost_painter.dart';
import '../painters/pumpkin_painter.dart';
import '../painters/candy_painter.dart';

enum SpookyType { ghost, bat, pumpkin, candy } // candy = winning item

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final rnd = Random();

  // Audio
  late final AudioPlayer _bgm;
  late final AudioPlayer _sfx;
  bool _bgmOn = true;
  bool _sfxOn = true;

  // Items + movement
  late List<_MovingItem> _items;
  Timer? _moveTimer;
  bool _found = false;

  // Subtle screen shake on trap
  late final AnimationController _shakeCtl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _bgm = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    _sfx = AudioPlayer();

    _initItems();
    _startBgm();
    _scheduleMoves(); // <- Option A: short timer to constantly retarget

    _shakeCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 8)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeCtl);
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _bgm.stop();
    _bgm.dispose();
    _sfx.dispose();
    _shakeCtl.dispose();
    super.dispose();
  }

  // ------- Items & Movement (Option A) -------

  void _initItems() {
    _items = [
      _MovingItem(type: SpookyType.candy,   isTrap: false, alignment: _randomAlign()),
      _MovingItem(type: SpookyType.ghost,   isTrap: true,  alignment: _randomAlign()),
      _MovingItem(type: SpookyType.ghost,   isTrap: true,  alignment: _randomAlign()),
      _MovingItem(type: SpookyType.bat,     isTrap: true,  alignment: _randomAlign()),
      _MovingItem(type: SpookyType.bat,     isTrap: true,  alignment: _randomAlign()),
      _MovingItem(type: SpookyType.pumpkin, isTrap: false, alignment: _randomAlign()),
      _MovingItem(type: SpookyType.pumpkin, isTrap: false, alignment: _randomAlign()),
    ];
  }

  Alignment _randomAlign() {
    // Keep a margin so items don't go off-screen (-1..1 is full)
    final x = rnd.nextDouble() * 1.6 - 0.8; // -0.8..0.8
    final y = rnd.nextDouble() * 1.6 - 0.8; // -0.8..0.8
    return Alignment(x, y);
  }

  void _scheduleMoves() {
    _moveTimer?.cancel();
    // Short interval to feel "constant". Keep 1200–1800ms per hop.
    _moveTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!mounted || _found) return;
      setState(() {
        for (final it in _items) {
          it.alignment = _randomAlign();
        }
      });
    });
  }

  // ------- Audio -------

  Future<void> _startBgm() async {
    if (_bgmOn) {
      await _bgm.play(AssetSource('audio/spooky_bg.mp3'), volume: 0.5);
    }
  }

  Future<void> _playJump() async {
    if (_sfxOn) {
      await _sfx.play(AssetSource('audio/jumpscare.wav'), volume: 1.0);
    }
  }

  Future<void> _playSuccess() async {
    if (_sfxOn) {
      await _sfx.play(AssetSource('audio/success.wav'), volume: 0.9);
    }
  }

  // ------- Interactions -------

  Future<void> _onTapItem(_MovingItem it) async {
    if (_found) return;

    if (it.type == SpookyType.candy) {
      setState(() => _found = true);
      await _playSuccess();
    } else {
      await _playJump();
      if (!_shakeCtl.isAnimating) {
        _shakeCtl.forward(from: 0).then((_) => _shakeCtl.reverse());
      }
    }
  }

  void _resetGame() {
    setState(() {
      _found = false;
      _initItems();
      _scheduleMoves();
    });
  }

  // ------- UI -------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final shortest = size.shortestSide;
    final baseSize = shortest * 0.17;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _shakeAnim,
        builder: (context, child) {
          final offset = _shakeAnim.value;
          return Transform.translate(
            offset: Offset(rnd.nextBool() ? offset : -offset, 0),
            child: child,
          );
        },
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0B0F1A), Color(0xFF1A1030)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Subtle ground fog
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: size.height * 0.25,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0x1122FF99), Color(0x0055FFAA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Moving items using AnimatedAlign with per-item stagger
            ..._items.map((it) {
              final ms = 1000 + rnd.nextInt(900); // 1000–1900ms per hop
              final curve = rnd.nextBool()
                  ? Curves.easeInOut
                  : Curves.easeInOutCubic;

              return AnimatedAlign(
                key: ValueKey(it),
                alignment: it.alignment,
                duration: Duration(milliseconds: ms),
                curve: curve,
                child: _PulsingGlow(
                  pulse: 1200 + rnd.nextInt(1000),
                  child: GestureDetector(
                    onTap: () => _onTapItem(it),
                    child: RepaintBoundary(
                      child: _SpookyPainted(
                        type: it.type,
                        size: baseSize * (0.85 + rnd.nextDouble() * 0.3),
                        isTrap: it.isTrap,
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Top bar: back + title + audio toggles
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Find the Candy!',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: _bgmOn ? 'Mute Music' : 'Unmute Music',
                      onPressed: () async {
                        setState(() => _bgmOn = !_bgmOn);
                        if (_bgmOn) {
                          _startBgm();
                        } else {
                          await _bgm.pause();
                        }
                      },
                      icon: Icon(_bgmOn ? Icons.music_note : Icons.music_off),
                    ),
                    IconButton(
                      tooltip: _sfxOn ? 'Mute SFX' : 'Unmute SFX',
                      onPressed: () => setState(() => _sfxOn = !_sfxOn),
                      icon: Icon(_sfxOn ? Icons.volume_up : Icons.volume_off),
                    ),
                  ],
                ),
              ),
            ),

            // Win overlay
            if (_found)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _found ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Card(
                          elevation: 12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'You Found It! 🍬',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Congrats, brave soul. Want to go again?',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _resetGame,
                                      icon: const Icon(Icons.replay_rounded),
                                      label: const Text('Play Again'),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          Navigator.of(context).maybePop(),
                                      icon: const Icon(Icons.exit_to_app_rounded),
                                      label: const Text('Exit'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ------- Helpers -------

class _MovingItem {
  _MovingItem({
    required this.type,
    required this.isTrap,
    required this.alignment,
  });

  SpookyType type;
  bool isTrap;
  Alignment alignment;
}

class _PulsingGlow extends StatefulWidget {
  const _PulsingGlow({required this.child, required this.pulse, super.key});
  final Widget child;
  final int pulse;

  @override
  State<_PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<_PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.pulse),
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
      builder: (context, child) {
        final blur = 8 + 10 * _anim.value;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xAAFF6A00).withOpacity(0.35 + 0.25 * _anim.value),
                blurRadius: blur,
                spreadRadius: 1.0 + _anim.value * 2.0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SpookyPainted extends StatelessWidget {
  const _SpookyPainted({
    required this.type,
    required this.size,
    required this.isTrap,
  });

  final SpookyType type;
  final double size;
  final bool isTrap;

  @override
  Widget build(BuildContext context) {
    CustomPainter painter;
    switch (type) {
      case SpookyType.ghost:
        painter = GhostPainter();
        break;
      case SpookyType.bat:
        painter = BatPainter();
        break;
      case SpookyType.pumpkin:
        painter = PumpkinPainter();
        break;
      case SpookyType.candy:
        painter = CandyPainter();
        break;
    }

    final label = switch (type) {
      SpookyType.candy => 'The Candy (WIN)',
      SpookyType.ghost => 'Ghost (Trap!)',
      SpookyType.bat => 'Bat (Trap!)',
      SpookyType.pumpkin => 'Pumpkin',
    };

    return Tooltip(
      message: label,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: painter),
      ),
    );
  }
}
