import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/utils/localization.dart';

class QuickActionsMenu extends ConsumerWidget {
  const QuickActionsMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);

    final actions = [
      {
        'id': 'savings-goal',
        'label': loc.get('quick_actions_new_goal'),
        'icon': LucideIcons.target,
        'gradient': isDark 
            ? const [Color(0xFF1D4ED8), Color(0xFF0E7490)]
            : const [Color(0xFF2563EB), Color(0xFF0891B2)],
        'isPremium': false,
      },
      {
        'id': 'my-savings',
        'label': loc.get('my_savings').replaceAll(' 🎯', ''),
        'icon': LucideIcons.piggyBank,
        'gradient': isDark 
            ? const [Color(0xFF0E7490), Color(0xFF0369A1)]
            : const [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
        'isPremium': false,
      },
      {
        'id': 'my-savings',
        'label': 'Mis Ahorros',
        'icon': LucideIcons.piggyBank,
        'gradient': isDark 
            ? const [Color(0xFF0E7490), Color(0xFF0369A1)] // cyan-700 to sky-700
            : const [Color(0xFF06B6D4), Color(0xFF0EA5E9)], // cyan-500 to sky-500
        'isPremium': false,
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
        'icon': LucideIcons.messageSquare,
        'gradient': isDark 
            ? const [Color(0xFF7E22CE), Color(0xFF4338CA)]
            : const [Color(0xFF9333EA), Color(0xFF4F46E5)],
        'isPremium': true,
      },
    ];

    // Filtramos para eliminar duplicados de 'my-savings' que pudieran haber
    final uniqueActions = <String, Map<String, dynamic>>{};
    for (var action in actions) {
      uniqueActions[action['id'] as String] = action;
    }
    final filteredActions = uniqueActions.values.toList();

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, bottom: 24.0),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Cabecera "Acciones rápidas"
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.get('quick_actions'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Lista de acciones
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ...filteredActions.map((action) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(action['id']);
                          },
                          child: Container(
                            padding: const EdgeInsets.only(left: 20, right: 8, top: 8, bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (action['isPremium'] == true) ...[
                                  const Icon(LucideIcons.crown, color: Colors.orange, size: 14),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  action['label'] as String,
                                  style: const TextStyle(
                                    color: Color(0xFF1E293B), // Azul marino muy oscuro / gris oscuro
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: action['gradient'] as List<Color>,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(action['icon'] as IconData, color: Colors.white, size: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Botón de cerrar "X"
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.x, color: Color(0xFF3B82F6), size: 24),
                  ),
                ),
              ),
              // Espaciado adicional para igualar la posición del FAB original
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
