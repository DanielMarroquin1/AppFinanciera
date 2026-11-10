import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema central de respuesta háptica y vibración física para QUIVO.
class AppHaptics {
  /// Vibración ligera para toques de botones comunes, chips, pestañas y menús
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Vibración táctil fina para selectores, sliders, switches y días del calendario
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibración media para botones principales (Guardar, Crear, Confirmar, FAB)
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Vibración fuerte para eliminar elementos, cancelar o alertas importantes
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Patrón de vibración de éxito (ej. transacción registrada, meta alcanzada)
  static void success() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 90));
    HapticFeedback.lightImpact();
  }

  /// Patrón de vibración de error o advertencia (ej. límite de presupuesto excedido)
  static void error() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
  }

  /// Vibración estándar de notificación
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}

/// Widget envolvente que agrega a cualquier botón o elemento interactivo:
/// 1. Vibración háptica física al presionar
/// 2. Animación elástica de compresión (bounce / squeeze) al tocar
class BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final Duration duration;
  final bool enableHaptics;
  final HapticType hapticType;
  final HitTestBehavior behavior;

  const BounceTap({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.94,
    this.duration = const Duration(milliseconds: 110),
    this.enableHaptics = true,
    this.hapticType = HapticType.light,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<BounceTap> createState() => _BounceTapState();
}

enum HapticType { light, selection, medium, heavy, success, error }

class _BounceTapState extends State<BounceTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: const Duration(milliseconds: 140),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutQuad,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    if (!widget.enableHaptics) return;
    switch (widget.hapticType) {
      case HapticType.light:
        AppHaptics.lightImpact();
        break;
      case HapticType.selection:
        AppHaptics.selection();
        break;
      case HapticType.medium:
        AppHaptics.mediumImpact();
        break;
      case HapticType.heavy:
        AppHaptics.heavyImpact();
        break;
      case HapticType.success:
        AppHaptics.success();
        break;
      case HapticType.error:
        AppHaptics.error();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null && widget.onLongPress == null) {
      return widget.child;
    }

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) {
        _triggerHaptic();
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      onLongPress: widget.onLongPress != null
          ? () {
              AppHaptics.mediumImpact();
              widget.onLongPress?.call();
            }
          : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
