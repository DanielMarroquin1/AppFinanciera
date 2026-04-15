import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CategoryDetailModal extends StatelessWidget {
  final Map<String, dynamic> categoryData;

  const CategoryDetailModal({super.key, required this.categoryData});

  static Future<void> show(BuildContext context, {required Map<String, dynamic> categoryData}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => _CategoryDetailModalInternal(categoryData: categoryData, scrollController: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _CategoryDetailModalInternal extends StatelessWidget {
  final Map<String, dynamic> categoryData;
  final ScrollController scrollController;

  const _CategoryDetailModalInternal({required this.categoryData, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = categoryData['color'] as Color? ?? const Color(0xFF4F46E5);
    final categoryName = categoryData['category'] as String? ?? 'Categoría';
    final amount = categoryData['amount'] as double? ?? 0.0;

    // Simulated transactions for this category
    final recentExpenses = [
      {'icon': categoryName.split(' ')[0], 'name': 'Gasto 1', 'date': 'Hoy', 'amount': amount * 0.4},
      {'icon': categoryName.split(' ')[0], 'name': 'Gasto 2', 'date': 'Ayer', 'amount': amount * 0.3},
      {'icon': categoryName.split(' ')[0], 'name': 'Gasto 3', 'date': 'Hace 3 días', 'amount': amount * 0.3},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
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
                      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(categoryName.split(' ')[0], style: const TextStyle(fontSize: 20))), // Emoji
                    ),
                    const SizedBox(width: 12),
                    Text(categoryName.substring(categoryName.indexOf(' ') + 1), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
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
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total gastado en Febrero', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                      const SizedBox(height: 8),
                      Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('${categoryData['percentage']}% de tus gastos totales', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text('Gastos Recientes', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
                const SizedBox(height: 12),
                
                ...recentExpenses.map((expense) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151).withOpacity(0.3) : Colors.white,
                      border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: Text(expense['icon'] as String, style: const TextStyle(fontSize: 24))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(expense['name'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(expense['date'] as String, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(
                          '-\$${(expense['amount'] as double).abs().toStringAsFixed(2)}', 
                          style: TextStyle(
                            color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626), 
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
