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
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _handleDismiss([String? actionId]) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(actionId);
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
          // Dismissible top scrim
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _handleDismiss(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),

          // Docked Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                // Swipe down to dismiss
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! > 220) {
                  _handleDismiss();
                }
              },
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: 520,
                  maxHeight: size.height * 0.88,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            const Color(0xFF0F172A),
                            const Color(0xFF0B1222),
                            const Color(0xFF070B14),
                          ]
                        : [
                            Colors.white,
                            const Color(0xFFF8FAFC),
                            const Color(0xFFF1F5F9),
                          ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.45)
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
                      blurRadius: 36,
                      offset: const Offset(0, -10),
                    ),
                    if (isDark)
                      BoxShadow(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, -2),
                      ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag Handle
                        Container(
                          width: 44,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Header Row with Title Badge and Close X
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
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF38BDF8)
                                            .withValues(alpha: 0.18),
                                        const Color(0xFF0284C7)
                                            .withValues(alpha: 0.12),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF38BDF8)
                                          .withValues(alpha: 0.4),
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
                                        loc
                                            .get('quick_actions_hub_title')
                                            .toUpperCase(),
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
                                const SizedBox(height: 5),
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
                            // Quick Close Circle Icon Button
                            _HeaderCloseButton(
                              isDark: isDark,
                              onTap: () => _handleDismiss(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // 2-Column Bento Grid with Staggered Entrance Animations
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cardWidth = (constraints.maxWidth - 12) / 2;
                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: List.generate(actions.length, (index) {
                                final action = actions[index];

                                // Staggered curve for this card
                                final startInterval =
                                    (0.06 + index * 0.08).clamp(0.0, 0.95);
                                final endInterval =
                                    (startInterval + 0.38).clamp(0.0, 1.0);

                                final cardScale = Tween<double>(
                                  begin: 0.82,
                                  end: 1.0,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _staggerController,
                                    curve: Interval(
                                      startInterval,
                                      endInterval,
                                      curve: Curves.easeOutBack,
                                    ),
                                  ),
                                );

                                final cardSlide = Tween<Offset>(
                                  begin: const Offset(0, 24),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _staggerController,
                                    curve: Interval(
                                      startInterval,
                                      endInterval,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                                );

                                final cardFade = Tween<double>(
                                  begin: 0.0,
                                  end: 1.0,
                                ).animate(
                                  CurvedAnimation(
                                    parent: _staggerController,
                                    curve: Interval(
                                      startInterval,
                                      endInterval,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                );

                                return AnimatedBuilder(
                                  animation: _staggerController,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: cardSlide.value,
                                      child: Transform.scale(
                                        scale: cardScale.value,
                                        child: Opacity(
                                          opacity: cardFade.value.clamp(0.0, 1.0),
                                          child: child,
                                        ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: cardWidth,
                                    child: _BentoQuickActionCard(
                                      action: action,
                                      isDark: isDark,
                                      onTap: () =>
                                          _handleDismiss(action['id'] as String),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Bottom Close Bar
                        _BottomCloseBar(
                          isDark: isDark,
                          label: loc.get('quick_actions_close'),
                          onTap: () => _handleDismiss(),
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

class _HeaderCloseButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _HeaderCloseButton({required this.isDark, required this.onTap});

  @override
  State<_HeaderCloseButton> createState() => _HeaderCloseButtonState();
}

class _HeaderCloseButtonState extends State<_HeaderCloseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - 0.12 * _controller.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            border: Border.all(
              color: widget.isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            LucideIcons.x,
            size: 18,
            color: widget.isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _BottomCloseBar extends StatefulWidget {
  final bool isDark;
  final String label;
  final VoidCallback onTap;

  const _BottomCloseBar({
    required this.isDark,
    required this.label,
    required this.onTap,
  });

  @override
  State<_BottomCloseBar> createState() => _BottomCloseBarState();
}

class _BottomCloseBarState extends State<_BottomCloseBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - 0.03 * _controller.value;
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark
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
                color: widget.isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
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
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
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

  Future<void> _handleTap() async {
    if (_isTapped) return;
    setState(() => _isTapped = true);
    HapticFeedback.mediumImpact();

    // Trigger visual press bounce
    await _pressController.forward();
    // Allow user to see the tactile bounce and glow flash
    await Future.delayed(const Duration(milliseconds: 130));

    if (mounted) {
      _pressController.reverse();
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.action['gradient'] as List<Color>;
    final accent = widget.action['accent'] as Color;
    final isPremium = widget.action['isPremium'] == true;

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) => _handleTap(),
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF1E293B).withValues(alpha: 0.65)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isTapped
                  ? accent
                  : accent.withValues(alpha: widget.isDark ? 0.32 : 0.22),
              width: _isTapped ? 1.8 : 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(
                  alpha: _isTapped
                      ? 0.35
                      : (widget.isDark ? 0.12 : 0.08),
                ),
                blurRadius: _isTapped ? 20 : 14,
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
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.action['icon'] as IconData,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  if (isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF59E0B).withValues(alpha: 0.25),
                            const Color(0xFFEA580C).withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.crown,
                            size: 10,
                            color: Color(0xFFF59E0B),
                          ),
                          SizedBox(width: 3),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 10,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),

              // Subtitle
              Text(
                widget.action['desc'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  fontWeight: FontWeight.w400,
                  color: widget.isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
