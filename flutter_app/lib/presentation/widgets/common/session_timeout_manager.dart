import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/routing/app_router.dart';
import '../../providers/auth_provider.dart';

class SessionTimeoutManager extends ConsumerStatefulWidget {
  final Widget child;
  const SessionTimeoutManager({super.key, required this.child});

  @override
  ConsumerState<SessionTimeoutManager> createState() =>
      _SessionTimeoutManagerState();
}

class _SessionTimeoutManagerState extends ConsumerState<SessionTimeoutManager>
    with WidgetsBindingObserver {
  Timer? _inactivityTimer;
  DateTime? _pausedTime;
  bool _isBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (!_isBackgrounded && mounted) {
        setState(() => _isBackgrounded = true);
      }
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.hidden) {
        _pausedTime ??= DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isBackgrounded && mounted) {
        setState(() => _isBackgrounded = false);
      }
      if (_pausedTime != null) {
        final elapsed = DateTime.now().difference(_pausedTime!);
        _pausedTime = null;
        final authState = ref.read(authProvider);
        // Si el usuario sale de la app estando autenticado por más de 4s,
        // reinicia la protección enviando a la pantalla de carga y login
        if (authState.isAuthenticated && elapsed.inSeconds >= 4) {
          final context = AppRouter.rootNavigatorKey.currentContext;
          if (context != null && context.mounted) {
            GoRouter.of(context).go('/splash');
          }
        }
      }
    }
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      final mins = authState.user?.autoLockMinutes ?? 1;
      _inactivityTimer = Timer(Duration(minutes: mins), () => _onTimeout(mins));
    }
  }

  void _onTimeout(int mins) {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) return;

    // Cierre automático de sesión por inactividad
    ref.read(authProvider.notifier).logout();

    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      GoRouter.of(context).go('/login');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.horizontal,
          content: Row(
            children: [
              const Icon(
                LucideIcons.shieldAlert,
                color: Colors.amberAccent,
                size: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔒 Sesión Expirada por Privacidad',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tu sesión se cerró automáticamente tras $mins minuto${mins > 1 ? 's' : ''} de inactividad.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1E1B4B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 5),
          elevation: 10,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      final prevAuth = previous?.isAuthenticated ?? false;
      final prevMins = previous?.user?.autoLockMinutes ?? 1;
      final nextMins = next.user?.autoLockMinutes ?? 1;
      if ((next.isAuthenticated && !prevAuth) ||
          (next.isAuthenticated && prevMins != nextMins)) {
        _resetTimer();
      } else if (!next.isAuthenticated) {
        _inactivityTimer?.cancel();
      }
    });

    return Listener(
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerUp: (_) => _resetTimer(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          widget.child,
          if (_isBackgrounded &&
              ref.watch(authProvider.select((s) => s.isAuthenticated)))
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF040812),
                      Color(0xFF081326),
                      Color(0xFF050B17),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Card luminosa que resalta el logo oficial de QUIVO con máxima nitidez
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 22,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.28),
                                blurRadius: 36,
                                spreadRadius: 4,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.40),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/quivo_logo_full.png',
                            width: 210,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Badge elegante de seguridad
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.lock,
                                color: Color(0xFF34D399),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Privacidad Protegida',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
