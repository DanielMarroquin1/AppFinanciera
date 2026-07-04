import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/credit_card.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
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
    final currencyCode = ref.watch(authProvider).user?.currency ?? 'GTQ';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 650, maxWidth: 480),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 32,
              offset: const Offset(0, 16),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Premium Header with card glow
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    card.color.withValues(alpha: 0.95),
                    card.color.withValues(alpha: 0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                boxShadow: [
                  BoxShadow(color: card.color.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(LucideIcons.creditCard, size: 120, color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(LucideIcons.history, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.get('credit_card_history'),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              card.name,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: transactionsAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator())),
                error: (err, _) => Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('Error: $err', style: TextStyle(color: isDark ? Colors.white : Colors.black)))),
                data: (allTransactions) {
                  final cardTransactions = allTransactions.where((t) => t.creditCardId == card.id && !t.isFixed).toList();
                  cardTransactions.sort((a, b) => b.date.compareTo(a.date));

                  if (cardTransactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(LucideIcons.receipt, size: 48, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              loc.get('no_transactions'),
                              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              loc.get('recent_activity'),
                              style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    shrinkWrap: true,
                    itemCount: cardTransactions.length,
                    itemBuilder: (context, index) {
                      final t = cardTransactions[index];
                      final isPayment = t.type == 'cc_payment';
                      final isIncome = t.type == 'income' || isPayment;
                      final categoryLabel = loc.translateCategory(t.category);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          boxShadow: [
                            if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                color: isIncome 
                                  ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.6) : const Color(0xFFECFDF5))
                                  : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.6) : const Color(0xFFFEF2F2)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                isPayment ? LucideIcons.checkCircle2 : (isIncome ? LucideIcons.arrowDownLeft : LucideIcons.shoppingBag),
                                color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          categoryLabel, 
                                          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isPayment)
                                        Container(
                                          margin: const EdgeInsets.only(left: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('Abono', style: TextStyle(color: const Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                    ],
                                  ),
                                  if (t.description.isNotEmpty && t.description != t.category) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      t.description, 
                                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(LucideIcons.calendar, size: 12, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('d MMM yyyy • HH:mm', loc.intlLocale).format(t.date), 
                                        style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isIncome ? '+' : '-'}${CurrencyFormatter.format(t.amount, currencyCode)}',
                                  style: TextStyle(
                                    color: isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isIncome ? 'Crédito' : 'Cargo',
                                  style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
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
