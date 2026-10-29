import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/app_haptics.dart';
import '../../providers/auth_provider.dart';
import 'add_expense_modal.dart';

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

  static Future<void> show(
    BuildContext context, {
    required int streak,
    required bool isActiveToday,
    bool isFrozen = false,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => StreakModal(
        currentStreak: streak,
        isActiveToday: isActiveToday,
        isFrozen: isFrozen,
      ),
    );
  }
}

class _StreakModalState extends ConsumerState<StreakModal>
    with TickerProviderStateMixin {
  late AnimationController _bobController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  final List<_FlameSpark> _sparks = [];

  @override
  void initState() {
    super.initState();

    // Gentle floating bob animation for 3D flame
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Warm pulsing glow
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Celebration sparks
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    if (widget.isActiveToday) {
      _initSparks();
      _particleController.repeat();
    }
  }

  void _initSparks() {
    final random = math.Random();
    final colors = [
      const Color(0xFFFF9600),
      const Color(0xFFFFC800),
      const Color(0xFFFF4838),
      Colors.white,
    ];
    for (int i = 0; i < 28; i++) {
      _sparks.add(
        _FlameSpark(
          angle: random.nextDouble() * 2 * math.pi,
          speed: 40 + random.nextDouble() * 100,
          radius: 2 + random.nextDouble() * 4,
          color: colors[random.nextInt(colors.length)],
        ),
      );
    }
  }

  @override
  void dispose() {
    _bobController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _onShare() {
    AppHaptics.mediumImpact();
    final streak = widget.currentStreak;
    final message =
        '¡Llevo $streak días de racha financiera en QUIVO! 🔥💰 Mantengo mis finanzas al día y creo hábitos saludables.';
    Clipboard.setData(ClipboardData(text: message));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1CB0F6),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: const Row(
          children: [
            Icon(LucideIcons.checkCheck, color: Color(0xFF092A40), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '¡Racha copiada! Compártela con tus amigos 🚀',
                style: TextStyle(
                  color: Color(0xFF092A40),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authProvider).user;
    final firstName = (authUser?.name.trim().isNotEmpty == true)
        ? authUser!.name.trim().split(' ').first.toUpperCase()
        : 'CAMPEÓN';

    // Weekday calculation (1=Lunes, 7=Domingo)
    final now = DateTime.now();
    final int todayWeekday = now.weekday;

    // Completed days in current week (Monday to today)
    final int completedDaysThisWeek = widget.isActiveToday
        ? math.min(todayWeekday, math.max(1, widget.currentStreak))
        : math.max(0, math.min(todayWeekday - 1, widget.currentStreak));

    final int daysRemaining = math.max(0, 7 - completedDaysThisWeek);
    final dayNames = ['L', 'Ma', 'Mi', 'J', 'V', 'S', 'D'];

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Main Dialog Card matching Image 2 Dark Slate aesthetic
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
            decoration: BoxDecoration(
              color: const Color(0xFF131F24),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF263843),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top close button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2830),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2E404D),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.x,
                        color: Color(0xFF8599A6),
                        size: 18,
                      ),
                    ),
                  ),
                ),

                // 3D Duolingo Flame Hero Visual
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsating warm glow
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        final glowScale = 1.0 + (_glowController.value * 0.12);
                        return Transform.scale(
                          scale: glowScale,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  (widget.isFrozen
                                          ? const Color(0xFF38BDF8)
                                          : const Color(0xFFFF9600))
                                      .withValues(
                                        alpha: 0.35 *
                                            (1.0 -
                                                (_glowController.value * 0.3)),
                                      ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Floating 3D Flame
                    AnimatedBuilder(
                      animation: _bobController,
                      builder: (context, child) {
                        final bobY = math.sin(_bobController.value * math.pi) * -7.0;
                        return CustomPaint(
                          size: const Size(150, 175),
                          painter: _DuolingoFlamePainter(
                            bobOffset: bobY,
                            isActive: widget.isActiveToday,
                            isFrozen: widget.isFrozen,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Giant Streak Counter (Image 2 style)
                Text(
                  '${widget.currentStreak}',
                  style: const TextStyle(
                    fontSize: 74,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF9600),
                    letterSpacing: -1.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),

                // Subtitle: "días de racha" (Image 2 style)
                Text(
                  widget.isFrozen
                      ? 'días protegidos con escudo'
                      : 'días de racha',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF9600),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 24),

                // Weekly Strip Header (L, Ma, Mi, J, V, S, D)
                Row(
                  children: List.generate(7, (index) {
                    final bool isCompleted = index < completedDaysThisWeek;
                    return Expanded(
                      child: Center(
                        child: Text(
                          dayNames[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isCompleted
                                ? const Color(0xFFFF9600)
                                : const Color(0xFF6E8492),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),

                // Weekly Strip Indicators (Continuous Capsule + Circles + Chest)
                _WeeklyCapsuleStrip(
                  completedCount: completedDaysThisWeek,
                  totalDays: 7,
                ),
                const SizedBox(height: 22),

                // Motivational Text matching Image 2
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFFD6E2E8),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      children: daysRemaining > 0
                          ? [
                              const TextSpan(
                                text: '¡Registra tus movimientos ',
                              ),
                              TextSpan(
                                text:
                                    '$daysRemaining ${daysRemaining == 1 ? "día más" : "días más"}',
                                style: const TextStyle(
                                  color: Color(0xFFFF9600),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    ' para recibir tu próxima recompensa por tu semana perfecta!',
                              ),
                            ]
                          : const [
                              TextSpan(
                                text:
                                    '¡Completaste tu semana perfecta! 🎉 ¡Reclama tu cofre semanal de recompensas!',
                                style: TextStyle(
                                  color: Color(0xFFFFC800),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // SAMI Encouragement Badge (Preserves Mascot presence)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17252D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF283B46),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        widget.isActiveToday
                            ? 'assets/images/sami_celebrando.png'
                            : 'assets/images/sami_bienvenida.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isActiveToday
                            ? 'SAMI: "¡Excelente disciplina financiera!"'
                            : 'SAMI: "¡Registra un movimiento y salva tu racha!"',
                        style: const TextStyle(
                          color: Color(0xFF8BA0AE),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bottom Action Bar: Share Button + 3D Duolingo Button
                Row(
                  children: [
                    // Share Button (Image 2 style)
                    GestureDetector(
                      onTap: _onShare,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A32),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2E434F),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              offset: const Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.share2,
                          color: Color(0xFF38BDF8),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Big 3D Duolingo Button (Image 2: ¡BRAVO, [NOMBRE]!)
                    Expanded(
                      child: _Duolingo3DButton(
                        label: widget.isActiveToday
                            ? '¡BRAVO, $firstName!'
                            : '¡MANTENER MI RACHA!',
                        onPressed: () {
                          if (widget.isActiveToday) {
                            AppHaptics.success();
                            Navigator.of(context).pop();
                          } else {
                            AppHaptics.mediumImpact();
                            Navigator.of(context).pop();
                            AddExpenseModal.show(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Celebration particles layer (when active)
          if (widget.isActiveToday)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _SparksPainter(
                        sparks: _sparks,
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

// ---------------------------------------------------------------------------
// WEEKLY CAPSULE STRIP (Joined Capsule for completed consecutive days)
// ---------------------------------------------------------------------------
class _WeeklyCapsuleStrip extends StatelessWidget {
  final int completedCount;
  final int totalDays;

  const _WeeklyCapsuleStrip({
    required this.completedCount,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double slotWidth = totalWidth / totalDays;

        return SizedBox(
          height: 44,
          child: Stack(
            children: [
              // 1. Continuous orange capsule spanning all completed days
              if (completedCount > 0)
                Positioned(
                  left: 0,
                  top: 1,
                  bottom: 1,
                  width: math.min(totalWidth, slotWidth * completedCount),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFF9600),
                          Color(0xFFFF4826),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFFFCC00),
                        width: 2.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5216).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),

              // 2. Individual day indicators row (Checks for completed, Circles for pending, Chest for Sunday)
              Row(
                children: List.generate(totalDays, (index) {
                  final bool isCompleted = index < completedCount;
                  final bool isSunday = index == 6;

                  Widget dayChild;
                  if (isSunday) {
                    // Sunday is always the Treasure Chest (golden if completed, metallic slate if pending)
                    dayChild = _TreasureChestIcon(
                      isCompleted: isCompleted,
                    );
                  } else if (isCompleted) {
                    // Dark checkmark inside continuous capsule
                    dayChild = const Icon(
                      LucideIcons.check,
                      color: Color(0xFF131F24),
                      size: 22,
                    );
                  } else {
                    // Pending day: dark circular dot matching Image 2
                    dayChild = Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF24333C),
                        shape: BoxShape.circle,
                      ),
                    );
                  }

                  return Expanded(
                    child: Center(child: dayChild),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 3D DUOLINGO FLAME PAINTER
// ---------------------------------------------------------------------------
class _DuolingoFlamePainter extends CustomPainter {
  final double bobOffset;
  final bool isActive;
  final bool isFrozen;

  _DuolingoFlamePainter({
    required this.bobOffset,
    required this.isActive,
    required this.isFrozen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Dark oval pedestal shadow at the base
    final pedestalPaint = Paint()
      ..color = const Color(0xFF16252D)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.94),
        width: w * 0.72,
        height: h * 0.16,
      ),
      pedestalPaint,
    );

    // Apply floating bob animation offset to flame
    canvas.save();
    canvas.translate(0, bobOffset);

    // 2. Outer Flame Contour (Golden Yellow Rim)
    final outerPath = Path();
    outerPath.moveTo(w * 0.50, h * 0.88);
    // bottom-left curve
    outerPath.cubicTo(w * 0.26, h * 0.88, w * 0.12, h * 0.74, w * 0.12, h * 0.58);
    // up to left tongue peak
    outerPath.cubicTo(w * 0.12, h * 0.44, w * 0.16, h * 0.28, w * 0.22, h * 0.21);
    // round left peak
    outerPath.cubicTo(w * 0.26, h * 0.18, w * 0.31, h * 0.21, w * 0.33, h * 0.27);
    // valley between flame peaks
    outerPath.cubicTo(w * 0.36, h * 0.37, w * 0.44, h * 0.46, w * 0.52, h * 0.36);
    // up to tall right peak
    outerPath.cubicTo(w * 0.58, h * 0.24, w * 0.67, h * 0.08, w * 0.74, h * 0.04);
    // round top peak
    outerPath.cubicTo(w * 0.79, h * 0.02, w * 0.84, h * 0.08, w * 0.86, h * 0.16);
    // right flank down
    outerPath.cubicTo(w * 0.92, h * 0.32, w * 0.88, h * 0.56, w * 0.84, h * 0.68);
    // curve back into bottom
    outerPath.cubicTo(w * 0.80, h * 0.82, w * 0.68, h * 0.88, w * 0.50, h * 0.88);
    outerPath.close();

    final outerPaint = Paint()
      ..color = isFrozen ? const Color(0xFF7DD3FC) : const Color(0xFFFFCC00)
      ..style = PaintingStyle.fill;
    canvas.drawPath(outerPath, outerPaint);

    // 3. Inner Flame Body (Fiery Red-Orange Gradient)
    final innerPath = Path();
    innerPath.moveTo(w * 0.50, h * 0.83);
    // bottom-left
    innerPath.cubicTo(w * 0.30, h * 0.83, w * 0.19, h * 0.70, w * 0.19, h * 0.57);
    // left inner tongue
    innerPath.cubicTo(w * 0.19, h * 0.45, w * 0.22, h * 0.34, w * 0.27, h * 0.28);
    innerPath.cubicTo(w * 0.29, h * 0.26, w * 0.33, h * 0.28, w * 0.35, h * 0.34);
    // valley
    innerPath.cubicTo(w * 0.38, h * 0.42, w * 0.45, h * 0.48, w * 0.52, h * 0.40);
    // tall inner peak
    innerPath.cubicTo(w * 0.58, h * 0.30, w * 0.65, h * 0.18, w * 0.72, h * 0.12);
    innerPath.cubicTo(w * 0.76, h * 0.09, w * 0.80, h * 0.14, w * 0.81, h * 0.22);
    // right flank
    innerPath.cubicTo(w * 0.85, h * 0.36, w * 0.81, h * 0.56, w * 0.77, h * 0.66);
    // back to bottom
    innerPath.cubicTo(w * 0.73, h * 0.78, w * 0.64, h * 0.83, w * 0.50, h * 0.83);
    innerPath.close();

    final innerGradient = isFrozen
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
          )
        : const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFFF8500),
              Color(0xFFFF3B30),
              Color(0xFFFF2D55),
              Color(0xFFFF6B00),
            ],
            stops: [0.0, 0.42, 0.75, 1.0],
          );

    final innerPaint = Paint()
      ..shader = innerGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(innerPath, innerPaint);

    // 4. Soft pinkish crescent accent on left flame tongue (Image 2 detail)
    if (!isFrozen) {
      final accentPath = Path();
      accentPath.moveTo(w * 0.23, h * 0.36);
      accentPath.cubicTo(w * 0.20, h * 0.46, w * 0.22, h * 0.58, w * 0.28, h * 0.64);
      accentPath.cubicTo(w * 0.24, h * 0.58, w * 0.24, h * 0.46, w * 0.28, h * 0.38);
      accentPath.close();

      final accentPaint = Paint()
        ..color = const Color(0xFFFF8A95).withValues(alpha: 0.65)
        ..style = PaintingStyle.fill;
      canvas.drawPath(accentPath, accentPaint);
    }

    // 5. Center Glowing White Droplet
    // Diffuse warm halo behind droplet
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.85),
          const Color(0xFFFFD54F).withValues(alpha: 0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(w * 0.50, h * 0.67),
          radius: w * 0.22,
        ),
      );
    canvas.drawCircle(Offset(w * 0.50, h * 0.67), w * 0.22, glowPaint);

    // Crisp white droplet shape
    final dropletPath = Path();
    dropletPath.moveTo(w * 0.50, h * 0.53);
    // left curve
    dropletPath.cubicTo(w * 0.44, h * 0.61, w * 0.38, h * 0.67, w * 0.38, h * 0.72);
    // round bottom
    dropletPath.cubicTo(w * 0.38, h * 0.79, w * 0.43, h * 0.82, w * 0.50, h * 0.82);
    dropletPath.cubicTo(w * 0.57, h * 0.82, w * 0.62, h * 0.79, w * 0.62, h * 0.72);
    // right curve back up
    dropletPath.cubicTo(w * 0.62, h * 0.67, w * 0.56, h * 0.61, w * 0.50, h * 0.53);
    dropletPath.close();

    final dropletPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(dropletPath, dropletPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DuolingoFlamePainter oldDelegate) {
    return oldDelegate.bobOffset != bobOffset ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isFrozen != isFrozen;
  }
}

// ---------------------------------------------------------------------------
// TREASURE CHEST ICON (Sunday reward)
// ---------------------------------------------------------------------------
class _TreasureChestIcon extends StatelessWidget {
  final bool isCompleted;

  const _TreasureChestIcon({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: isCompleted
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC800).withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: CustomPaint(
        size: const Size(34, 30),
        painter: _ChestPainter(isCompleted: isCompleted),
      ),
    );
  }
}

class _ChestPainter extends CustomPainter {
  final bool isCompleted;

  _ChestPainter({required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final primaryColor = isCompleted
        ? const Color(0xFFFFB300)
        : const Color(0xFF384C59);
    final strapColor = isCompleted
        ? const Color(0xFFFFD54F)
        : const Color(0xFF5D7483);
    final claspColor = isCompleted
        ? Colors.white
        : const Color(0xFF8BA2B0);

    // Chest Body (Lower box)
    final bodyPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    final bodyRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.12, h * 0.40, w * 0.76, h * 0.52),
      bottomLeft: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Chest Lid (Arched top)
    final lidPath = Path();
    lidPath.moveTo(w * 0.08, h * 0.40);
    lidPath.cubicTo(w * 0.08, h * 0.18, w * 0.30, h * 0.12, w * 0.50, h * 0.12);
    lidPath.cubicTo(w * 0.70, h * 0.12, w * 0.92, h * 0.18, w * 0.92, h * 0.40);
    lidPath.close();
    canvas.drawPath(lidPath, bodyPaint);

    // Left and Right Metallic Straps
    final strapPaint = Paint()
      ..color = strapColor
      ..style = PaintingStyle.fill;
    // Left strap
    canvas.drawRect(Rect.fromLTWH(w * 0.26, h * 0.14, w * 0.09, h * 0.76), strapPaint);
    // Right strap
    canvas.drawRect(Rect.fromLTWH(w * 0.65, h * 0.14, w * 0.09, h * 0.76), strapPaint);

    // Horizontal Seam between Lid and Box
    final seamPaint = Paint()
      ..color = strapColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(w * 0.08, h * 0.40),
      Offset(w * 0.92, h * 0.40),
      seamPaint,
    );

    // Center Lock Clasp (Heart / Shield icon)
    final claspPaint = Paint()
      ..color = claspColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.50, h * 0.45), w * 0.11, claspPaint);

    final lockHolePaint = Paint()
      ..color = const Color(0xFF131F24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.50, h * 0.45), w * 0.04, lockHolePaint);
  }

  @override
  bool shouldRepaint(covariant _ChestPainter oldDelegate) {
    return oldDelegate.isCompleted != isCompleted;
  }
}

// ---------------------------------------------------------------------------
// 3D DUOLINGO BUTTON (Flat 3D Bevel with responsive push feel)
// ---------------------------------------------------------------------------
class _Duolingo3DButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _Duolingo3DButton({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_Duolingo3DButton> createState() => _Duolingo3DButtonState();
}

class _Duolingo3DButtonState extends State<_Duolingo3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        height: 52,
        transform: Matrix4.translationValues(0, _isPressed ? 3 : 0, 0),
        decoration: BoxDecoration(
          color: const Color(0xFF1CB0F6), // Vibrant Duolingo Electric Cyan
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1899D6), // 3D Bottom Bevel Shadow
              offset: Offset(0, _isPressed ? 1 : 4),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: const TextStyle(
            color: Color(0xFF092A40), // Bold dark navy contrast text (Image 2)
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CELEBRATION SPARKS
// ---------------------------------------------------------------------------
class _FlameSpark {
  final double angle;
  final double speed;
  final double radius;
  final Color color;

  _FlameSpark({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.color,
  });
}

class _SparksPainter extends CustomPainter {
  final List<_FlameSpark> sparks;
  final double progress;

  _SparksPainter({required this.sparks, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.50, size.height * 0.28);

    for (final s in sparks) {
      final dist = s.speed * progress * 1.5;
      final dx = math.cos(s.angle) * dist;
      final dy = math.sin(s.angle) * dist - (30 * progress); // float upwards

      final pos = center + Offset(dx, dy);
      final alpha = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = s.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pos, s.radius * (1.0 - progress * 0.4), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparksPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
