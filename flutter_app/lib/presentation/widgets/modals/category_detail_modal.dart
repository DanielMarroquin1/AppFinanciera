import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/currency_formatter.dart';

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
    final percentage = categoryData['percentage'] as int? ?? 0;
    final currencyCode = categoryData['currencyCode'] as String?;
    final emoji = categoryData['emoji'] as String? ?? '💰';
    
    // Lista de transacciones reales (TransactionModel)
    final transactions = categoryData['transactions'] as List<dynamic>? ?? [];

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
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Text(categoryName.replaceAll(RegExp(r'^[^\w\s]+ '), ''), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
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
                      Text('Total gastado en el periodo', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(CurrencyFormatter.format(amount, currencyCode), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('$percentage% de tus gastos totales', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text('Desglose de Gastos', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
                const SizedBox(height: 12),
                
                if (transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No hay detalles transaccionales específicos para esta categoría.\n(Pudo ser calculado a partir de deudas u otros valores agregados).',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      ),
                    ),
                  )
                else
                  ...transactions.map((t) {
                    final dateStr = DateFormat('dd MMM, yyyy', 'es').format(t.date);
                    final title = t.description.isNotEmpty ? t.description : t.category;

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
                            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Text(dateStr, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(t.amount, currencyCode), 
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
