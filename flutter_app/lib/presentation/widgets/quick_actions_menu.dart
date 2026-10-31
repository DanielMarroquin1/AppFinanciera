import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class QuickActionsMenu extends ConsumerStatefulWidget {
  const QuickActionsMenu({super.key});

  @override
  ConsumerState<QuickActionsMenu> createState() => _QuickActionsMenuState();
}

class _QuickActionsMenuState extends ConsumerState<QuickActionsMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF131E27) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF1B2834) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF243645) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismissible backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _handleDismiss(),
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) => BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10 * _fadeAnimation.value,
                    sigmaY: 10 * _fadeAnimation.value,
                  ),
                  child: Container(
                    color: Colors.black.withValues(
                      alpha: 0.50 * _fadeAnimation.value,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Action Sheet (Native iOS/Fintech style)
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border(
                    top: BorderSide(color: borderColor, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF334756)
                                  : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Header Row
                        Row(
                          children: [
                            Text(
                              'Nuevo Movimiento',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _handleDismiss(),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? const Color(0xFF1E2D3B)
                                      : const Color(0xFFF1F5F9),
                                ),
                                child: Icon(
                                  LucideIcons.x,
                                  size: 16,
                                  color: subtitleColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 🔴 Registrar Gasto
                        _ActionListRow(
                          icon: LucideIcons.arrowDownLeft,
                          iconBg: const Color(0xFFEF4444),
                          title: 'Registrar Gasto',
                          subtitle: 'Compras, servicios, salidas o pagos',
                          cardBg: cardBg,
                          borderColor: borderColor,
                          titleColor: titleColor,
                          subtitleColor: subtitleColor,
                          onTap: () => _handleDismiss('expense'),
                        ),

                        const SizedBox(height: 10),

                        // 🟢 Registrar Ingreso
                        _ActionListRow(
                          icon: LucideIcons.arrowUpRight,
                          iconBg: const Color(0xFF10B981),
                          title: 'Registrar Ingreso',
                          subtitle: 'Sueldo, depósitos, transferencias o cobros',
                          cardBg: cardBg,
                          borderColor: borderColor,
                          titleColor: titleColor,
                          subtitleColor: subtitleColor,
                          onTap: () => _handleDismiss('income'),
                        ),

                        const SizedBox(height: 18),

                        // Subtle Divider
                        Divider(color: borderColor, height: 1),
                        const SizedBox(height: 14),

                        // Quick Navigation Shortcuts
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ShortcutIconPill(
                              icon: LucideIcons.bot,
                              label: 'SAMI AI',
                              color: const Color(0xFF8B5CF6),
                              isDark: isDark,
                              onTap: () => _handleDismiss('ai-chat'),
                            ),
                            _ShortcutIconPill(
                              icon: LucideIcons.sparkles,
                              label: 'Simulador',
                              color: const Color(0xFF06B6D4),
                              isDark: isDark,
                              onTap: () => _handleDismiss('what-if'),
                            ),
                            _ShortcutIconPill(
                              icon: LucideIcons.pieChart,
                              label: 'Presupuesto',
                              color: const Color(0xFF0D9488),
                              isDark: isDark,
                              onTap: () => _handleDismiss('category-budget'),
                            ),
                            _ShortcutIconPill(
                              icon: LucideIcons.shirt,
                              label: 'Armario',
                              color: const Color(0xFFF59E0B),
                              isDark: isDark,
                              onTap: () => _handleDismiss('armario-sami'),
                            ),
                          ],
                        ),
                      ],
                    ),
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

// =============================================================================
// ACTION LIST ROW (Clean, Human, Native iOS/Fintech)
// =============================================================================
class _ActionListRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Color cardBg;
  final Color borderColor;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onTap;

  const _ActionListRow({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.cardBg,
    required this.borderColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: subtitleColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: subtitleColor.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SHORTCUT ICON PILL (Clean icon + label)
// =============================================================================
class _ShortcutIconPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ShortcutIconPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.16 : 0.10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 20),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFD6E2E8) : const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
