import 'dart:ui';
import 'package:flutter/material.dart';
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
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
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
    await _animController.reverse();
    if (mounted) {
      Navigator.pop(context, actionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final actions = [
      {
        'id': 'what-if',
        'label': loc.get('what_if_title'),
        'desc': loc.get('quick_actions_what_if_desc'),
        'icon': LucideIcons.sparkles,
        'gradient': const [Color(0xFF06B6D4), Color(0xFF2563EB)],
        'accent': const Color(0xFF06B6D4),
        'isPremium': true,
      },
      {
        'id': 'rewards-shop',
        'label': loc.get('quick_actions_rewards_shop'),
        'desc': loc.get('quick_actions_rewards_desc'),
        'icon': LucideIcons.gift,
        'gradient': const [Color(0xFFF59E0B), Color(0xFFEA580C)],
        'accent': const Color(0xFFF59E0B),
        'isPremium': false,
      },
      {
        'id': 'category-budget',
        'label': loc.get('category_budget'),
        'desc': loc.get('quick_actions_budget_desc'),
        'icon': LucideIcons.pieChart,
        'gradient': const [Color(0xFF10B981), Color(0xFF059669)],
        'accent': const Color(0xFF10B981),
        'isPremium': true,
      },
      {
        'id': 'ai-chat',
        'label': loc.get('quick_actions_sami_ai'),
        'desc': loc.get('quick_actions_sami_desc'),
        'icon': LucideIcons.bot,
        'gradient': const [Color(0xFF8B5CF6), Color(0xFFD946EF)],
        'accent': const Color(0xFF8B5CF6),
        'isPremium': true,
      },
      {
        'id': 'pdf-report',
        'label': loc.get('pdf_report'),
        'desc': loc.get('quick_actions_pdf_desc'),
        'icon': LucideIcons.fileText,
        'gradient': const [Color(0xFF4F46E5), Color(0xFF3B82F6)],
        'accent': const Color(0xFF4F46E5),
        'isPremium': true,
      },
      {
        'id': 'notifications',
        'label': loc.get('notifications'),
        'desc': loc.get('quick_actions_notif_desc'),
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
          // Frosted Glass Scrim
          GestureDetector(
            onTap: () => _handleDismiss(),
            behavior: HitTestBehavior.opaque,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: (isDark ? const Color(0xFF050811) : Colors.black)
                      .withValues(alpha: isDark ? 0.72 : 0.5),
                ),
              ),
            ),
          ),

          // Main Interactive Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: SafeArea(
                bottom: true,
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxWidth: 500,
                    maxHeight: size.height * 0.88,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A).withValues(alpha: 0.94)
                        : Colors.white.withValues(alpha: 0.97),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155).withValues(alpha: 0.55)
                          : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                        blurRadius: 36,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Header Pill & Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF38BDF8)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF38BDF8)
                                          .withValues(alpha: 0.35),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        LucideIcons.zap,
                                        size: 13,
                                        color: Color(0xFF38BDF8),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        loc.get('quick_actions_hub_title').toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFF38BDF8),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  loc.get('quick_actions_hub_subtitle'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            // Quick Close Circle Icon
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

                        // 2-Column Bento Grid
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
                                  child: _BentoQuickActionCard(
                                    action: action,
                                    isDark: isDark,
                                    onTap: () => _handleDismiss(
                                      action['id'] as String,
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                        const SizedBox(height: 18),

                        // Bottom Close Bar
                        GestureDetector(
                          onTap: () => _handleDismiss(),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155).withValues(alpha: 0.6)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.chevronDown,
                                  size: 18,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  loc.get('quick_actions_close'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFF475569),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoQuickActionCard extends StatefulWidget {
  final Map<String, dynamic> action;
  final bool isDark;
  final VoidCallback onTap;

  const _BentoQuickActionCard({
    required this.action,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_BentoQuickActionCard> createState() => _BentoQuickActionCardState();
}

class _BentoQuickActionCardState extends State<_BentoQuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.action['gradient'] as List<Color>;
    final accent = widget.action['accent'] as Color;
    final isPremium = widget.action['isPremium'] == true;

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accent.withValues(alpha: widget.isDark ? 0.3 : 0.22),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: widget.isDark ? 0.12 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Icon squircle + PRO badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.first.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.action['icon'] as IconData,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.crown,
                            size: 10,
                            color: Colors.white,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                widget.action['label'] as String,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                widget.action['desc'] as String,
                style: TextStyle(
                  color: widget.isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: 11,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
