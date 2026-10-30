import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/services/streak_session_service.dart';
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
  late AnimationController _flickerController;
  final List<_FlameSpark> _sparks = [];
  bool _isActiveState = false;
  int _liveStreak = 0;

  @override
  void initState() {
    super.initState();
    _isActiveState = widget.isActiveToday;
    _liveStreak = widget.currentStreak;

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

    // Natural flame wind flicker
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Celebration sparks
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    if (_isActiveState) {
      _initSparks();
      _particleController.repeat();
    }

    // Escuchar activación automática tras 45s de permanencia
    StreakSessionService.autoActivatedNotifier.addListener(_onAutoActivated);
    StreakSessionService.secondsNotifier.addListener(_onSecondsTick);
  }

  void _onAutoActivated() {
    if (!_isActiveState && mounted) {
      setState(() {
        _isActiveState = true;
        _liveStreak = _liveStreak <= 0 ? 1 : _liveStreak;
      });
      _initSparks();
      _particleController.repeat();
    }
  }

  void _onSecondsTick() {
    if (!_isActiveState && mounted) {
      setState(() {});
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
    StreakSessionService.autoActivatedNotifier.removeListener(_onAutoActivated);
    StreakSessionService.secondsNotifier.removeListener(_onSecondsTick);
    _bobController.dispose();
    _glowController.dispose();
    _flickerController.dispose();
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

    // 5-day milestone cycle calculation (User gets +50 PTS every 5 days!)
    final int currentStreak = _liveStreak;
    final int cycleIndex = currentStreak <= 0 ? 0 : (currentStreak - 1) ~/ 5;
    final int startDay = cycleIndex * 5 + 1;
    final int completedInCycle = currentStreak <= 0
        ? 0
        : (currentStreak - startDay + 1).clamp(0, 5);
    final int daysRemainingInCycle = math.max(0, 5 - completedInCycle);

    final secondsRemaining = math.max(0, StreakSessionService.activationThresholdSeconds - StreakSessionService.elapsedSeconds);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Main Dialog Card matching Image 2 Dark Slate aesthetic
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: 390,
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            decoration: BoxDecoration(
              color: const Color(0xFF131F24),
              borderRadius: BorderRadius.circular(28),
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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

                  // 3D QUIVO Financial Flame Hero Visual
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
                              width: 145,
                              height: 145,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    (widget.isFrozen
                                            ? const Color(0xFF00E5FF)
                                            : const Color(0xFFFF9600))
                                        .withValues(
                                          alpha: (_isActiveState ? 0.35 : 0.20) *
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

                      // Floating 3D QUIVO Flame
                      AnimatedBuilder(
                        animation: Listenable.merge([_bobController, _flickerController]),
                        builder: (context, child) {
                          final bobY = math.sin(_bobController.value * math.pi) * -5.0;
                          return CustomPaint(
                            size: const Size(130, 142),
                            painter: _QuivoFlamePainter(
                              bobOffset: bobY,
                              flickerProgress: _flickerController.value,
                              isActive: _isActiveState,
                              isFrozen: widget.isFrozen,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Giant Streak Counter (Image 2 style)
                  Text(
                    '$_liveStreak',
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
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF9600),
                    letterSpacing: -0.2,
                  ),
                ),

                // Chip de Auto-Activación por permanencia (45s en la app)
                if (!_isActiveState) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2C37),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFF9600).withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9600).withValues(alpha: 0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.timer, color: Color(0xFFFF9600), size: 14),
                        const SizedBox(width: 8),
                        Text(
                          secondsRemaining > 0
                              ? 'Auto-encendido en ${secondsRemaining}s en la app 🔥'
                              : '¡Encendiendo racha ahora! 🔥',
                          style: const TextStyle(
                            color: Color(0xFFFFD54F),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // 5-Day Milestone Badge: "+50 PTS cada 5 días"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🪙', style: TextStyle(fontSize: 13)),
                      SizedBox(width: 6),
                      Text(
                        'BONO: +50 PTS CADA 5 DÍAS',
                        style: TextStyle(
                          color: Color(0xFFFFD54F),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 5-Day Milestone Progress Track (startDay to endDay)
                _FiveDayMilestoneTrack(
                  startDay: startDay,
                  completedCount: completedInCycle,
                  isActiveToday: _isActiveState,
                ),
                const SizedBox(height: 12),

                // Motivational Text for the 5-day cycle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFFD6E2E8),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.30,
                      ),
                      children: daysRemainingInCycle > 0
                          ? [
                              const TextSpan(
                                text: '¡Registra tus movimientos ',
                              ),
                              TextSpan(
                                text:
                                    '$daysRemainingInCycle ${daysRemainingInCycle == 1 ? "día más" : "días más"}',
                                style: const TextStyle(
                                  color: Color(0xFFFF9600),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const TextSpan(
                                text:
                                    ' para recibir tu cofre de ',
                              ),
                              const TextSpan(
                                text: '+50 PTS',
                                style: TextStyle(
                                  color: Color(0xFFFFD54F),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const TextSpan(
                                text: ' extra!',
                              ),
                            ]
                          : const [
                              TextSpan(
                                text:
                                    '¡Completaste tu ciclo de 5 días! 🎉 ¡Reclamaste tus ',
                              ),
                              TextSpan(
                                text: '+50 PTS',
                                style: TextStyle(
                                  color: Color(0xFFFFD54F),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: ' de racha!',
                              ),
                            ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // SAMI Encouragement Card (High-Definition Master Asset, zero pixelation)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16252E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF263C4A),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // High-Res SAMI Avatar Badge with glowing ring
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF00E5FF), Color(0xFF0284C7)],
                          ),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/sami_3d_front_open.png',
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'SAMI',
                                  style: TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isActiveState ? '✨ Racha Activa' : '🔥 Por Activar',
                                  style: TextStyle(
                                    color: _isActiveState
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFFF9600),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isActiveState
                                  ? '¡Gran disciplina hoy! Cada día suma a tu libertad financiera.'
                                  : '¡Pasa 45s aquí o registra un gasto para encenderla!',
                              style: const TextStyle(
                                color: Color(0xFFD6E2E8),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Bottom Action Bar: Share Button + 3D Duolingo Button
                Row(
                  children: [
                    // Share Button (Image 2 style)
                    GestureDetector(
                      onTap: _onShare,
                      child: Container(
                        width: 50,
                        height: 50,
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
                          size: 21,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Big 3D Duolingo Button (Image 2: ¡BRAVO, [NOMBRE]!)
                    Expanded(
                      child: _Duolingo3DButton(
                        label: _isActiveState
                            ? '¡BRAVO, $firstName!'
                            : '¡MANTENER MI RACHA!',
                        onPressed: () {
                          if (_isActiveState) {
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
        ),

        // Celebration particles layer (when active)
        if (_isActiveState)
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
// 5-DAY MILESTONE TRACK (+50 PTS cada 5 días continuos)
// ---------------------------------------------------------------------------
class _FiveDayMilestoneTrack extends StatelessWidget {
  final int startDay;
  final int completedCount;
  final bool isActiveToday;

  const _FiveDayMilestoneTrack({
    required this.startDay,
    required this.completedCount,
    required this.isActiveToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Day numbers header row (startDay .. startDay + 4)
        Row(
          children: List.generate(5, (index) {
            final int dayNum = startDay + index;
            final bool isCompleted = index < completedCount;
            final bool isMilestone = (index == 4);

            return Expanded(
              child: Center(
                child: Text(
                  isMilestone ? 'Hito $dayNum' : 'Día $dayNum',
                  style: TextStyle(
                    fontSize: isMilestone ? 12.5 : 12.0,
                    fontWeight: isMilestone ? FontWeight.w900 : FontWeight.w800,
                    color: isMilestone
                        ? const Color(0xFFFFD54F)
                        : (isCompleted
                            ? const Color(0xFFFF9600)
                            : const Color(0xFF6E8492)),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),

        // 5-node continuous progress track
        LayoutBuilder(
          builder: (context, constraints) {
            final double totalWidth = constraints.maxWidth;
            final double slotWidth = totalWidth / 5;

            return SizedBox(
              height: 54,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // 1. Continuous orange capsule spanning completed days
                  if (completedCount > 0)
                    Positioned(
                      left: 0,
                      top: 4,
                      bottom: 4,
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
                          borderRadius: BorderRadius.circular(24),
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

                  // 2. Individual day indicators row (Checks for 1-4, 3D Chest with +50 PTS on 5)
                  Row(
                    children: List.generate(5, (index) {
                      final bool isCompleted = index < completedCount;
                      final bool isMilestone = (index == 4);

                      Widget dayChild;
                      if (isMilestone) {
                        // 5th Day: The Treasure Chest with glowing +50 PTS Badge
                        dayChild = Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            _TreasureChestIcon(isCompleted: isCompleted),
                            // +50 PTS Gold Badge floating above/below chest
                            Positioned(
                              bottom: -16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? const Color(0xFFFFD54F)
                                      : const Color(0xFF263843),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCompleted
                                        ? const Color(0xFFFF9600)
                                        : const Color(0xFFFFD54F).withValues(alpha: 0.7),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '+50 PTS',
                                  style: TextStyle(
                                    color: isCompleted
                                        ? const Color(0xFF092A40)
                                        : const Color(0xFFFFD54F),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (isCompleted) {
                        dayChild = const Icon(
                          LucideIcons.check,
                          color: Color(0xFF131F24),
                          size: 22,
                        );
                      } else {
                        dayChild = Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF24333C),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF334652),
                              width: 1.5,
                            ),
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
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 3D QUIVO FINANCIAL FLAME PAINTER (Llama Fluida, Dinámica y Orgánica QUIVO)
// ---------------------------------------------------------------------------
class _QuivoFlamePainter extends CustomPainter {
  final double bobOffset;
  final double flickerProgress;
  final bool isActive;
  final bool isFrozen;

  _QuivoFlamePainter({
    required this.bobOffset,
    required this.flickerProgress,
    required this.isActive,
    required this.isFrozen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Apply floating bob animation offset to the flame
    canvas.save();
    canvas.translate(0, bobOffset);

    // Natural energetic flame wind & flicker
    final flicker = math.sin(flickerProgress * 2 * math.pi) * 3.5;
    final secondaryFlicker = math.cos(flickerProgress * 2 * math.pi) * 2.5;

    // 1. Warm radial ambient bloom (Sin disco rígido plano en el piso)
    final bloomCenter = Offset(w * 0.50, h * 0.58);
    final bloomPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isFrozen
                  ? const Color(0xFF00E5FF)
                  : (isActive ? const Color(0xFFFF3D00) : const Color(0xFFFF9100)))
              .withValues(alpha: isActive ? 0.42 : 0.16),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: bloomCenter, radius: w * 0.68));
    canvas.drawCircle(bloomCenter, w * 0.68, bloomPaint);

    // 2. Outer Dynamic Flame Body (Cuerpo exterior de fuego estilizado con 3 crestas orgánicas)
    final outerPath = Path();
    // Punta central alta
    outerPath.moveTo(w * 0.50 + flicker * 0.8, h * 0.05);
    // Cresta derecha superior
    outerPath.cubicTo(w * 0.63 + flicker * 0.4, h * 0.16, w * 0.72, h * 0.25, w * 0.76, h * 0.36);
    // Lengüeta exterior derecha
    outerPath.cubicTo(w * 0.88, h * 0.26 + secondaryFlicker, w * 0.96, h * 0.38, w * 0.90, h * 0.56);
    // Costado derecho bajando al vientre redondeado
    outerPath.cubicTo(w * 0.88, h * 0.76, w * 0.76, h * 0.95, w * 0.50, h * 0.96);
    // Costado izquierdo redondeado
    outerPath.cubicTo(w * 0.24, h * 0.95, w * 0.12, h * 0.76, w * 0.10, h * 0.56);
    // Lengüeta exterior izquierda
    outerPath.cubicTo(w * 0.04, h * 0.38, w * 0.12, h * 0.26 - secondaryFlicker, w * 0.24, h * 0.36);
    // Cresta izquierda superior hacia la punta
    outerPath.cubicTo(w * 0.28, h * 0.25, w * 0.37 - flicker * 0.4, h * 0.16, w * 0.50 + flicker * 0.8, h * 0.05);
    outerPath.close();

    // Degradado ardiente de alta energía
    final outerGradient = isFrozen
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F2FE), Color(0xFF38BDF8), Color(0xFF0284C7)],
          )
        : (isActive
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFEA00), // Oro puro en la punta
                  Color(0xFFFF9100), // Naranja magma
                  Color(0xFFFF3D00), // Rojo fuego vivo
                  Color(0xFFB71C1C), // Carmesí profundo en la base
                ],
                stops: [0.0, 0.28, 0.65, 1.0],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFB300),
                  Color(0xFFFF6F00),
                  Color(0xFF3E2723),
                ],
                stops: [0.0, 0.40, 1.0],
              ));

    final outerPaint = Paint()
      ..shader = outerGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(outerPath, outerPaint);

    // Borde iluminado con resplandor suave
    final rimPaint = Paint()
      ..color = (isFrozen ? const Color(0xFFE0F2FE) : const Color(0xFFFFF9C4))
          .withValues(alpha: isActive ? 0.85 : 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawPath(outerPath, rimPaint);

    // 3. Middle Flame Layer (Capa intermedia vibrante)
    final midFlicker = -flicker * 0.7;
    final midPath = Path();
    midPath.moveTo(w * 0.50 + midFlicker, h * 0.20);
    midPath.cubicTo(w * 0.61 + midFlicker, h * 0.32, w * 0.68, h * 0.44, w * 0.71, h * 0.54);
    midPath.cubicTo(w * 0.78, h * 0.48, w * 0.84, h * 0.56, w * 0.81, h * 0.68);
    midPath.cubicTo(w * 0.78, h * 0.84, w * 0.66, h * 0.90, w * 0.50, h * 0.91);
    midPath.cubicTo(w * 0.34, h * 0.90, w * 0.22, h * 0.84, w * 0.19, h * 0.68);
    midPath.cubicTo(w * 0.16, h * 0.56, w * 0.22, h * 0.48, w * 0.29, h * 0.54);
    midPath.cubicTo(w * 0.32, h * 0.44, w * 0.39 + midFlicker, h * 0.32, w * 0.50 + midFlicker, h * 0.20);
    midPath.close();

    final midGradient = isFrozen
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFF38BDF8)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFDE7),
              Color(0xFFFFEE58),
              Color(0xFFFF9800),
            ],
            stops: [0.0, 0.40, 1.0],
          );

    final midPaint = Paint()
      ..shader = midGradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;
    canvas.drawPath(midPath, midPaint);

    // 4. Inner Luminous Core (Gota incandescente de plasma blanco-dorado)
    final corePath = Path();
    final coreTopY = h * 0.36 + flicker * 0.3;
    corePath.moveTo(w * 0.50, coreTopY);
    corePath.cubicTo(w * 0.63, h * 0.50, w * 0.66, h * 0.68, w * 0.50, h * 0.84);
    corePath.cubicTo(w * 0.34, h * 0.68, w * 0.37, h * 0.50, w * 0.50, coreTopY);
    corePath.close();

    final corePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.65,
        colors: [
          Colors.white,
          (isFrozen ? const Color(0xFF7DD3FC) : const Color(0xFFFFE082))
              .withValues(alpha: 0.90),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(w * 0.30, h * 0.32, w * 0.40, h * 0.55))
      ..style = PaintingStyle.fill;
    canvas.drawPath(corePath, corePaint);

    // 5. Stylized QUIVO Flame Emblem (Emblema 'Q' integrado en el corazón ardiente)
    final emblemCenter = Offset(w * 0.50, h * 0.64);
    final emblemRadius = w * 0.14;

    // Disco sutilmente dorado
    final emblemDiscPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF9C4), Color(0xFFFFB300), Color(0xFFD97706)],
      ).createShader(Rect.fromCircle(center: emblemCenter, radius: emblemRadius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(emblemCenter, emblemRadius, emblemDiscPaint);

    // Emblema "Q" en blanco con trazo nítido
    final qPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    final qRect = Rect.fromCircle(center: emblemCenter, radius: emblemRadius * 0.48);
    canvas.drawOval(qRect, qPaint);
    canvas.drawLine(
      Offset(emblemCenter.dx + emblemRadius * 0.18, emblemCenter.dy + emblemRadius * 0.18),
      Offset(emblemCenter.dx + emblemRadius * 0.50, emblemCenter.dy + emblemRadius * 0.50),
      qPaint,
    );

    // Brillo especular
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(emblemCenter.dx - emblemRadius * 0.38, emblemCenter.dy - emblemRadius * 0.38),
      emblemRadius * 0.20,
      shinePaint,
    );

    // 6. Floating Sparks / Embers drifting upward (Ascuas flotantes ascendentes)
    final emberPaint = Paint()..style = PaintingStyle.fill;
    final emberPositions = [
      Offset(w * 0.40 + flicker * 1.4, h * 0.06),
      Offset(w * 0.68 - flicker * 0.9, h * 0.20),
      Offset(w * 0.26 + flicker * 0.6, h * 0.24),
      Offset(w * 0.82, h * 0.32),
      Offset(w * 0.50 + secondaryFlicker, h * 0.02),
    ];
    for (int i = 0; i < emberPositions.length; i++) {
      final pos = emberPositions[i];
      final r = (1.5 + (i % 2) * 1.3);
      emberPaint.color = (i == 0 ? Colors.white : const Color(0xFFFFD54F))
          .withValues(alpha: (0.65 + 0.35 * math.sin(flickerProgress * math.pi + i)));
      canvas.drawCircle(pos, r, emberPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _QuivoFlamePainter oldDelegate) {
    return oldDelegate.bobOffset != bobOffset ||
        oldDelegate.flickerProgress != flickerProgress ||
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
