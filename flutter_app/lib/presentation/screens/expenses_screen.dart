import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/modals/expenses_filter_modal.dart';
import '../widgets/modals/expense_report_modal.dart';
import '../widgets/modals/voice_expense_modal.dart';
import '../widgets/modals/category_detail_modal.dart';
import '../widgets/modals/add_debt_modal.dart';
import '../widgets/modals/add_expense_modal.dart';
import '../providers/color_palette_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/debts_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/localization.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/transaction.dart';
class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  late int selectedMonth;
  late int selectedYear;
  String selectedCategory = 'Todas';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
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

  List<dynamic> _getFilteredExpenses(List<dynamic> transactions) {
    final allExpenses = transactions.where((t) => t.type == 'expense' && !t.isFixed).toList();
    
    // Filter by month and year
    var timeFiltered = allExpenses.where((t) {
      return t.date.month == selectedMonth && t.date.year == selectedYear;
    }).toList();

    // Filter by category
    if (selectedCategory != 'Todas') {
      timeFiltered = timeFiltered.where((t) {
        return t.category.startsWith(selectedCategory);
      }).toList();
    }

    // Filter by search
    if (searchQuery.isNotEmpty) {
      timeFiltered = timeFiltered.where((t) =>
        t.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
        t.category.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }
    
    timeFiltered.sort((a, b) => b.date.compareTo(a.date));
    return timeFiltered;
  }

  void _showReportModal(
    BuildContext context, 
    List<dynamic> transactions, 
    List<dynamic> debtsList,
    String? currencyCode,
    int rMonth,
    int rYear,
    List<String> rCategories,
    bool includeNormal,
    bool includeFixed,
    bool includeDebts,
  ) {
    var allExpenses = transactions.where((t) => t.type == 'expense').toList();
    
    var timeFiltered = allExpenses.where((t) {
      if (!includeNormal && !t.isFixed) return false;
      if (!includeFixed && t.isFixed) return false;
      return t.date.month == rMonth && t.date.year == rYear;
    }).toList();

    if (!rCategories.contains('Todas')) {
      timeFiltered = timeFiltered.where((t) => rCategories.any((c) => t.category.startsWith(c))).toList();
    }

    final categoryMap = <String, double>{};
    for (var t in timeFiltered) {
      categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
    }

    if (includeDebts) {
      for (var debt in debtsList) {
        if (debt.paidInstallments < debt.totalInstallments || debt.totalInstallments == 0) {
          categoryMap['debt'] = (categoryMap['debt'] ?? 0) + debt.installmentAmount;
        }
      }
    }

    final totalExpenses = categoryMap.values.fold(0.0, (sum, val) => sum + val);
    
    final categoryList = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    String formattedMonth = DateFormat('MMMM yyyy', 'es').format(DateTime(rYear, rMonth));
    formattedMonth = formattedMonth[0].toUpperCase() + formattedMonth.substring(1);
    
    String displayCategory = rCategories.contains('Todas') ? 'Todas' : (rCategories.length == 1 ? rCategories.first : 'Varias Categorías');
      
    ExpenseReportModal.show(
      context,
      categoryList: categoryList,
      totalExpenses: totalExpenses,
      selectedMonth: formattedMonth,
      selectedCategory: displayCategory,
      currencyCode: currencyCode,
      transactions: timeFiltered,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ref.watch(colorPaletteProvider);
    final paletteGradient = ref.read(colorPaletteProvider.notifier).getGradient(isDark);
    
    final transactionsAsync = ref.watch(transactionsProvider);
    final debtsAsync = ref.watch(debtsProvider);
    final authState = ref.watch(authProvider);
    final currencyCode = authState.user?.currency;
    final loc = ref.watch(localizationProvider);

    String formattedMonth = DateFormat('MMMM', 'es').format(DateTime(selectedYear, selectedMonth));
    formattedMonth = formattedMonth[0].toUpperCase() + formattedMonth.substring(1);
    final displayMonthStr = '$formattedMonth $selectedYear';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              loc.get('my_expenses'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$displayMonthStr${selectedCategory != 'Todas' ? ' • $selectedCategory' : ''}',
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.plus, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(loc.get('add_expense'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.receipt, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(loc.get('fixed_expense'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
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
                              hintText: loc.get('search_expenses'),
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
                    final filters = await ExpensesFilterModal.show(
                      context,
                      initialMonth: selectedMonth,
                      initialYear: selectedYear,
                      initialCategories: ['Todas'],
                    );
                    if (filters != null) {
                      final rMonth = filters['month'] as int;
                      final rYear = filters['year'] as int;
                      final rCategories = filters['categories'] as List<String>;
                      final rNormal = filters['includeNormal'] as bool;
                      final rFixed = filters['includeFixed'] as bool;
                      final rDebts = filters['includeDebts'] as bool;
                      
                      final transactions = ref.read(transactionsProvider).value ?? [];
                      final debtsList = ref.read(debtsProvider).value ?? [];
                      
                      _showReportModal(
                        context, transactions, debtsList, currencyCode,
                        rMonth, rYear, rCategories, rNormal, rFixed, rDebts
                      );
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
                final filteredExpenses = _getFilteredExpenses(transactions);

                final totalExpenses = filteredExpenses.fold(0.0, (sum, t) => sum + t.amount);
                final totalIncome = transactions.where((t) => t.type == 'income' && !t.isFixed).fold(0.0, (sum, t) => sum + t.amount);
                final budgetPercentage = totalIncome > 0 ? (totalExpenses / totalIncome * 100).clamp(0.0, 100.0) : 0.0;

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
                          Text('${loc.get('total_expenses_month')} $displayMonthStr', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(CurrencyFormatter.format(totalExpenses, currencyCode), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
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
                              ? '${budgetPercentage.toStringAsFixed(0)}% ${loc.get('of_your_income')} (${CurrencyFormatter.format(totalIncome, currencyCode)})' 
                              : loc.get('no_income_yet'),
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const SizedBox(height: 24),

                    // Active Fixed Expenses Section
                    Builder(
                      builder: (context) {
                        final allExpenses = transactionsAsync.value ?? [];
                        final fixedExpenses = allExpenses.where((t) => t.isFixed && t.type == 'expense').toList();
                        fixedExpenses.sort((a, b) => b.date.compareTo(a.date)); // Sort to get latest
                        final uniqueFixedExpenses = <String, dynamic>{};
                        for (var t in fixedExpenses) {
                          final key = t.description.isNotEmpty ? t.description : t.category;
                          if (!uniqueFixedExpenses.containsKey(key)) {
                            uniqueFixedExpenses[key] = t;
                          }
                        }
                        final activeFixedList = uniqueFixedExpenses.values.toList();

                        if (activeFixedList.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Suscripciones y Gastos Fijos', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
                            const SizedBox(height: 12),
                            ...activeFixedList.map((expense) {
                              return InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return SingleChildScrollView(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                                            left: 24,
                                            right: 24,
                                            top: 24,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isDark 
                                                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] 
                                                : [Colors.white, const Color(0xFFF8FAFC)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                                          ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 40, height: 4,
                                              margin: const EdgeInsets.only(bottom: 24),
                                              decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                                            ),
                                            Container(
                                              width: 72, height: 72,
                                              decoration: BoxDecoration(color: (isDark ? Colors.blue[900] : Colors.blue[50])?.withOpacity(isDark ? 0.3 : 1.0), shape: BoxShape.circle),
                                              child: Center(child: Text(_getCategoryEmoji(expense.category), style: const TextStyle(fontSize: 32))),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              expense.description.isNotEmpty ? expense.description : expense.category, 
                                              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              CurrencyFormatter.format(expense.amount, currencyCode), 
                                              style: TextStyle(color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669), fontSize: 32, fontWeight: FontWeight.w900)
                                            ),
                                            const SizedBox(height: 32),
                                            Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF334155).withOpacity(0.5) : Colors.white,
                                                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(LucideIcons.calendar, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                                                          const SizedBox(width: 8),
                                                          Text('Frecuencia', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                                                        ],
                                                      ),
                                                      Text(expense.recurrenceType == 'weekly' ? 'Semanal' : (expense.recurrenceType == 'bimonthly' ? 'Quincenal' : 'Mensual'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                                                    ],
                                                  ),
                                                  const Divider(height: 24),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(LucideIcons.clock, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                                                          const SizedBox(width: 8),
                                                          Text('Día de cobro', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                                                        ],
                                                      ),
                                                      Text(expense.recurrenceType == 'bimonthly' ? '${expense.recurrenceDay} y ${expense.recurrenceDay2}' : '${expense.recurrenceDay}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 32),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  elevation: 0,
                                                ),
                                                child: const Text('Entendido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ));
                                    }
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
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
                                          color: Colors.blue.withOpacity(0.1), 
                                          borderRadius: BorderRadius.circular(16)
                                        ),
                                        child: Center(child: Text(_getCategoryEmoji(expense.category), style: const TextStyle(fontSize: 26))),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(expense.description.isNotEmpty ? expense.description : expense.category, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
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
                                          Text(CurrencyFormatter.format(expense.amount, currencyCode), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
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
                                            AddExpenseModal.show(context, existingTransaction: expense, isFixed: expense.isFixed, currencyCode: currencyCode);
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
                            }),
                            const SizedBox(height: 24),
                          ],
                        );
                      }
                    ),

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
                            Text('-${CurrencyFormatter.format(expense.amount, currencyCode)}', style: TextStyle(color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 16)),
                            PopupMenuButton<String>(
                              icon: Icon(LucideIcons.moreVertical, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              color: isDark ? const Color(0xFF1F2937) : Colors.white,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  AddExpenseModal.show(context, existingTransaction: expense, isFixed: expense.isFixed, currencyCode: currencyCode);
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                                      title: Text('Eliminar Gasto', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                                      content: Text('¿Estás seguro de que quieres eliminar este gasto? Esta acción no se puede deshacer.', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700])),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(),
                                          child: Text('Cancelar', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref.read(transactionNotifierProvider.notifier).deleteTransaction(expense.id);
                                            Navigator.of(ctx).pop();
                                          },
                                          child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    )
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.edit2, size: 16, color: isDark ? Colors.white : Colors.black),
                                      const SizedBox(width: 8),
                                      Text('Editar', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                final activeDebts = debtsList.where((d) => d.paidInstallments < d.totalInstallments).toList();
                
                if (activeDebts.isEmpty) {
                  return Column(
                    children: [
                      if (debtsList.isNotEmpty) // There are debts, but all are paid
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text('¡Felicidades! No tienes deudas activas.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                        ),
                      InkWell(
                        onTap: () => AddDebtModal.show(context, currencyCode: currencyCode),
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
                              Text(debtsList.isEmpty ? 'Agregar primera deuda' : 'Agregar nueva deuda', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500])),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: activeDebts.map((debt) {
                    final progress = debt.totalInstallments > 0 ? (debt.paidInstallments / debt.totalInstallments) : 0.0;
                    final isFullyPaid = debt.paidInstallments >= debt.totalInstallments;
                    return InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Gestionar Deuda', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  Text('Pagar cuota de ${debt.name}', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 16)),
                                  const SizedBox(height: 8),
                                  Text('Monto: ${CurrencyFormatter.format(debt.installmentAmount, currencyCode)}', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 16)),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final updatedDebt = debt.copyWith(paidInstallments: debt.paidInstallments + 1);
                                        await ref.read(debtNotifierProvider.notifier).updateDebt(updatedDebt);
                                        
                                        final uid = FirebaseAuth.instance.currentUser?.uid;
                                        if (uid != null) {
                                          final transaction = TransactionModel(
                                            id: '',
                                            userId: uid,
                                            amount: debt.installmentAmount,
                                            type: 'expense',
                                            category: debt.category,
                                            description: 'Cuota de ${debt.name}',
                                            date: DateTime.now(),
                                            isFixed: false,
                                          );
                                          await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
                                        }
                                        
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Cuota pagada y registrada como gasto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                              backgroundColor: isDark ? const Color(0xFF065F46) : const Color(0xFF10B981),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: const Text('Agregar Cuota', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1F2937) : Colors.white,
                          border: Border.all(
                            color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
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
                                      Expanded(child: Text(debt.name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                                      Text('${CurrencyFormatter.format(debt.installmentAmount, currencyCode)}/cuota', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
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
