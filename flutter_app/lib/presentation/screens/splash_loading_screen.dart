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
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _waveController;
  late Animation<double> _samiScaleAnimation;
  late Animation<double> _samiFadeAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _sloganFadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // 5-second splash loading duration as requested
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // Fast repeating controller for SAMI's hand waving animation (~500ms cycle)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..repeat(reverse: true);

    // SAMI entrance: 0ms to 700ms
    _samiScaleAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.16, curve: Curves.easeOutBack),
      ),
    );

    _samiFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.12, curve: Curves.easeOut),
      ),
    );

    // QUIVO logo entrance: 500ms to 1200ms
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 0.24, curve: Curves.easeOut),
      ),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.10, 0.26, curve: Curves.easeOutCubic),
      ),
    );

    // Slogan entrance: 1000ms to 1800ms
    _sloganFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.35, curve: Curves.easeOut),
      ),
    );

    // Progress bar fills smoothly from 0.0 to 1.0 across full 5 seconds
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.04, 0.96, curve: Curves.easeInOutCubic),
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
    _waveController.dispose();
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
            top: MediaQuery.of(context).size.height * 0.26,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final glowPulse = 0.85 + 0.15 * math.sin(_controller.value * 6 * math.pi);
                  return Container(
                    width: 290 * glowPulse,
                    height: 290 * glowPulse,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00E5FF).withValues(alpha: 0.16),
                          const Color(0xFF10B981).withValues(alpha: 0.09),
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

                // SAMI Mascot with active hand-waving and floating animation
                AnimatedBuilder(
                  animation: Listenable.merge([_controller, _waveController]),
                  builder: (context, child) {
                    // Floating vertical movement
                    final floatY = math.sin(_controller.value * 5 * math.pi) * 8.0;
                    // Rhythmic hand wave rotation: pivots around the lower center to swing the raised hand back and forth!
                    final waveAngle = (math.sin(_waveController.value * math.pi) - 0.5) * 0.18;
                    // Subtle hand bounce
                    final handPulse = 1.0 + 0.04 * math.sin(_waveController.value * math.pi);

                    return Transform.translate(
                      offset: Offset(0, floatY),
                      child: Transform.scale(
                        scale: _samiScaleAnimation.value * handPulse,
                        child: Transform.rotate(
                          angle: waveAngle,
                          alignment: const Alignment(-0.2, 0.7), // Pivots near SAMI's waist/shoulder
                          child: Opacity(
                            opacity: _samiFadeAnimation.value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          constraints: const BoxConstraints(
                            maxWidth: 245,
                            maxHeight: 185,
                          ),
                          child: Image.asset(
                            'assets/images/sami_bienvenida.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        // Animated waving stars / sparkles near waving hand
                        Positioned(
                          top: 10,
                          left: 12,
                          child: AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, _) {
                              final sparkScale = 0.8 + 0.35 * _waveController.value;
                              return Transform.scale(
                                scale: sparkScale,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    size: 16,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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

                // Modern glowing progress bar at bottom (5 seconds)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _controller.value > 0.05 ? 1.0 : 0.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 180,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 180 * _progressAnimation.value.clamp(0.0, 1.0),
                              height: 4.5,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF06B6D4),
                                    Color(0xFF38BDF8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF06B6D4).withValues(alpha: 0.65),
                                    blurRadius: 10,
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
