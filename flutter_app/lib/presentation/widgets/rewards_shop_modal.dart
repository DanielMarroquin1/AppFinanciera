import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RewardsShopModal extends StatelessWidget {
  final int userPoints;

  const RewardsShopModal({super.key, required this.userPoints});

  static void show(BuildContext context, {int points = 150}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RewardsShopModal(userPoints: points),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      {
        'title': 'Avatares',
        'color': isDark ? [const Color(0xFF4C1D95), const Color(0xFF831843)] : [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
        'items': [
          {'id': 'avatar1', 'name': 'Avatar Superhéroe', 'desc': 'Desbloquea avatares de superhéroes', 'icon': '🦸', 'cost': 50, 'locked': true},
          {'id': 'avatar2', 'name': 'Avatar Fantasía', 'desc': 'Desbloquea avatares mágicos', 'icon': '🧙', 'cost': 50, 'locked': true},
        ]
      },
      {
        'title': '🎨 Paletas de Colores',
        'color': isDark ? [const Color(0xFF312E81), const Color(0xFF064E3B)] : [const Color(0xFF6366F1), const Color(0xFF10B981)],
        'items': [
          {'id': 'theme1', 'name': 'Paleta Océano', 'desc': 'Tonos azules y turquesa del mar', 'icon': '🌊', 'cost': 100, 'locked': true, 'colors': [Colors.lightBlue, Colors.cyan, Colors.blue]},
          {'id': 'theme2', 'name': 'Paleta Atardecer', 'desc': 'Tonos cálidos de naranja y rosa', 'icon': '🌅', 'cost': 100, 'locked': true, 'colors': [Colors.orange, Colors.pink, Colors.amber]},
        ]
      },
      {
        'title': 'Especiales',
        'color': isDark ? [const Color(0xFF78350F), const Color(0xFF7C2D12)] : [const Color(0xFFF59E0B), const Color(0xFFF97316)],
        'items': [
          {'id': 'spec1', 'name': 'Prueba Premium 7 Días', 'desc': 'Acceso completo por 1 semana', 'icon': '👑', 'cost': 300, 'locked': true},
        ]
      }
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isDark 
                  ? const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFC2410C)])
                  : const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF97316)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(LucideIcons.shoppingBag, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tienda de Recompensas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Canjea tus puntos', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.star, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text('Tus Puntos', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                        ],
                      ),
                      Text('$userPoints', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          // Body
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final gradientColors = category['color'] as List<Color>;
                final items = category['items'] as List<Map<String, dynamic>>;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Header
                    Row(
                      children: [
                        Expanded(child: Container(height: 4, decoration: BoxDecoration(gradient: LinearGradient(colors: gradientColors), borderRadius: BorderRadius.circular(2)))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(category['title'] as String, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontWeight: FontWeight.bold)),
                        ),
                        Expanded(child: Container(height: 4, decoration: BoxDecoration(gradient: LinearGradient(colors: gradientColors), borderRadius: BorderRadius.circular(2)))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Items
                    ...items.map((item) {
                      final canAfford = userPoints >= (item['cost'] as int);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F2937) : Colors.white,
                          border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), width: 2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                              child: Center(child: Text(item['icon'] as String, style: const TextStyle(fontSize: 28))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(item['desc'] as String, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                                  
                                  if (item['colors'] != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: (item['colors'] as List<Color>).map((c) => Expanded(
                                        child: Container(margin: const EdgeInsets.only(right: 4), height: 8, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))),
                                      )).toList(),
                                    ),
                                  ],
                                  
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: canAfford 
                                          ? LinearGradient(colors: [const Color(0xFF4F46E5), const Color(0xFF10B981)])
                                          : null,
                                      color: canAfford ? null : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(canAfford ? LucideIcons.star : LucideIcons.lock, color: canAfford ? Colors.white : Colors.grey, size: 16),
                                        const SizedBox(width: 8),
                                        Text('Canjear por ${item['cost']} pts', style: TextStyle(color: canAfford ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
