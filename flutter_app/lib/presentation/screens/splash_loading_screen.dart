import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/localization.dart';

class SplashLoadingScreen extends ConsumerStatefulWidget {
  const SplashLoadingScreen({super.key});

  @override
  ConsumerState<SplashLoadingScreen> createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends ConsumerState<SplashLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _samiScaleAnimation;
  late Animation<double> _samiFadeAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _sloganFadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // 3-second splash loading duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // SAMI entrance: 0ms to 600ms (0.0 to 0.20)
    _samiScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.22, curve: Curves.easeOutBack),
      ),
    );

    _samiFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.16, curve: Curves.easeOut),
      ),
    );

    // QUIVO logo entrance: 400ms to 900ms (0.13 to 0.30)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.14, 0.30, curve: Curves.easeOut),
      ),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.14, 0.32, curve: Curves.easeOutCubic),
      ),
    );

    // Slogan entrance: 700ms to 1200ms (0.23 to 0.40)
    _sloganFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.24, 0.40, curve: Curves.easeOut),
      ),
    );

    // Progress bar fills linearly from 0.0 to 1.0 across full 3 seconds
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.95, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateNext();
      }
    });
  }

  void _navigateNext() {
    if (!mounted) return;
    final isAuth = ref.read(authProvider).isAuthenticated;
    if (isAuth) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationProvider);
    final slogan = loc.get('app_slogan').isNotEmpty && loc.get('app_slogan') != 'app_slogan'
        ? loc.get('app_slogan')
        : 'Todo gran ahorro empieza como una semilla';

    return Scaffold(
      backgroundColor: const Color(0xFF060D1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background luxury dark navy gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF040812),
                  Color(0xFF081226),
                  Color(0xFF0A1730),
                  Color(0xFF050A16),
                ],
                stops: [0.0, 0.35, 0.70, 1.0],
              ),
            ),
          ),

          // Ambient radial glows in background
          Positioned(
            top: MediaQuery.of(context).size.height * 0.28,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final glowPulse = 0.85 + 0.15 * math.sin(_controller.value * 4 * math.pi);
                  return Container(
                    width: 280 * glowPulse,
                    height: 280 * glowPulse,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00E5FF).withValues(alpha: 0.14),
                          const Color(0xFF10B981).withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Central Content: Mascot + Logo + Slogan
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // SAMI Mascot with gentle breathing & floating animation
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final floatY = math.sin(_controller.value * 3 * math.pi) * 8.0;
                    final tilt = math.sin(_controller.value * 3 * math.pi) * 0.025;
                    return Transform.translate(
                      offset: Offset(0, floatY),
                      child: Transform.rotate(
                        angle: tilt,
                        child: Transform.scale(
                          scale: _samiScaleAnimation.value,
                          child: Opacity(
                            opacity: _samiFadeAnimation.value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 240,
                        maxHeight: 180,
                      ),
                      child: Image.asset(
                        'assets/images/sami_bienvenida.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Brand Logo QUIVO with leaf O
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _logoSlideAnimation,
                      child: Opacity(
                        opacity: _logoFadeAnimation.value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Center(
                    child: Image.asset(
                      'assets/images/quivo_logo_leaf.png',
                      height: 44,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Brand Slogan: "Todo gran ahorro empieza como una semilla"
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _sloganFadeAnimation.value.clamp(0.0, 1.0),
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      slogan,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.35,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Modern glowing progress bar at bottom
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _controller.value > 0.08 ? 1.0 : 0.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 170,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 170 * _progressAnimation.value.clamp(0.0, 1.0),
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF06B6D4),
                                    Color(0xFF38BDF8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF06B6D4).withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
