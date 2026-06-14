import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';

class BadgesModal extends ConsumerWidget {
  const BadgesModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => _BadgesModalInternal(scrollController: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class _BadgesModalInternal extends ConsumerWidget {
  final ScrollController scrollController;

  const _BadgesModalInternal({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final user = ref.watch(authProvider).user;

    if (user == null) return const SizedBox.shrink();

    // Define all badges and progress
    final badges = [
      {
        'id': 'profile',
        'title': 'Pionero',
        'description': 'Completa tu perfil al 100%',
        'icon': LucideIcons.userCheck,
        'color': const Color(0xFF3B82F6), // Blue
        'current': user.profileComplete ? 1 : 0,
        'target': 1,
      },
      {
        'id': 'streak_7',
        'title': 'Constante',
        'description': 'Alcanza una racha de 7 días',
        'icon': LucideIcons.flame,
        'color': const Color(0xFFF97316), // Orange
        'current': user.currentStreak > 7 ? 7 : user.currentStreak,
        'target': 7,
      },
      {
        'id': 'streak_30',
        'title': 'Maestro',
        'description': 'Alcanza una racha de 30 días',
        'icon': LucideIcons.award,
        'color': const Color(0xFFEAB308), // Yellow
        'current': user.currentStreak > 30 ? 30 : user.currentStreak,
        'target': 30,
      },
      {
        'id': 'shopper_1',
        'title': 'Comprador',
        'description': 'Compra 1 artículo en la tienda',
        'icon': LucideIcons.shoppingBag,
        'color': const Color(0xFF8B5CF6), // Purple
        'current': user.unlockedItems.isNotEmpty ? 1 : 0,
        'target': 1,
      },
      {
        'id': 'shopper_5',
        'title': 'Coleccionista',
        'description': 'Compra 5 artículos en la tienda',
        'icon': LucideIcons.crown,
        'color': const Color(0xFFEC4899), // Pink
        'current': user.unlockedItems.length > 5 ? 5 : user.unlockedItems.length,
        'target': 5,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            height: 4, width: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: (isDark ? const Color(0xFFEAB308) : const Color(0xFFCA8A04)).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Icon(LucideIcons.medal, color: isDark ? const Color(0xFFEAB308) : const Color(0xFFCA8A04)),
                    ),
                    const SizedBox(width: 12),
                    Text('Mis Insignias', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
          const Divider(),

          Expanded(
            child: GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                final current = badge['current'] as int;
                final target = badge['target'] as int;
                final isUnlocked = current >= target;
                final baseColor = badge['color'] as Color;
                
                final color = isUnlocked ? baseColor : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB));
                final iconColor = isUnlocked ? Colors.white : (isDark ? Colors.grey[500] : Colors.grey[400]);

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF374151).withOpacity(0.3) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: color.withOpacity(isUnlocked ? 0.5 : 0.2), width: 2),
                    boxShadow: isUnlocked && !isDark ? [
                      BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))
                    ] : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          boxShadow: isUnlocked ? [
                            BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
                          ] : [],
                        ),
                        child: Icon(badge['icon'] as IconData, color: iconColor, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        badge['title'] as String,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          badge['description'] as String,
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$current / $target', style: TextStyle(color: isUnlocked ? baseColor : (isDark ? Colors.grey[400] : Colors.grey[600]), fontSize: 12, fontWeight: FontWeight.bold)),
                                if (isUnlocked)
                                  Icon(LucideIcons.checkCircle2, color: baseColor, size: 14),
                              ],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: current / target,
                              backgroundColor: isDark ? const Color(0xFF4B5563) : const Color(0xFFF3F4F6),
                              valueColor: AlwaysStoppedAnimation<Color>(isUnlocked ? baseColor : (isDark ? Colors.grey[400]! : Colors.grey[400]!)),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
