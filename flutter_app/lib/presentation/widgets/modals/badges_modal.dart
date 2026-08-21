import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/localization.dart';
import 'dart:ui';

class BadgesModal extends ConsumerStatefulWidget {
  const BadgesModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BadgesModalContent(),
    );
  }

  @override
  ConsumerState<BadgesModal> createState() => _BadgesModalState();
}

class _BadgesModalState extends ConsumerState<BadgesModal> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class BadgesModalContent extends ConsumerStatefulWidget {
  const BadgesModalContent({super.key});

  @override
  ConsumerState<BadgesModalContent> createState() => _BadgesModalContentState();
}

class _BadgesModalContentState extends ConsumerState<BadgesModalContent> {
  Map<String, dynamic>? _selectedBadge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final loc = ref.watch(localizationProvider);

    if (user == null) return const SizedBox.shrink();

    final badges = [
      {
        'id': 'profile',
        'title': loc.get('badge_pioneer'),
        'description': loc.get('badge_pioneer_desc'),
        'icon': LucideIcons.userCheck,
        'color': const Color(0xFF3B82F6),
        'current': user.profileComplete ? 1 : 0,
        'target': 1,
      },
      {
        'id': 'first_tx',
        'title': loc.get('badge_first_tx'),
        'description': loc.get('badge_first_tx_desc'),
        'icon': LucideIcons.rocket,
        'color': const Color(0xFF10B981),
        'current': 1,
        'target': 1,
      },
      {
        'id': 'streak_7',
        'title': loc.get('badge_constant_fire'),
        'description': loc.get('badge_constant_fire_desc'),
        'icon': LucideIcons.flame,
        'color': const Color(0xFFF97316),
        'current': user.currentStreak > 7 ? 7 : user.currentStreak,
        'target': 7,
      },
      {
        'id': 'streak_30',
        'title': loc.get('badge_habit_master'),
        'description': loc.get('badge_habit_master_desc'),
        'icon': LucideIcons.award,
        'color': const Color(0xFFEAB308),
        'current': user.currentStreak > 30 ? 30 : user.currentStreak,
        'target': 30,
      },
      {
        'id': 'shopper_1',
        'title': loc.get('badge_vip_shopper'),
        'description': loc.get('badge_vip_shopper_desc'),
        'icon': LucideIcons.shoppingBag,
        'color': const Color(0xFF8B5CF6),
        'current': user.unlockedItems.isNotEmpty ? 1 : 0,
        'target': 1,
      },
      {
        'id': 'saver_100',
        'title': loc.get('badge_financial_mind'),
        'description': loc.get('badge_financial_mind_desc'),
        'icon': LucideIcons.brain,
        'color': const Color(0xFF06B6D4),
        'current': user.points > 100 ? 100 : user.points,
        'target': 100,
      },
      {
        'id': 'night_owl',
        'title': loc.get('badge_night_owl'),
        'description': loc.get('badge_night_owl_desc'),
        'icon': LucideIcons.moon,
        'color': const Color(0xFF6366F1),
        'current': isDark ? 1 : 0,
        'target': 1,
      },
      {
        'id': 'visionary',
        'title': loc.get('badge_visionary'),
        'description': loc.get('badge_visionary_desc'),
        'icon': LucideIcons.sparkles,
        'color': const Color(0xFFEC4899),
        'current': 0, 
        'target': 1,
      },
      {
        'id': 'budget_king',
        'title': loc.get('badge_budget_king'),
        'description': loc.get('badge_budget_king_desc'),
        'icon': LucideIcons.crown,
        'color': const Color(0xFFF59E0B),
        'current': 1, 
        'target': 1,
      },
    ];

    final unlockedCount = badges.where((b) => (b['current'] as int) >= (b['target'] as int)).length;

    // Helper variables for selected badge
    final selBadge = _selectedBadge;
    final selCurrent = selBadge != null ? (selBadge['current'] as int) : 0;
    final selTarget = selBadge != null ? (selBadge['target'] as int) : 1;
    final selUnlocked = selCurrent >= selTarget;
    final selColor = selBadge != null ? (selBadge['color'] as Color) : Colors.transparent;
    final selIcon = selBadge != null ? (selBadge['icon'] as IconData) : LucideIcons.lock;
    final selTitle = selBadge != null ? (selBadge['title'] as String) : '';
    final selDesc = selBadge != null ? (selBadge['description'] as String) : '';

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 5,
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(3)),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.get('trophies'),
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1, color: isDark ? Colors.white : Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$unlockedCount ${loc.get('unlocked_of')} ${badges.length}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Detail Card (Animated CrossFade)
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: selBadge == null ? const SizedBox.shrink() : Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: selColor.withValues(alpha: 0.3), width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selUnlocked ? selColor.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        selUnlocked ? selIcon : LucideIcons.lock,
                        size: 32,
                        color: selUnlocked ? selColor : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selUnlocked ? selTitle : 'Trofeo Oculto',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selUnlocked ? selDesc : 'Sigue usando la aplicación para descubrir cómo desbloquear este trofeo.',
                            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.4),
                          ),
                          if (!selUnlocked) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: selCurrent / selTarget,
                                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.grey[600]! : Colors.grey[500]!),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: selBadge == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 300),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  final cCurrent = badge['current'] as int;
                  final cTarget = badge['target'] as int;
                  final isUnlocked = cCurrent >= cTarget;
                  final bColor = badge['color'] as Color;
                  final isSelected = selBadge?['id'] == badge['id'];

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        if (isSelected) {
                          _selectedBadge = null;
                        } else {
                          _selectedBadge = badge;
                        }
                      });
                    },
                    child: Container(
                      color: Colors.transparent, // Capture taps
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            width: isSelected ? 80 : 70,
                            height: isSelected ? 80 : 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isUnlocked ? bColor.withValues(alpha: isSelected ? 0.2 : 0.1) : (isDark ? Colors.grey[800] : Colors.grey[200]),
                              boxShadow: isUnlocked && isSelected ? [
                                BoxShadow(color: bColor.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2)
                              ] : [],
                              border: Border.all(
                                color: isUnlocked 
                                    ? bColor.withValues(alpha: isSelected ? 0.8 : 0.2)
                                    : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                                width: isSelected ? 2 : 1,
                              )
                            ),
                            child: Center(
                              child: Icon(
                                isUnlocked ? badge['icon'] as IconData : LucideIcons.lock,
                                size: isSelected ? 36 : 28,
                                color: isUnlocked ? bColor : (isDark ? Colors.grey[600] : Colors.grey[400]),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isUnlocked ? badge['title'] as String : 'Oculto',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                              letterSpacing: -0.2,
                              color: isSelected 
                                  ? (isDark ? Colors.white : Colors.black)
                                  : (isUnlocked ? (isDark ? Colors.grey[300] : Colors.grey[800]) : (isDark ? Colors.grey[600] : Colors.grey[400])),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
