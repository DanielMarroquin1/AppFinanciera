import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_expense_modal.dart';
import '../../../core/utils/localization.dart';

class StreakModal extends ConsumerStatefulWidget {
  final int currentStreak;
  final bool isActiveToday;
  final bool isFrozen;

  const StreakModal({
    super.key,
    required this.currentStreak,
    required this.isActiveToday,
    this.isFrozen = false,
  });

  @override
  ConsumerState<StreakModal> createState() => _StreakModalState();

  static Future<void> show(BuildContext context, {required int streak, required bool isActiveToday, bool isFrozen = false}) {
    return showDialog(
      context: context,
      builder: (context) => StreakModal(currentStreak: streak, isActiveToday: isActiveToday, isFrozen: isFrozen),
    );
  }
}

class _StreakModalState extends ConsumerState<StreakModal> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _particleController;
  final List<_CelebrationParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    if (widget.isActiveToday) {
      _initParticles();
      _particleController.repeat();
    }
  }

  void _initParticles() {
    final random = math.Random();
    final colors = [
      const Color(0xFFF97316), // Orange
      const Color(0xFFEA580C), // Dark Orange
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFFCD34D), // Yellow Gold
      const Color(0xFFEF4444), // Red
      Colors.white,
    ];

    for (int i = 0; i < 45; i++) {
      _particles.add(_CelebrationParticle(
        angle: random.nextDouble() * 2 * math.pi,
        speed: 60 + random.nextDouble() * 140,
        radius: 3 + random.nextDouble() * 5,
        color: colors[random.nextInt(colors.length)],
        isStar: random.nextBool(),
      ));
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);

    // Calculate continuous 5-day cycle starting day
    final int startDay = widget.currentStreak <= 0
        ? 1
        : ((widget.currentStreak - 1) ~/ 5) * 5 + 1;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Background Glow for Active Streak
          if (widget.isActiveToday)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF97316).withValues(alpha: 0.25 + (_pulseController.value * 0.15)),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Main Dialog Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: widget.isActiveToday
                    ? (isDark ? const Color(0xFFEA580C) : const Color(0xFFF97316))
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                width: widget.isActiveToday ? 2.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Status Badge
                if (widget.isFrozen) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF0284C7)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.snowflake, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          loc.get('streak_badge_frozen'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8),
                        ),
                      ],
                    ),
                  ),
                ] else if (widget.isActiveToday) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEA580C)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF97316).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.sparkles, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          loc.get('streak_badge_active'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.flame, color: isDark ? Colors.orange[400] : Colors.orange[700], size: 14),
                        const SizedBox(width: 6),
                        Text(
                          loc.get('streak_badge_pending'),
                          style: TextStyle(
                            color: isDark ? Colors.grey[200] : Colors.grey[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Flame Icon Circle
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.isActiveToday || widget.isFrozen)
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            width: 100 + (_pulseController.value * 20),
                            height: 100 + (_pulseController.value * 20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: (widget.isFrozen ? const Color(0xFF0EA5E9) : const Color(0xFFF97316))
                                    .withValues(alpha: 0.3 * (1.0 - _pulseController.value)),
                                width: 3,
                              ),
                            ),
                          );
                        },
                      ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: widget.isFrozen
                            ? (isDark
                                ? const LinearGradient(colors: [Color(0xFF0C4A6E), Color(0xFF075985)])
                                : const LinearGradient(colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)]))
                            : widget.isActiveToday
                                ? (isDark
                                    ? const LinearGradient(colors: [Color(0xFF7C2D12), Color(0xFF9A3412)])
                                    : const LinearGradient(colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)]))
                                : (isDark
                                    ? const LinearGradient(colors: [Color(0xFF374151), Color(0xFF1F2937)])
                                    : const LinearGradient(colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)])),
                        border: Border.all(
                          color: widget.isFrozen
                              ? const Color(0xFF0EA5E9)
                              : widget.isActiveToday
                                  ? (isDark ? const Color(0xFFF97316) : const Color(0xFFFB923C))
                                  : (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
                          width: 3.5,
                        ),
                        boxShadow: (widget.isActiveToday || widget.isFrozen)
                            ? [
                                BoxShadow(
                                  color: (widget.isFrozen ? const Color(0xFF0EA5E9) : const Color(0xFFF97316)).withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: (widget.isActiveToday || widget.isFrozen) ? 1.0 + (_pulseController.value * 0.18) : 1.0,
                            child: Icon(
                              widget.isFrozen ? LucideIcons.snowflake : LucideIcons.flame,
                              size: 52,
                              color: widget.isFrozen
                                  ? const Color(0xFF0EA5E9)
                                  : widget.isActiveToday
                                      ? (isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C))
                                      : (isDark ? Colors.grey[500] : Colors.grey[400]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Streak Count Display
                Text(
                  '${widget.currentStreak}',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: widget.isFrozen
                        ? const Color(0xFF0EA5E9)
                        : widget.isActiveToday && widget.currentStreak > 0
                            ? (isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C))
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    height: 1.0,
                  ),
                ),
                Text(
                  widget.isFrozen
                      ? loc.get('streak_sub_frozen')
                      : widget.currentStreak == 0
                          ? loc.get('streak_sub_zero')
                          : widget.currentStreak == 1
                              ? loc.get('streak_sub_one')
                              : loc.get('streak_sub_multi'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),

                // Instructions Box (How to Activate / Status)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.isFrozen
                        ? (isDark ? const Color(0xFF0C4A6E).withValues(alpha: 0.2) : const Color(0xFFE0F2FE))
                        : widget.isActiveToday
                            ? (isDark ? const Color(0xFF7C2D12).withValues(alpha: 0.2) : const Color(0xFFFFF7ED))
                            : (isDark ? const Color(0xFF334155).withValues(alpha: 0.4) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.isFrozen
                          ? const Color(0xFF38BDF8)
                          : widget.isActiveToday
                              ? (isDark ? const Color(0xFF9A3412) : const Color(0xFFFED7AA))
                              : (isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: widget.isFrozen
                      ? Row(
                          children: [
                            const Icon(LucideIcons.shieldCheck, color: Color(0xFF0EA5E9), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                loc.get('streak_desc_frozen'),
                                style: TextStyle(color: isDark ? const Color(0xFFBAE6FD) : const Color(0xFF0369A1), fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        )
                      : widget.isActiveToday
                          ? Row(
                              children: [
                                Icon(LucideIcons.checkCircle2, color: isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C), size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    loc.get('streak_desc_active'),
                                    style: TextStyle(color: isDark ? Colors.orange[200] : Colors.orange[900], fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.info, color: Color(0xFFF59E0B), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.currentStreak == 0 ? loc.get('streak_title_zero') : loc.get('streak_title_pending'),
                                      style: TextStyle(color: isDark ? Colors.amber[400] : Colors.amber[800], fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.currentStreak == 0
                                      ? loc.get('streak_desc_zero')
                                      : loc.get('streak_desc_pending'),
                                  style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 13, height: 1.4),
                                ),
                              ],
                            ),
                ),
                const SizedBox(height: 24),

                // 5-step progress (Duolingo style)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final int dayNumber = startDay + index;
                    final bool isCompleted = dayNumber <= widget.currentStreak;
                    final bool isChest = index == 4; // Every 5th day of the cycle is the bonus chest
                    return Column(
                      children: [
                        Text(
                          '${loc.get('streak_day')} $dayNumber',
                          style: TextStyle(
                            color: isCompleted
                                ? (isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C))
                                : (isDark ? Colors.grey[600] : Colors.grey[400]),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: isChest ? 46 : 38,
                          height: isChest ? 46 : 38,
                          decoration: BoxDecoration(
                            shape: isChest ? BoxShape.rectangle : BoxShape.circle,
                            borderRadius: isChest ? BorderRadius.circular(12) : null,
                            color: isCompleted
                                ? (isDark ? const Color(0xFFEA580C) : const Color(0xFFF97316))
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                            border: isChest && !isCompleted
                                ? Border.all(
                                    color: isDark ? const Color(0xFFF59E0B).withValues(alpha: 0.5) : const Color(0xFFFCD34D),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: isChest
                              ? Icon(LucideIcons.gift, color: isCompleted ? Colors.white : (isDark ? const Color(0xFFF59E0B) : const Color(0xFFF59E0B)), size: 22)
                              : (isCompleted ? const Icon(LucideIcons.check, color: Colors.white, size: 18) : null),
                        ),
                        if (isChest) ...[
                          const SizedBox(height: 4),
                          Text('+200 ${loc.get('streak_pts')}', style: TextStyle(color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706), fontSize: 10, fontWeight: FontWeight.bold)),
                        ]
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 28),

                 // Action Buttons
                if (widget.isActiveToday) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFFEA580C) : const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFFF97316).withValues(alpha: 0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.flame, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            loc.get('streak_btn_continue'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        AddExpenseModal.show(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFFEA580C).withValues(alpha: 0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.plusCircle, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            loc.get('streak_btn_register'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      loc.get('streak_btn_close'),
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Celebration Particles Layer (when streak is active)
          if (widget.isActiveToday)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _CelebrationParticlesPainter(
                        particles: _particles,
                        progress: _particleController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CelebrationParticle {
  final double angle;
  final double speed;
  final double radius;
  final Color color;
  final bool isStar;

  _CelebrationParticle({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.color,
    required this.isStar,
  });
}

class _CelebrationParticlesPainter extends CustomPainter {
  final List<_CelebrationParticle> particles;
  final double progress;

  _CelebrationParticlesPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.35);

    for (final p in particles) {
      // Calculate expansion and gravity arc
      final dist = p.speed * progress * (size.width / 150);
      final dx = math.cos(p.angle) * dist;
      final dy = math.sin(p.angle) * dist + (140 * progress * progress); // gravity

      final pos = center + Offset(dx, dy);
      final alpha = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      if (p.isStar) {
        _drawStar(canvas, pos, p.radius * (1.0 - progress * 0.3), paint);
      } else {
        canvas.drawCircle(pos, p.radius * (1.0 - progress * 0.3), paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const int points = 5;
    final double innerRadius = radius * 0.45;
    double angle = -math.pi / 2;
    const double step = math.pi / points;

    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? radius : innerRadius;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CelebrationParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
