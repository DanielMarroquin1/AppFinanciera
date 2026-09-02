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

class _QuickActionsMenuState extends ConsumerState<QuickActionsMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _scaleAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localizationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      {
        'id': 'what-if',
        'label': loc.get('what_if_title'),
        'icon': LucideIcons.cpu,
        'gradient': isDark 
            ? const [Color(0xFF1D4ED8), Color(0xFF0E7490)]
            : const [Color(0xFF2563EB), Color(0xFF0891B2)],
        'isPremium': true,
      },
      {
        'id': 'rewards-shop',
        'label': loc.get('quick_actions_rewards_shop'),
        'icon': LucideIcons.shoppingBag,
        'gradient': isDark 
            ? const [Color(0xFFD97706), Color(0xFFC2410C)]
            : const [Color(0xFFFBBF24), Color(0xFFF97316)],
        'isPremium': false,
      },
      {
        'id': 'category-budget',
        'label': loc.get('category_budget'),
        'icon': LucideIcons.sliders,
        'gradient': isDark 
            ? const [Color(0xFF047857), Color(0xFF065F46)]
            : const [Color(0xFF059669), Color(0xFF10B981)],
        'isPremium': true,
      },
      {
        'id': 'ai-chat',
        'label': loc.get('ai_assistant'),
        'icon': LucideIcons.sparkles,
        'gradient': isDark 
            ? const [Color(0xFF7E22CE), Color(0xFF4338CA)]
            : const [Color(0xFF9333EA), Color(0xFF4F46E5)],
        'isPremium': true,
      },
      {
        'id': 'pdf-report',
        'label': 'Reporte PDF',
        'icon': LucideIcons.fileText,
        'gradient': isDark 
            ? const [Color(0xFF047857), Color(0xFF065F46)]
            : const [Color(0xFF059669), Color(0xFF10B981)],
        'isPremium': true,
      },
      {
        'id': 'notifications',
        'label': 'Notificaciones',
        'icon': LucideIcons.bell,
        'gradient': isDark 
            ? const [Color(0xFFBE123C), Color(0xFF9F1239)]
            : const [Color(0xFFF43F5E), Color(0xFFE11D48)],
        'isPremium': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Blur
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.65)),
              ),
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      loc.get('quick_actions').toUpperCase(),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Animated Grid
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: List.generate(actions.length, (index) {
                      final action = actions[index];
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _animController,
                          curve: Interval(index * 0.1, 1.0, curve: Curves.easeOutBack),
                        ),
                        child: AnimatedPremiumHoverItem(
                          onTap: () async {
                            await _animController.reverse();
                            if (mounted) Navigator.pop(context, action['id']);
                          },
                          action: action,
                          isDark: isDark,
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Close FAB
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: GestureDetector(
                      onTap: () async {
                        await _animController.reverse();
                        if (mounted) Navigator.pop(context);
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: Transform.rotate(
                          angle: 45 * 3.1415927 / 180,
                          child: Icon(LucideIcons.plus, color: isDark ? Colors.white : Colors.black87, size: 32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedPremiumHoverItem extends StatefulWidget {
  final Map<String, dynamic> action;
  final bool isDark;
  final VoidCallback onTap;

  const AnimatedPremiumHoverItem({super.key, required this.action, required this.isDark, required this.onTap});

  @override
  State<AnimatedPremiumHoverItem> createState() => _AnimatedPremiumHoverItemState();
}

class _AnimatedPremiumHoverItemState extends State<AnimatedPremiumHoverItem> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  }
  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2 columns
    final itemWidth = (MediaQuery.of(context).size.width - 48 - 16) / 2;
    final color = (widget.action['gradient'] as List<Color>)[0];

    return GestureDetector(
      onTapDown: (_) => _bounceController.forward(),
      onTapUp: (_) {
        _bounceController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _bounceController.reverse(),
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          final scale = 1.0 - (_bounceController.value * 0.08);
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: itemWidth,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, HSLColor.fromColor(color).withLightness(0.3).toColor()],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Icon(widget.action['icon'] as IconData, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.action['label'] as String,
                    style: TextStyle(
                      color: widget.isDark ? Colors.grey[200] : Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (widget.action['isPremium'] == true)
                Positioned(
                  top: -8,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.4), blurRadius: 4)],
                    ),
                    child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
