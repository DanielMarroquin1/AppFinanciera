import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_provider.dart';
import '../utils/app_haptics.dart';

/// Servicio global para rastrear el tiempo de permanencia del usuario en la app.
/// Si el usuario pasa más de 45 segundos dentro de la app, su racha se enciende automáticamente.
class StreakSessionService {
  static final StreakSessionService _instance = StreakSessionService._internal();
  factory StreakSessionService() => _instance;
  StreakSessionService._internal();

  static const int activationThresholdSeconds = 45;
  static int elapsedSeconds = 0;
  static Timer? _timer;
  static final ValueNotifier<int> secondsNotifier = ValueNotifier<int>(0);
  static final ValueNotifier<bool> autoActivatedNotifier = ValueNotifier<bool>(false);
  static bool _hasTriggeredThisSession = false;

  /// Inicia el temporizador de permanencia si no ha sido iniciado
  static void start(WidgetRef ref) {
    if (_timer != null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      elapsedSeconds++;
      secondsNotifier.value = elapsedSeconds;

      final user = ref.read(authProvider).user;
      if (user == null) return;

      final now = DateTime.now();
      final todayStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final isActiveToday = user.lastActiveDate == todayStr;

      if (isActiveToday) {
        autoActivatedNotifier.value = true;
      } else if (elapsedSeconds >= activationThresholdSeconds && !_hasTriggeredThisSession) {
        _hasTriggeredThisSession = true;
        autoActivatedNotifier.value = true;
        
        // Encender la racha automáticamente en authProvider
        final success = await ref.read(authProvider.notifier).incrementStreakOnAction();
        if (success) {
          AppHaptics.success();
        }
      }
    });
  }

  /// Detiene el temporizador si la app se suspende o cierra
  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Reinicia el contador de sesión si es necesario
  static void reset() {
    elapsedSeconds = 0;
    secondsNotifier.value = 0;
    _hasTriggeredThisSession = false;
    autoActivatedNotifier.value = false;
  }
}
