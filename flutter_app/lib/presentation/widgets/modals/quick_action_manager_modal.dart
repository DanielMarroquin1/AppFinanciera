import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/color_palette_provider.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final user = ref.watch(authProvider).user;
    final currencyCode = user?.currency;

    final isIncome = type == 'income';
    final title = isIncome ? 'Gestión de Ingresos' : 'Gestión de Gastos';
    final subtitle = isIncome ? 'Registra y controla tu flujo de dinero' : 'Administra y lleva el control de tus salidas';

    final gradientColors = isIncome 
        ? [const Color(0xFF10B981), const Color(0xFF059669)]
        : [const Color(0xFFEF4444), const Color(0xFFDC2626)];

    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, -10))
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: gradientColors[0].withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Icon(isIncome ? LucideIcons.trendingUp : LucideIcons.trendingDown, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text(subtitle, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(LucideIcons.xCircle, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 28),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 16),
                
                // Botones Modernos
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          if (isIncome) context.push('/incomes');
                          else AddExpenseModal.show(context);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F2937) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: gradientColors[0].withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(LucideIcons.plus, color: gradientColors[0], size: 28),
                              ),
                              const SizedBox(height: 12),
                              Text(isIncome ? 'Ingreso Variable' : 'Gasto Único', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
                              const SizedBox(height: 4),
                              Text('Solo una vez', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 11), textAlign: TextAlign.center),
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
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: isDark 
                                ? const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF172554)])
                                : const LinearGradient(colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)]),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFBFDBFE)),
                            boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.repeat, color: Colors.blue, size: 28),
                              ),
                              const SizedBox(height: 12),
                              Text(isIncome ? 'Ingreso Fijo' : 'Suscripción/Fijo', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
                              const SizedBox(height: 4),
                              const Text('Recurrente', style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Text('Historial Fijo Automático', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
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
                          child: Column(
                            children: [
                              Icon(LucideIcons.inbox, size: 48, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('No tienes ${isIncome ? 'ingresos' : 'gastos'} fijos activos.', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400])),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: activeFixedList.map((expense) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F2937) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Navigator.pop(context);
                                if (isIncome) {
                                  AddIncomeModal.show(context, isFixed: true, existingTransaction: expense);
                                } else {
                                  AddExpenseModal.show(context, isFixed: true, existingTransaction: expense);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 52, height: 52,
                                      decoration: BoxDecoration(
                                        color: gradientColors[0].withValues(alpha: 0.1), 
                                        borderRadius: BorderRadius.circular(16)
                                      ),
                                      child: Center(child: Text(loc.getCategoryEmoji(expense.category), style: const TextStyle(fontSize: 26))),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            expense.description.isNotEmpty ? expense.description : loc.translateCategory(expense.category), 
                                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE2E8F0)),
                                            ),
                                            child: Text(
                                              loc.formatRecurrenceSubtitle(expense.recurrenceType, expense.recurrenceDay, expense.recurrenceDay2),
                                              style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${isIncome ? '+' : '-'}${CurrencyFormatter.format(expense.amount, currencyCode)}', 
                                          style: TextStyle(color: gradientColors[0], fontWeight: FontWeight.w900, fontSize: 16)
                                        ),
                                        const SizedBox(height: 4),
                                        Text(isIncome ? 'FIJO' : 'SUSCRIPCIÓN', style: TextStyle(color: isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      icon: Icon(LucideIcons.moreVertical, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
                                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                              Icon(LucideIcons.edit2, size: 18, color: isDark ? Colors.white : Colors.black),
                                              const SizedBox(width: 12),
                                              Text('Editar', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                                              const SizedBox(width: 12),
                                              Text('Eliminar', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error al cargar datos.'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          )
        ],
      ),
    );
  }
}
