import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TransactionsListModal extends StatelessWidget {
  const TransactionsListModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => TransactionsListModalInternal(scrollController: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Not used directly
  }
}

class TransactionsListModalInternal extends StatelessWidget {
  final ScrollController scrollController;

  const TransactionsListModalInternal({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allTransactions = [
      {'icon': '🛒', 'name': 'Supermercado', 'date': 'Hoy, 10:30 AM', 'amount': -45.50, 'category': 'Comida'},
      {'icon': '🚕', 'name': 'Uber', 'date': 'Ayer, 6:15 PM', 'amount': -12.00, 'category': 'Transporte'},
      {'icon': '☕', 'name': 'Cafe', 'date': 'Ayer, 8:00 AM', 'amount': -4.50, 'category': 'Comida'},
      {'icon': '💼', 'name': 'Salario', 'date': '15 Ene, 2026', 'amount': 3500.00, 'category': 'Ingreso'},
      {'icon': '🎬', 'name': 'Netflix', 'date': '12 Ene, 2026', 'amount': -15.00, 'category': 'Entretenimiento'},
      {'icon': '🍕', 'name': 'Pizza', 'date': '10 Ene, 2026', 'amount': -25.00, 'category': 'Comida'},
      {'icon': '👕', 'name': 'Ropa', 'date': '8 Ene, 2026', 'amount': -120.00, 'category': 'Compras'},
      {'icon': '⚡', 'name': 'Luz', 'date': '5 Ene, 2026', 'amount': -65.00, 'category': 'Servicios'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
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
                Text('Todas las Transacciones', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
          const Divider(),

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: allTransactions.length,
              itemBuilder: (context, index) {
                final tx = allTransactions[index];
                final isIncome = (tx['amount'] as double) > 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF374151).withValues(alpha: 0.3) : Colors.white,
                    border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Text(tx['icon'] as String, style: const TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx['name'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(tx['category'] as String, style: TextStyle(color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5), fontSize: 12)),
                                Text(' • ${tx['date']}', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        isIncome ? '+\$${tx['amount']}' : '-\$${(tx['amount'] as double).abs().toStringAsFixed(2)}', 
                        style: TextStyle(
                          color: isIncome 
                              ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
                              : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)), 
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      ),
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
