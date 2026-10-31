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
      duration: const Duration(milliseconds: 280),
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

    final smartTools = [
      {
        'id': 'ai-chat',
        'label': 'Asistente SAMI',
        'desc': 'IA financiera 24/7',
        'icon': LucideIcons.bot,
        'gradient': const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        'accent': const Color(0xFF8B5CF6),
        'isPremium': true,
      },
      {
        'id': 'what-if',
        'label': '¿Qué pasaría si...?',
        'desc': 'Simulador de metas',
        'icon': LucideIcons.sparkles,
        'gradient': const [Color(0xFF06B6D4), Color(0xFF2563EB)],
        'accent': const Color(0xFF06B6D4),
        'isPremium': true,
      },
      {
        'id': 'category-budget',
        'label': 'Presupuesto',
        'desc': 'Límites de gastos',
        'icon': LucideIcons.pieChart,
        'gradient': const [Color(0xFF0D9488), Color(0xFF047857)],
        'accent': const Color(0xFF0D9488),
        'isPremium': true,
      },
      {
        'id': 'armario-sami',
        'label': 'Armario SAMI',
        'desc': 'Tienda y estilo',
        'icon': LucideIcons.gift,
        'gradient': const [Color(0xFFF59E0B), Color(0xFFD97706)],
        'accent': const Color(0xFFF59E0B),
        'isPremium': false,
      },
      {
        'id': 'pdf-report',
        'label': 'Reporte PDF',
        'desc': 'Balance financiero',
        'icon': LucideIcons.fileText,
        'gradient': const [Color(0xFF6366F1), Color(0xFF4338CA)],
        'accent': const Color(0xFF6366F1),
        'isPremium': true,
      },
      {
        'id': 'notifications',
        'label': 'Notificaciones',
        'desc': 'Alertas y recordatorios',
        'icon': LucideIcons.bell,
        'gradient': const [Color(0xFFF43F5E), Color(0xFFBE123C)],
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
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  color: Colors.black.withValues(alpha: isDark ? 0.65 : 0.40),
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
                margin: const EdgeInsets.symmetric(horizontal: 18),
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A).withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.98),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155).withValues(alpha: 0.8)
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.60 : 0.20),
                      blurRadius: 40,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF06B6D4).withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                LucideIcons.plus,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.get('quick_actions'),
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.4,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '¿Qué movimiento deseas registrar?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
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
                              width: 34,
                              height: 34,
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
                                size: 16,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // =======================================================
                      // HERO DUAL ACTIONS: NUEVO GASTO & NUEVO INGRESO
                      // =======================================================
                      Row(
                        children: [
                          // 🔴 NUEVO GASTO
                          Expanded(
                            child: _HeroTransactionActionTile(
                              title: 'Nuevo Gasto',
                              subtitle: 'Registrar salida',
                              icon: LucideIcons.arrowDownRight,
                              gradient: const [
                                Color(0xFFEF4444),
                                Color(0xFFDC2626),
                              ],
                              accentColor: const Color(0xFFEF4444),
                              isDark: isDark,
                              onTap: () => _handleDismiss('expense'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 🟢 NUEVO INGRESO
                          Expanded(
                            child: _HeroTransactionActionTile(
                              title: 'Nuevo Ingreso',
                              subtitle: 'Añadir saldo',
                              icon: LucideIcons.arrowUpRight,
                              gradient: const [
                                Color(0xFF10B981),
                                Color(0xFF059669),
                              ],
                              accentColor: const Color(0xFF10B981),
                              isDark: isDark,
                              onTap: () => _handleDismiss('income'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Section Header: Herramientas Inteligentes
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'HERRAMIENTAS FINANCIERAS',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 2-Column Clean Tactile Action Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = (constraints.maxWidth - 10) / 2;
                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(smartTools.length, (index) {
                              final tool = smartTools[index];
                              return SizedBox(
                                width: cardWidth,
                                child: _SmartToolTile(
                                  tool: tool,
                                  isDark: isDark,
                                  onTap: () =>
                                      _handleDismiss(tool['id'] as String),
                                ),
                              );
                            }),
                          );
                        },
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

// =============================================================================
// HERO TRANSACTION ACTION TILE (Nuevo Gasto / Nuevo Ingreso)
// =============================================================================
class _HeroTransactionActionTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  const _HeroTransactionActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_HeroTransactionActionTile> createState() =>
      _HeroTransactionActionTileState();
}

class _HeroTransactionActionTileState extends State<_HeroTransactionActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _pressController.forward();
      },
      onTapUp: (_) async {
        await _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.gradient,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.38),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                child: Center(
                  child: Icon(widget.icon, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SMART TOOL TILE (SAMI AI, What-If, Category Budget, etc.)
// =============================================================================
class _SmartToolTile extends StatefulWidget {
  final Map<String, dynamic> tool;
  final bool isDark;
  final VoidCallback onTap;

  const _SmartToolTile({
    required this.tool,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_SmartToolTile> createState() => _SmartToolTileState();
}

class _SmartToolTileState extends State<_SmartToolTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.tool['gradient'] as List<Color>;
    final accent = widget.tool['accent'] as Color;
    final isPremium = widget.tool['isPremium'] == true;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        _pressController.forward();
      },
      onTapUp: (_) async {
        await _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.70)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isDark
                  ? const Color(0xFF334155).withValues(alpha: 0.6)
                  : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    widget.tool['icon'] as IconData,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.tool['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: widget.isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPremium) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.tool['desc'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
