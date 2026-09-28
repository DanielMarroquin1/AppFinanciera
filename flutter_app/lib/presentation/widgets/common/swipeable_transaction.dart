import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/models/transaction_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/transaction_provider.dart';
import 'custom_snackbar.dart';
import '../modals/add_expense_modal.dart';
import '../modals/add_income_modal.dart';
import 'package:intl/intl.dart';

class SwipeableTransaction extends ConsumerWidget {
  final TransactionModel transaction;
  final String currencyCode;
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
    final formattedDate = DateFormat("d 'de' MMMM 'de' yyyy", 'es').format(transaction.date);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isIncome
                                ? const Color(0xFF10B981).withOpacity(0.15)
                                : const Color(0xFF3B82F6).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            isIncome ? LucideIcons.trendingUp : LucideIcons.shoppingBag,
                            color: isIncome ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.description.isNotEmpty ? transaction.description : transaction.category,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                transaction.category,
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          onPressed: () => Navigator.pop(context),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount, currencyCode)}',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF312E81).withOpacity(isDark ? 0.5 : 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.sparkles, size: 12, color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA)),
                              const SizedBox(width: 4),
                              Text('IA', style: TextStyle(color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA), fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              // Action List
              _buildActionTile(context, isDark, 'Editar', LucideIcons.edit2, () {
                Navigator.pop(context);
                if (isIncome) {
                  AddIncomeModal.show(context, existingTransaction: transaction, isFixed: transaction.isFixed, currencyCode: currencyCode);
                } else {
                  AddExpenseModal.show(context, existingTransaction: transaction, isFixed: transaction.isFixed, currencyCode: currencyCode);
                }
              }),
              Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              _buildActionTile(context, isDark, 'Agregar a registros comunes', LucideIcons.clipboardList, () {
                Navigator.pop(context);
                CustomSnackBar.showSuccess(context, 'Agregado a registros comunes');
              }),
              Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              _buildActionTile(context, isDark, 'Compartir', LucideIcons.share2, () {
                Navigator.pop(context);
                // TODO: Share logic
              }),
              Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              _buildActionTile(context, isDark, 'Eliminar', LucideIcons.trash2, () {
                Navigator.pop(context);
                _executeDelete(context, ref);
              }, isDestructive: true),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTile(BuildContext context, bool isDark, String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
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
                color: isDestructive ? const Color(0xFFEF4444) : (isDark ? Colors.white : Colors.black),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              icon,
              color: isDestructive ? const Color(0xFFEF4444) : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _executeDelete(BuildContext context, WidgetRef ref) {
    // Delete immediately
    ref.read(transactionNotifierProvider.notifier).deleteTransaction(transaction.id);
    
    // Show Undo SnackBar
    _showUndoSnackBar(context, ref);
  }

  void _showUndoSnackBar(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        duration: const Duration(seconds: 4),
        content: Container(
          padding: const EdgeInsets.only(left: 4, right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF14B8A6).withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            children: [
              // Mascot placeholder (using a generic avatar/icon since no specific mascot image is provided, 
              // but we make it look like the requested 3D icon box)
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0F172A),
                ),
                child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 24)), 
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Movimiento eliminado',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2DD4BF),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Deshacer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
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
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
