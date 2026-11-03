import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Speed Dial flotante nativo, limpio y minimalista para el botón central (+)
/// Mantiene las 5 funciones completas del sistema:
/// 1. Gasto
/// 2. Ingreso
/// 3. SAMI IA
/// 4. Simulador What-If
/// 5. Descarga PDF
class QuickActionsMenu extends StatefulWidget {
  const QuickActionsMenu({super.key});

  @override
  State<QuickActionsMenu> createState() => _QuickActionsMenuState();
}

class _QuickActionsMenuState extends State<QuickActionsMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss([String? actionId]) async {
    if (_isClosing) return;
    _isClosing = true;
    HapticFeedback.lightImpact();
    await _animController.reverse();
    if (mounted) {
      Navigator.of(context).pop(actionId);
    }
  }

  Widget _buildSpeedDialItem({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required Color shadowColor,
    required VoidCallback onTap,
    required double startInterval,
    required double endInterval,
  }) {
    final itemAnimation = CurvedAnimation(
      parent: _animController,
      curve: Interval(startInterval, endInterval, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: itemAnimation,
      builder: (context, child) {
        final progress = itemAnimation.value;
        return Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1.0 - progress) * 20),
            child: Transform.scale(
              scale: (0.75 + (progress * 0.25)).clamp(0.0, 1.08),
              child: child,
            ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _handleDismiss();
            onTap();
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Frosted Glass Pill Label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D26).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                // Glowing Circular Action Button
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor.withValues(alpha: 0.40),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Blur & Tap to Dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _handleDismiss(),
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) => BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 14 * _fadeAnimation.value,
                    sigmaY: 14 * _fadeAnimation.value,
                  ),
                  child: Container(
                    color: Colors.black.withValues(
                      alpha: 0.55 * _fadeAnimation.value,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Speed Dial Floating Menu
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: bottomPadding > 0 ? 14 : 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 5. 📄 Descarga Reporte PDF
                    _buildSpeedDialItem(
                      title: 'Descargar PDF',
                      icon: LucideIcons.fileText,
                      gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                      shadowColor: const Color(0xFFF59E0B),
                      startInterval: 0.32,
                      endInterval: 0.98,
                      onTap: () => Navigator.of(context).pop('pdf-report'),
                    ),

                    // 4. 🔮 Simulador What-If
                    _buildSpeedDialItem(
                      title: 'Simulador What-If',
                      icon: LucideIcons.sparkles,
                      gradientColors: const [Color(0xFF06B6D4), Color(0xFF0284C7)],
                      shadowColor: const Color(0xFF06B6D4),
                      startInterval: 0.24,
                      endInterval: 0.90,
                      onTap: () => Navigator.of(context).pop('what-if'),
                    ),

                    // 3. 🤖 SAMI IA (Chat Asistente)
                    _buildSpeedDialItem(
                      title: 'SAMI IA',
                      icon: LucideIcons.bot,
                      gradientColors: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      shadowColor: const Color(0xFF8B5CF6),
                      startInterval: 0.16,
                      endInterval: 0.82,
                      onTap: () => Navigator.of(context).pop('ai-chat'),
                    ),

                    // 2. 🟢 Nuevo Ingreso
                    _buildSpeedDialItem(
                      title: 'Nuevo Ingreso',
                      icon: LucideIcons.arrowUpRight,
                      gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                      shadowColor: const Color(0xFF10B981),
                      startInterval: 0.08,
                      endInterval: 0.74,
                      onTap: () => Navigator.of(context).pop('income'),
                    ),

                    // 1. 🔴 Nuevo Gasto
                    _buildSpeedDialItem(
                      title: 'Nuevo Gasto',
                      icon: LucideIcons.arrowDownLeft,
                      gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                      shadowColor: const Color(0xFFEF4444),
                      startInterval: 0.0,
                      endInterval: 0.66,
                      onTap: () => Navigator.of(context).pop('expense'),
                    ),

                    const SizedBox(height: 14),

                    // Center Dismiss FAB (Transforms smoothly from + to ✕)
                    Center(
                      child: GestureDetector(
                        onTap: () => _handleDismiss(),
                        child: AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            return RotationTransition(
                              turns: _rotationAnimation,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF06B6D4),
                                        Color(0xFF0891B2),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF06B6D4).withValues(alpha: 0.45),
                                        blurRadius: 18,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    LucideIcons.plus,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
