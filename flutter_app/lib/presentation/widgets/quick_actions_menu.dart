import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/utils/localization.dart';

class QuickActionsMenu extends ConsumerStatefulWidget {
  const QuickActionsMenu({super.key});

  @override
  ConsumerState<QuickActionsMenu> createState() => _QuickActionsMenuState();
}

class _QuickActionsMenuState extends ConsumerState<QuickActionsMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
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
    final loc = ref.watch(localizationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      {
        'id': 'what-if',
        'label': loc.get('what_if_title') ?? '¿Qué pasaría si...?',
        'icon': LucideIcons.sparkles,
        'gradient': const [Color(0xFF06B6D4), Color(0xFF2563EB)],
        'accent': const Color(0xFF06B6D4),
        'isPremium': true,
      },
      {
        'id': 'rewards-shop',
        'label': loc.get('quick_actions_rewards_shop') ?? 'Tienda de Premios',
        'icon': LucideIcons.gift,
        'gradient': const [Color(0xFFF59E0B), Color(0xFFEA580C)],
        'accent': const Color(0xFFF59E0B),
        'isPremium': false,
      },
      {
        'id': 'category-budget',
        'label': loc.get('category_budget') ?? 'Presupuesto',
        'icon': LucideIcons.pieChart,
        'gradient': const [Color(0xFF10B981), Color(0xFF059669)],
        'accent': const Color(0xFF10B981),
        'isPremium': true,
      },
      {
        'id': 'ai-chat',
        'label': loc.get('quick_actions_sami_ai') ?? 'Asistente SAMI',
        'icon': LucideIcons.bot,
        'gradient': const [Color(0xFF8B5CF6), Color(0xFFD946EF)],
        'accent': const Color(0xFF8B5CF6),
        'isPremium': true,
      },
      {
        'id': 'pdf-report',
        'label': loc.get('pdf_report') ?? 'Reporte PDF',
        'icon': LucideIcons.fileText,
        'gradient': const [Color(0xFF6366F1), Color(0xFF3B82F6)],
        'accent': const Color(0xFF6366F1),
        'isPremium': true,
      },
      {
        'id': 'notifications',
        'label': loc.get('notifications') ?? 'Notificaciones',
        'icon': LucideIcons.bell,
        'gradient': const [Color(0xFFF43F5E), Color(0xFFE11D48)],
        'accent': const Color(0xFFF43F5E),
        'isPremium': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismissible blurred background
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _handleDismiss(),
              behavior: HitTestBehavior.opaque,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  color: Colors.black.withValues(alpha: isDark ? 0.60 : 0.35),
                ),
              ),
            ),
          ),

          // Floating Center Modal Card
          Center(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                constraints: const BoxConstraints(maxWidth: 390),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A).withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.55 : 0.18),
                      blurRadius: 36,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.get('quick_actions') ?? 'Acciones Rápidas',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.4,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loc.get('quick_actions_hub_subtitle') ?? 'Herramientas financieras y accesos directos',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Close Button
                          GestureDetector(
                            onTap: () => _handleDismiss(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Icon(
                                LucideIcons.x,
                                size: 18,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 2-Column Clean Tactile Action Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = (constraints.maxWidth - 12) / 2;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: List.generate(actions.length, (index) {
                              final action = actions[index];
                              return SizedBox(
                                width: cardWidth,
                                child: _HumanQuickActionTile(
                                  action: action,
                                  isDark: isDark,
                                  onTap: () => _handleDismiss(action['id'] as String),
                                ),
                              );
                            }),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // Bottom Floating Close FAB
                      GestureDetector(
                        onTap: () => _handleDismiss(),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFCBD5E1),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            LucideIcons.x,
                            size: 24,
                            color: isDark ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
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

class _HumanQuickActionTile extends StatefulWidget {
  final Map<String, dynamic> action;
  final bool isDark;
  final VoidCallback onTap;

  const _HumanQuickActionTile({
    required this.action,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_HumanQuickActionTile> createState() => _HumanQuickActionTileState();
}

class _HumanQuickActionTileState extends State<_HumanQuickActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.91).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails _) async {
    await _pressController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.action['gradient'] as List<Color>;
    final accent = widget.action['accent'] as Color;
    final isPremium = widget.action['isPremium'] == true;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.65)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accent.withValues(alpha: widget.isDark ? 0.28 : 0.20),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: widget.isDark ? 0.12 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular Vibrant Icon Badge
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: gradient.first.withValues(alpha: 0.40),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.action['icon'] as IconData,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Label (Centered, Bold, Never truncated)
                  Text(
                    widget.action['label'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),

              // Subtle, Classy PRO Indicator (Never aggressive)
              if (isPremium)
                Positioned(
                  top: -6,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.crown, size: 9, color: Color(0xFFF59E0B)),
                        SizedBox(width: 2),
                        Text(
                          'PRO',
                          style: TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
