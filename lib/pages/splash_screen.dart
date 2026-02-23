import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
//  COLOR PALETTE
// ─────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF6C63FF);
const _kViolet = Color(0xFFBB86FC);
const _kDeepBg = Color(0xFF05050F);
const _kMidBg = Color(0xFF0D0D1E);

// ─────────────────────────────────────────────────────────────
//  SPLASH SCREEN
// ─────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Orb background rotation ───────────────────────────────
  late final AnimationController _orbCtrl;

  // ── Logo: scale + fade in ─────────────────────────────────
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _glowOpacity;

  // ── Logo ring pulse ───────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  // ── Text: slide up + fade in ──────────────────────────────
  late final AnimationController _textCtrl;
  late final Animation<double> _textOffset;
  late final Animation<double> _textOpacity;

  // ── Tagline ───────────────────────────────────────────────
  late final AnimationController _tagCtrl;
  late final Animation<double> _tagOpacity;

  // ── Bottom shimmer bar ────────────────────────────────────
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerX;

  @override
  void initState() {
    super.initState();

    // ── Orb slow rotation (looping) ───────────────────────────
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // ── Logo entrance (600 ms, starts at 300 ms) ──────────────
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut);
    _logoOpacity = CurvedAnimation(
      parent: _logoCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _glowOpacity = CurvedAnimation(
      parent: _logoCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    // ── Pulse (looping after logo appears) ────────────────────
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulseScale = Tween(
      begin: 1.0,
      end: 1.8,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
    _pulseOpacity = Tween(
      begin: 0.45,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    // ── Text slide-up (500 ms) ────────────────────────────────
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOffset = Tween(
      begin: 40.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);

    // ── Tagline fade (400 ms) ─────────────────────────────────
    _tagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tagOpacity = CurvedAnimation(parent: _tagCtrl, curve: Curves.easeIn);

    // ── Shimmer bar ───────────────────────────────────────────
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _shimmerX = Tween(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

    // ── Sequence start ────────────────────────────────────────
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 250));

    // Logo zoom in
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));

    // Start looping pulse halo
    _pulseCtrl.repeat();

    // Slide up the app name
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));

    // Fade in tagline
    _tagCtrl.forward();

    // Start shimmer after tagline
    await Future.delayed(const Duration(milliseconds: 200));
    _shimmerCtrl.repeat();
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _textCtrl.dispose();
    _tagCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _kDeepBg,
      body: Stack(
        children: [
          // ── Layer 1: animated orb background ───────────────
          AnimatedBuilder(
            animation: _orbCtrl,
            builder: (_, _) => CustomPaint(
              size: Size(size.width, size.height),
              painter: _OrbPainter(_orbCtrl.value),
            ),
          ),

          // ── Layer 2: centre content ─────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo ──────────────────────────────────────
                _buildLogo(),

                const SizedBox(height: 32),

                // ── App name ──────────────────────────────────
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, _) => Transform.translate(
                    offset: Offset(0, _textOffset.value),
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: _buildAppName(),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Tagline ───────────────────────────────────
                AnimatedBuilder(
                  animation: _tagCtrl,
                  builder: (_, _) => Opacity(
                    opacity: _tagOpacity.value,
                    child: _buildTagline(),
                  ),
                ),
              ],
            ),
          ),

          // ── Layer 3: bottom shimmer loading bar ─────────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: _buildShimmerBar(size),
          ),

          // ── Layer 4: bottom version text ────────────────────
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _tagCtrl,
              builder: (_, _) => Opacity(
                opacity: _tagOpacity.value,
                child: Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.25),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Logo with glow + pulse ring ──────────────────────────
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoCtrl, _pulseCtrl]),
      builder: (_, _) {
        return SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse halo
              Opacity(
                opacity: _pulseOpacity.value * _glowOpacity.value,
                child: Transform.scale(
                  scale: _pulseScale.value,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _kPurple, width: 2),
                    ),
                  ),
                ),
              ),

              // Glow blur circle
              Opacity(
                opacity: _glowOpacity.value * 0.6,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _kPurple.withValues(alpha: 0.7),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),

              // Logo icon container
              Transform.scale(
                scale: _logoScale.value.clamp(0.0, 1.0),
                child: Opacity(
                  opacity: _logoOpacity.value,
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [_kPurple, Color(0xFF9B5DE5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _kPurple.withValues(alpha: 0.5),
                          blurRadius: 24,
                          spreadRadius: 4,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.blur_circular_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── App name ──────────────────────────────────────────────
  Widget _buildAppName() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFFFFFF), _kViolet],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        'circlo',
        style: GoogleFonts.poppins(
          fontSize: 46,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
          color: Colors.white, // masked by ShaderMask
        ),
      ),
    );
  }

  // ─── Tagline ───────────────────────────────────────────────
  Widget _buildTagline() {
    return Column(
      children: [
        // Dot divider
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _kPurple.withValues(alpha: 0.7 - i * 0.2),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          'Share your world, connect deeper.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 0.3,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ─── Shimmer loading bar ───────────────────────────────────
  Widget _buildShimmerBar(Size size) {
    const barW = 120.0;
    const barH = 3.0;

    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (_, _) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(barH),
            child: Container(
              width: barW,
              height: barH,
              color: Colors.white.withValues(alpha: 0.08),
              child: Stack(
                children: [
                  Positioned(
                    left: _shimmerX.value * barW - barW * 0.4,
                    child: Container(
                      width: barW * 0.4,
                      height: barH,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(barH),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            _kPurple.withValues(alpha: 0.9),
                            _kViolet,
                            _kPurple.withValues(alpha: 0.9),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ORB BACKGROUND PAINTER
// ─────────────────────────────────────────────────────────────
class _OrbPainter extends CustomPainter {
  final double t; // 0.0 → 1.0 (loops)

  _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final angle = t * 2 * math.pi;

    // ── Gradient background ─────────────────────────────────
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [_kDeepBg, _kMidBg],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // ── Top-left large orb (purple) ─────────────────────────
    final orb1x = cx * 0.35 + math.cos(angle) * 30;
    final orb1y = cy * 0.45 + math.sin(angle) * 20;
    _drawOrb(
      canvas,
      orb1x,
      orb1y,
      size.width * 0.65,
      _kPurple.withValues(alpha: 0.18),
    );

    // ── Bottom-right orb (violet) ───────────────────────────
    final orb2x = cx * 1.65 + math.cos(angle + math.pi) * 25;
    final orb2y = cy * 1.55 + math.sin(angle + math.pi) * 20;
    _drawOrb(
      canvas,
      orb2x,
      orb2y,
      size.width * 0.6,
      _kViolet.withValues(alpha: 0.12),
    );

    // ── Top-right small accent orb ──────────────────────────
    final orb3x = cx * 1.7 + math.cos(angle * 1.3) * 18;
    final orb3y = cy * 0.3 + math.sin(angle * 1.3) * 15;
    _drawOrb(
      canvas,
      orb3x,
      orb3y,
      size.width * 0.35,
      const Color(0xFF03DAC6).withValues(alpha: 0.08),
    );

    // ── Bottom-left tiny orb ────────────────────────────────
    final orb4x = cx * 0.25 + math.cos(angle * 0.8 + 2) * 15;
    final orb4y = cy * 1.7 + math.sin(angle * 0.8 + 2) * 12;
    _drawOrb(
      canvas,
      orb4x,
      orb4y,
      size.width * 0.28,
      _kPurple.withValues(alpha: 0.10),
    );

    // ── Subtle grid dots ────────────────────────────────────
    _drawDotGrid(canvas, size);
  }

  void _drawOrb(Canvas canvas, double x, double y, double r, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r));
    canvas.drawCircle(Offset(x, y), r, paint);
  }

  void _drawDotGrid(Canvas canvas, Size size) {
    const spacing = 36.0;
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..style = PaintingStyle.fill;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}
