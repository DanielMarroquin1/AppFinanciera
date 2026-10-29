import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/sami_outfit.dart';

/// Widget unificado para renderizar los avatares oficiales de SAMI con ropa, gorra y accesorios
class SamiAvatarWidget extends StatelessWidget {
  final String? avatarId;
  final double size;
  final bool isDark;
  final bool isLocked;
  final bool isSelected;
  final bool showAccessoryBadge;
  final VoidCallback? onTap;

  const SamiAvatarWidget({
    super.key,
    required this.avatarId,
    required this.size,
    required this.isDark,
    this.isLocked = false,
    this.isSelected = false,
    this.showAccessoryBadge = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final outfit = SamiOutfit.getOutfit(avatarId);
    final badgeSize = size * 0.38;

    Widget avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [outfit.primaryColor, outfit.secondaryColor],
        ),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF38BDF8)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.8)),
          width: isSelected ? 3.0 : (size * 0.04).clamp(1.5, 4.0),
        ),
        boxShadow: [
          // Sombra principal del orbe
          BoxShadow(
            color: outfit.primaryColor.withValues(
              alpha: isSelected ? 0.6 : (isDark ? 0.45 : 0.25),
            ),
            blurRadius: isSelected ? 16 : 10,
            offset: const Offset(0, 4),
          ),
          if (isSelected)
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Fondo con brillo radial suave
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 0.75,
                  colors: [
                    Colors.white.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Personaje SAMI
            Padding(
              padding: EdgeInsets.all(size * 0.08),
              child: Image.asset(
                outfit.imageAsset,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      outfit.accessoryEmoji,
                      style: TextStyle(fontSize: size * 0.45),
                    ),
                  );
                },
              ),
            ),

            // Filtro de bloqueo si no ha sido comprado
            if (isLocked)
              Container(
                color: Colors.black.withValues(alpha: 0.55),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(size * 0.08),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      LucideIcons.lock,
                      size: size * 0.25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    // Si tiene insignia de accesorio (gorra, corbata, corona, etc.)
    if (showAccessoryBadge && !isLocked) {
      avatarContent = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  outfit.accessoryEmoji,
                  style: TextStyle(fontSize: badgeSize * 0.62),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: avatarContent,
      );
    }

    return avatarContent;
  }
}
