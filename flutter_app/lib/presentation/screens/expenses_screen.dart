import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/modals/expenses_filter_modal.dart';
import '../widgets/modals/voice_expense_modal.dart';
import '../widgets/modals/category_detail_modal.dart';
import '../widgets/modals/add_debt_modal.dart';
import '../widgets/modals/add_expense_modal.dart';
import '../providers/color_palette_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/debts_provider.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  late String selectedMonth;
  String selectedCategory = 'Todas';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    try {
      selectedMonth = DateFormat('MMMM', 'es').format(DateTime.now());
      // Capitalize first letter
      selectedMonth = selectedMonth[0].toUpperCase() + selectedMonth.substring(1);
    } catch (_) {
      selectedMonth = DateFormat('MMMM').format(DateTime.now());
    }
  }

  // Category color mapping
  static const Map<String, Color> categoryColors = {
    '🍔': Color(0xFFF43F5E),
    '🚗': Color(0xFF0EA5E9),
    '🏠': Color(0xFF6366F1),
    '🎮': Color(0xFFD946EF),
    '💊': Color(0xFF10B981),
    '📱': Color(0xFFF59E0B),
    '📚': Color(0xFF8B5CF6),
    '💸': Color(0xFF64748B),
    '💼': Color(0xFF059669),
    'food': Color(0xFFF43F5E),
    'transport': Color(0xFF0EA5E9),
    'home': Color(0xFF6366F1),
    'entertainment': Color(0xFFD946EF),
    'health': Color(0xFF10B981),
    'bills': Color(0xFFF59E0B),
    'education': Color(0xFF8B5CF6),
    'shopping': Color(0xFFEC4899),
    'other': Color(0xFF64748B),
  };

  static const Map<String, String> categoryLabels = {
    '🍔': '🍔 Comida',
    '🚗': '🚗 Transporte',
    '🏠': '🏠 Hogar',
    '🎮': '🎮 Entretenimiento',
    '💊': '💊 Salud',
    '📱': '📱 Servicios',
    '📚': '📚 Educación',
    '💸': '💸 Otro',
    '💼': '💼 Salario',
    'food': '🍔 Comida',
    'transport': '🚗 Transporte',
    'home': '🏠 Hogar',
    'entertainment': '🎮 Entretenimiento',
    'health': '💊 Salud',
    'bills': '📱 Servicios',
    'education': '📚 Educación',
    'shopping': '🛍️ Compras',
    'other': '💸 Otro',
  };

  String _getCategoryEmoji(String category) {
    if (category.runes.isNotEmpty && category.runes.first > 127) return category;
    const map = {
      'food': '🍔', 'transport': '🚗', 'shopping': '🛍️', 'bills': '📱',
      'entertainment': '🎮', 'health': '💊', 'education': '📚', 'home': '🏠',
      'other': '💸',
    };
    return map[category] ?? '💰';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ref.watch(colorPaletteProvider);
    final paletteGradient = ref.read(colorPaletteProvider.notifier).getGradient(isDark);
    
    final transactionsAsync = ref.watch(transactionsProvider);
    final debtsAsync = ref.watch(debtsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Mis Gastos 💸',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$selectedMonth 2026${selectedCategory != 'Todas' ? ' • $selectedCategory' : ''}',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => AddExpenseModal.show(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFFB91C1C), const Color(0xFFBE185D)]
                              : [const Color(0xFFDC2626), const Color(0xFFDB2777)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFFDC2626).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.plus, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text('Agregar Gasto', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => AddExpenseModal.show(context, isFixed: true),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF7E22CE), const Color(0xFF4338CA)]
                              : [const Color(0xFF9333EA), const Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF9333EA).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.receipt, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text('Gasto Fijo', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filter
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.search, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (v) => setState(() => searchQuery = v),
                            decoration: InputDecoration(
                              hintText: 'Buscar gastos...',
                              hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () async {
                    final filters = await showModalBottomSheet<Map<String, String>>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const ExpensesFilterModal(),
                    );
                    if (filters != null) {
                      setState(() {
                        selectedMonth = filters['month']!;
                        selectedCategory = filters['category']!;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: paletteGradient[0], 
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Icon(LucideIcons.filter, color: Colors.white, size: 20)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Total Expenses Card — real data
            transactionsAsync.when(
              loading: () => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: paletteGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
              error: (e, _) => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: paletteGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text('Error al cargar gastos: $e', style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
              data: (transactions) {
                final allExpenses = transactions.where((t) => t.type == 'expense').toList();
                
                // Filter by search
                final filteredExpenses = searchQuery.isEmpty
                    ? allExpenses
                    : allExpenses.where((t) =>
                        t.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
                        t.category.toLowerCase().contains(searchQuery.toLowerCase())
                      ).toList();

                // Sort by date descending
                filteredExpenses.sort((a, b) => b.date.compareTo(a.date));

                final totalExpenses = filteredExpenses.fold(0.0, (sum, t) => sum + t.amount);
                final totalIncome = transactions.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount);
                final budgetPercentage = totalIncome > 0 ? (totalExpenses / totalIncome * 100).clamp(0.0, 100.0) : 0.0;

                // Group by category
                final categoryMap = <String, double>{};
                for (var t in filteredExpenses) {
                  categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
                }
                final categoryList = categoryMap.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Total card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: paletteGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total de Gastos - $selectedMonth', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(currencyFormatter.format(totalExpenses), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (budgetPercentage / 100).clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: budgetPercentage > 80 ? const Color(0xFFF87171) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            totalIncome > 0 
                              ? '${budgetPercentage.toStringAsFixed(0)}% de tus ingresos (${currencyFormatter.format(totalIncome)})' 
                              : 'Sin ingresos registrados aún',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category breakdown
                    Text('Gastos por Categoría', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
                    const SizedBox(height: 12),
                    if (categoryList.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F2937) : Colors.white,
                          border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(child: Text('No hay gastos registrados', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]))),
                      ),
                    ...categoryList.map((entry) {
                      final percentage = totalExpenses > 0 ? (entry.value / totalExpenses * 100) : 0.0;
                      final label = categoryLabels[entry.key] ?? '${_getCategoryEmoji(entry.key)} ${entry.key}';
                      final color = categoryColors[entry.key] ?? const Color(0xFF64748B);
                      final categoryData = {
                        'category': label,
                        'amount': entry.value,
                        'percentage': percentage.round(),
                        'color': color,
                      };
                      return InkWell(
                        onTap: () => CategoryDetailModal.show(context, categoryData: categoryData),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F2937) : Colors.white,
                            border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(label, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                                  Text(currencyFormatter.format(entry.value), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 8,
                                width: double.infinity,
                                decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (percentage / 100).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text('${percentage.toStringAsFixed(1)}% del total', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Recent expense history
                    Text('Historial de Gastos', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
                    const SizedBox(height: 12),
                    if (filteredExpenses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('No hay gastos recientes.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]))),
                      ),
                    ...filteredExpenses.map((expense) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: Center(child: Text(_getCategoryEmoji(expense.category), style: const TextStyle(fontSize: 22))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(expense.description.isNotEmpty ? expense.description : expense.category, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${categoryLabels[expense.category] ?? expense.category} • ${DateFormat('d MMM, HH:mm').format(expense.date)}${expense.isFixed ? ' • Fijo' : ''}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text('-${currencyFormatter.format(expense.amount)}', style: TextStyle(color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Debts and Installments — real data
            Text('Deudas y Cuotas Activas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
            const SizedBox(height: 12),
            debtsAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
              error: (e, _) => Text('Error al cargar deudas: $e', style: const TextStyle(color: Colors.red)),
              data: (debtsList) {
                if (debtsList.isEmpty) {
                  return InkWell(
                    onTap: () => AddDebtModal.show(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                        border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.plus, color: isDark ? Colors.grey[400] : Colors.grey[500], size: 18),
                          const SizedBox(width: 8),
                          Text('Agregar primera deuda', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500])),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: debtsList.map((debt) {
                    final progress = debt.totalInstallments > 0 ? (debt.paidInstallments / debt.totalInstallments) : 0.0;
                    final isFullyPaid = debt.paidInstallments >= debt.totalInstallments;
                    return InkWell(
                      onTap: () => AddDebtModal.show(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F2937) : Colors.white,
                          border: Border.all(
                            color: isFullyPaid 
                              ? (isDark ? const Color(0xFF047857) : const Color(0xFF6EE7B7))
                              : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                              child: Center(child: Text(debt.category, style: const TextStyle(fontSize: 24))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text('${debt.name}${isFullyPaid ? ' ✅' : ''}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                                      Text('${currencyFormatter.format(debt.installmentAmount)}/cuota', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 6,
                                    width: double.infinity,
                                    decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: progress.clamp(0.0, 1.0),
                                      child: Container(decoration: BoxDecoration(
                                        color: progress >= 1.0 ? Colors.green : (progress >= 0.5 ? const Color(0xFF6366F1) : const Color(0xFFF59E0B)),
                                        borderRadius: BorderRadius.circular(8),
                                      )),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${debt.paidInstallments} de ${debt.totalInstallments} cuotas', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => VoiceExpenseModal.show(context),
        backgroundColor: Colors.transparent,
        elevation: 10,
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF10B981)]),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: const Icon(LucideIcons.mic, color: Colors.white),
        ),
      ),
    );
  }
}
