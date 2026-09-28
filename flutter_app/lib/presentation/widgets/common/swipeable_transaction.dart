import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/transaction.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/transaction_provider.dart';
import 'custom_snackbar.dart';
import '../modals/add_expense_modal.dart';
import '../modals/add_income_modal.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/localization.dart';

class SwipeableTransaction extends ConsumerWidget {
  final TransactionModel transaction;
  final String? currencyCode;
  final Widget child;

  const SwipeableTransaction({
    super.key,
    required this.transaction,
    required this.currencyCode,
    required this.child,
  });

  void _showActionMenu(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isIncome = transaction.type == 'income';
    final loc = ref.read(localizationProvider);
    final formattedDate = DateFormat(
      "d 'de' MMMM 'de' yyyy",
      'es',
    ).format(transaction.date);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isIncome
                                  ? const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.15)
                                  : const Color(
                                      0xFF3B82F6,
                                    ).withValues(alpha: 0.15),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isIncome
                                  ? LucideIcons.trendingUp
                                  : LucideIcons.shoppingBag,
                              color: isIncome
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF3B82F6),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.description.isNotEmpty
                                      ? transaction.description
                                      : loc.translateCategory(
                                          transaction.category,
                                        ),
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.translateCategory(transaction.category),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              LucideIcons.x,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            onPressed: () => Navigator.pop(context),
                            style: IconButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF1F5F9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount, currencyCode)}',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
                // Action List
                _buildActionTile(
                  context,
                  isDark,
                  'Editar',
                  LucideIcons.edit2,
                  () {
                    Navigator.pop(context);
                    if (isIncome) {
                      AddIncomeModal.show(
                        context,
                        existingTransaction: transaction,
                        isFixed: transaction.isFixed,
                      );
                    } else {
                      AddExpenseModal.show(
                        context,
                        existingTransaction: transaction,
                        isFixed: transaction.isFixed,
                        currencyCode: currencyCode,
                      );
                    }
                  },
                ),
                Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
                _buildActionTile(
                  context,
                  isDark,
                  'Eliminar',
                  LucideIcons.trash2,
                  () {
                    Navigator.pop(context);
                    _executeDelete(context, ref);
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    bool isDark,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDestructive
                    ? const Color(0xFFEF4444)
                    : (isDark ? Colors.white : Colors.black),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              icon,
              color: isDestructive
                  ? const Color(0xFFEF4444)
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _executeDelete(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(transactionNotifierProvider.notifier);
    notifier.deleteTransaction(transaction.id);

    CustomSnackBar.showUndo(context, 'Movimiento eliminado', () {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      notifier.addTransaction(transaction);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onLongPress: () => _showActionMenu(context, ref),
      child: Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) {
          _executeDelete(context, ref);
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444), // Red
            borderRadius: BorderRadius.circular(16), // Match corner radius
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Icon(LucideIcons.trash2, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
