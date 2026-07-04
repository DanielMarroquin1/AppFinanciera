import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';

class TransactionsListModal extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink(); // Not used directly
  }
}

class TransactionsListModalInternal extends ConsumerWidget {
  final ScrollController scrollController;

  const TransactionsListModalInternal({super.key, required this.scrollController});

  String _getCategoryEmoji(String category) {
    if (category.runes.isNotEmpty && category.runes.first > 127) return category;
    const map = {
      'food': '🍔', 'transport': '🚗', 'shopping': '🛍️', 'bills': '📱',
      'entertainment': '🎮', 'health': '💊', 'education': '📚', 'home': '🏠',
      'salary': '💼', 'freelance': '💻', 'bonus': '🎁', 'investment': '📈',
      'sale': '🏷️', 'gift': '🎉', 'other': '💸', 'debt': '💳'
    };
    return map[category] ?? '💰';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(transactionsProvider);
    final user = ref.watch(authProvider).user;
    final currencyCode = user?.currency;
    final loc = ref.watch(localizationProvider);

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
            child: transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(child: Text('No hay transacciones registradas', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400])));
                }
                
                final sorted = transactions.where((t) => !t.isFixed).toList()..sort((a, b) => b.date.compareTo(a.date));

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final tx = sorted[index];
                    final isIncome = tx.type == 'income';
                    final formattedDate = DateFormat('dd MMM, yyyy - hh:mm a').format(tx.date);

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
                            child: Center(child: Text(_getCategoryEmoji(tx.category), style: const TextStyle(fontSize: 24))),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tx.description.isNotEmpty ? tx.description : loc.translateCategory(tx.category), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(loc.translateCategory(tx.category), style: TextStyle(color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5), fontSize: 12, fontWeight: FontWeight.w600)),
                                    Expanded(child: Text(' • $formattedDate', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12), overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            isIncome ? '+${CurrencyFormatter.format(tx.amount, currencyCode)}' : '-${CurrencyFormatter.format(tx.amount, currencyCode)}', 
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
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error al cargar transacciones')),
            ),
          )
        ],
      ),
    );
  }
}
