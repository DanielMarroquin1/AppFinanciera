import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/color_palette_provider.dart';

class QuivoLogo extends ConsumerWidget {
  final double size;
  final Color? color;
  final List<Color>? gradient;
  final bool usePalette;
  final bool withContainer;
  final bool withGlow;
  final VoidCallback? onTap;

  const QuivoLogo({
    super.key,
    this.size = 48,
    this.color,
    this.gradient,
    this.usePalette = true,
    this.withContainer = false,
    this.withGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resuelve dinámicamente los colores de la paleta activa o el estándar azul marino
    List<Color> resolvedGradient;
    if (gradient != null && gradient!.isNotEmpty) {
      resolvedGradient = gradient!;
    } else if (color != null) {
      resolvedGradient = [color!, color!];
    } else if (usePalette) {
      final palette = ref.watch(colorPaletteProvider);
      if (palette.id == 'theme_default') {
        // Estándar oficial de la marca (Diseño 3): Verde Fresco a Verde Lima
        resolvedGradient = const [
          Color(0xFF6AD93D), // Verde Fresco
          Color(0xFFCDE60E), // Verde Lima
        ];
      } else {
        resolvedGradient = [palette.colors[0], palette.colors[1]];
      }
    } else {
      // Estándar oficial estático
      resolvedGradient = const [Color(0xFF6AD93D), Color(0xFFCDE60E)];
    }

    final primaryColor = resolvedGradient.first;

    // La "Q" intuitiva renderizada mediante ShaderMask sobre la máscara alfa pura
    Widget qIcon = ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: resolvedGradient,
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Image.asset(
        'assets/images/quivo_logo_white.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );

    if (withGlow) {
      qIcon = Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.20),
              blurRadius: size * 0.35,
              spreadRadius: -2,
            ),
          ],
        ),
        child: qIcon,
      );
    }

    if (withContainer) {
      final containerSize = size * 1.55;
      final borderRadius = BorderRadius.circular(containerSize * 0.30);

      Widget container = Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141C2E) : Colors.white,
          borderRadius: borderRadius,
          border: Border.all(
            color: primaryColor.withValues(alpha: isDark ? 0.40 : 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: isDark ? 0.30 : 0.18),
              blurRadius: 28,
              spreadRadius: -2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: qIcon),
      );

      if (onTap != null) {
        return InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: container,
        );
      }
      return container;
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: qIcon,
      );
    }

    return qIcon;
  }
}

/// Logo de QUIVO con texto institucional dinámico
class QuivoBrandHeader extends ConsumerWidget {
  final double iconSize;
  final double fontSize;
  final bool showBadge;

  const QuivoBrandHeader({
    super.key,
    this.iconSize = 34,
    this.fontSize = 22,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = ref.watch(colorPaletteProvider);
    final primaryColor = palette.id == 'theme_default'
        ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF004457))
        : palette.colors[0];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        QuivoLogo(size: iconSize),
        const SizedBox(width: 10),
        Text(
          'QUIVO',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        if (showBadge) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Text(
              'APP',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
