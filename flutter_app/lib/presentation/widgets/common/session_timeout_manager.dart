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
  ConsumerState<SessionTimeoutManager> createState() => _SessionTimeoutManagerState();
}

class _SessionTimeoutManagerState extends ConsumerState<SessionTimeoutManager> {
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
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
          content: Row(
            children: [
              const Icon(LucideIcons.shieldAlert, color: Colors.amberAccent, size: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔒 Sesión Expirada por Privacidad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('Tu sesión se cerró automáticamente tras $mins minuto${mins > 1 ? 's' : ''} de inactividad.', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1E1B4B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      if ((next.isAuthenticated && !prevAuth) || (next.isAuthenticated && prevMins != nextMins)) {
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
      child: widget.child,
    );
  }
}
