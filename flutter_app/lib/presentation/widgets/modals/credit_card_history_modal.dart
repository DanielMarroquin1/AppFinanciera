import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/credit_card.dart';
import '../../providers/transaction_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import 'package:intl/intl.dart';

class CreditCardHistoryModal extends ConsumerWidget {
  final CreditCard card;

  const CreditCardHistoryModal({super.key, required this.card});

  static void show(BuildContext context, CreditCard card) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => CreditCardHistoryModal(card: card),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(transactionsProvider);
    final loc = ref.watch(localizationProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 12),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    card.color.withValues(alpha: 0.8),
                    card.color,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(LucideIcons.creditCard, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historial',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                        ),
                        Text(
                          card.name,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: transactionsAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
                error: (err, _) => Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('Error: $err', style: TextStyle(color: isDark ? Colors.white : Colors.black)))),
                data: (allTransactions) {
                  final cardTransactions = allTransactions.where((t) => t.creditCardId == card.id && !t.isFixed).toList();
                  cardTransactions.sort((a, b) => b.date.compareTo(a.date));

                  if (cardTransactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.receipt, size: 48, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Sin movimientos',
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    shrinkWrap: true,
                    itemCount: cardTransactions.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final t = cardTransactions[index];
                      final isPayment = t.type == 'cc_payment';
                      final isIncome = t.type == 'income' || isPayment;
                      
                      return Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: isIncome 
                                ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5))
                                : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEF2F2)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isPayment ? LucideIcons.checkCircle : (isIncome ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight),
                              color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.category, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 16)),
                                if (t.description.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(t.description, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                                ],
                                Text(DateFormat('d MMM yyyy, HH:mm', loc.intlLocale).format(t.date), style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 11)),
                              ],
                            ),
                          ),
                          Text(
                            '${isIncome ? '+' : '-'}${CurrencyFormatter.format(t.amount, 'GTQ')}',
                            style: TextStyle(
                              color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      );
                    },
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
