import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import 'add_income_modal.dart';
import 'add_expense_modal.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class QuickActionManagerModal extends ConsumerWidget {
  final String type; // 'income' or 'expense'

  const QuickActionManagerModal({super.key, required this.type});

  static Future<void> show(BuildContext context, {required String type}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => _QuickActionManagerModalInternal(type: type, scrollController: scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}

class _QuickActionManagerModalInternal extends ConsumerWidget {
  final String type;
  final ScrollController scrollController;

  const _QuickActionManagerModalInternal({required this.type, required this.scrollController});

  String _getCategoryEmoji(String category) {
    if (category.runes.isNotEmpty && category.runes.first > 127) return category;
    const map = {
      'food': '🍔', 'transport': '🚗', 'shopping': '🛍️', 'bills': '📱',
      'entertainment': '🎮', 'health': '💊', 'education': '📚', 'home': '🏠',
      'other': '💸', 'debt': '💳', 'salary': '💼', 'freelance': '💻',
      'bonus': '🎁', 'investment': '📈', 'sale': '🏷️', 'gift': '🎉'
    };
    return map[category] ?? '💰';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final user = ref.watch(authProvider).user;
    final currencyCode = user?.currency;

    final isIncome = type == 'income';
    final title = isIncome ? 'Gestión de Ingresos' : 'Gestión de Gastos';
    final primaryColor = isIncome 
        ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
        : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626));

    final bgColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
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
                      decoration: BoxDecoration(color: primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Icon(isIncome ? LucideIcons.trendingUp : LucideIcons.trendingDown, color: primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
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
                // Acciones
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          if (isIncome) context.push('/incomes');
                          else AddExpenseModal.show(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            border: Border.all(color: primaryColor.withOpacity(0.3), width: 2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(LucideIcons.plusCircle, color: primaryColor, size: 28),
                              const SizedBox(height: 8),
                              Text('Agregar Variable', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          if (isIncome) AddIncomeModal.show(context, isFixed: true);
                          else AddExpenseModal.show(context, isFixed: true);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.blue[900] : Colors.blue[50])?.withOpacity(isDark ? 0.3 : 1.0),
                            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(LucideIcons.repeat, color: Colors.blue, size: 28),
                              const SizedBox(height: 8),
                              Text('Agregar Fijo', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Text('Historial de ${isIncome ? 'Ingresos' : 'Gastos'} Fijos', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                transactionsAsync.when(
                  data: (allTransactions) {
                    final fixedList = allTransactions.where((t) => t.type == type && t.isFixed).toList();
                    fixedList.sort((a, b) => b.date.compareTo(a.date));
                    
                    final uniqueFixedList = <String, dynamic>{};
                    for (var t in fixedList) {
                      final key = t.description.isNotEmpty ? t.description : t.category;
                      if (!uniqueFixedList.containsKey(key)) {
                        uniqueFixedList[key] = t;
                      }
                    }
                    final activeFixedList = uniqueFixedList.values.toList();

                    if (activeFixedList.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text('No tienes ${isIncome ? 'ingresos' : 'gastos'} fijos activos.', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400])),
                        ),
                      );
                    }

                    return Column(
                      children: activeFixedList.map((expense) {
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            if (isIncome) {
                              AddIncomeModal.show(context, isFixed: true, existingTransaction: expense);
                            } else {
                              AddExpenseModal.show(context, isFixed: true, existingTransaction: expense);
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark 
                                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] 
                                  : [Colors.white, const Color(0xFFF8FAFC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? Colors.black : Colors.blue.withOpacity(0.05)).withOpacity(isDark ? 0.2 : 1),
                                  blurRadius: 10, offset: const Offset(0, 4)
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52, height: 52,
                                  decoration: BoxDecoration(
                                    color: (isIncome ? Colors.green : Colors.blue).withOpacity(0.1), 
                                    borderRadius: BorderRadius.circular(16)
                                  ),
                                  child: Center(child: Text(loc.getCategoryEmoji(expense.category), style: const TextStyle(fontSize: 26))),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(expense.description.isNotEmpty ? expense.description : loc.translateCategory(expense.category), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Día ${expense.recurrenceDay} • ${expense.recurrenceType == 'weekly' ? 'Semanal' : (expense.recurrenceType == 'bimonthly' ? 'Quincenal' : 'Mensual')}',
                                          style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(CurrencyFormatter.format(expense.amount, currencyCode), style: TextStyle(color: isIncome ? (isDark ? const Color(0xFF10B981) : const Color(0xFF059669)) : (isDark ? Colors.white : Colors.black), fontWeight: FontWeight.w900, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('Suscripción', style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), fontSize: 10)),
                                  ],
                                ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                icon: Icon(LucideIcons.moreVertical, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
                                color: isDark ? const Color(0xFF374151) : Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.pop(context); // Close the quick action modal first
                                    if (isIncome) {
                                      AddIncomeModal.show(context, isFixed: true, existingTransaction: expense);
                                    } else {
                                      AddExpenseModal.show(context, isFixed: true, existingTransaction: expense);
                                    }
                                  } else if (value == 'delete') {
                                    ref.read(transactionNotifierProvider.notifier).deleteTransaction(expense.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(LucideIcons.edit2, size: 18, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                                        const SizedBox(width: 8),
                                        Text('Editar', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                                        const SizedBox(width: 8),
                                        Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error al cargar datos.'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
