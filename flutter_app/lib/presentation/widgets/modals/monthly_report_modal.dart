import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import '../../providers/color_palette_provider.dart';
import 'premium_paywall_dialog.dart';

class MonthlyReportModal extends ConsumerStatefulWidget {
  const MonthlyReportModal({super.key});

  static void show(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);
    final isPremium = container.read(authProvider).user?.isPremium ?? false;
    if (!isPremium) {
      PremiumPaywallDialog.show(context, customMessage: 'Genera y exporta tu reporte mensual detallado en PDF con el Plan Premium.');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => MonthlyReportContent(scrollController: controller),
      ),
    );
  }

  @override
  ConsumerState<MonthlyReportModal> createState() => _MonthlyReportModalState();
}

class _MonthlyReportModalState extends ConsumerState<MonthlyReportModal> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}

class MonthlyReportContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const MonthlyReportContent({super.key, required this.scrollController});

  @override
  ConsumerState<MonthlyReportContent> createState() => _MonthlyReportContentState();
}

class _MonthlyReportContentState extends ConsumerState<MonthlyReportContent> {
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
  }

  void _previousMonth() {
    setState(() {
      if (selectedMonth == 1) {
        selectedMonth = 12;
        selectedYear--;
      } else {
        selectedMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (selectedMonth == 12) {
        selectedMonth = 1;
        selectedYear++;
      } else {
        selectedMonth++;
      }
    });
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (ctx) {
        int tempMonth = selectedMonth;
        int tempYear = selectedYear;
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Seleccionar Fecha', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    
                    // Selector de Año
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(LucideIcons.chevronLeft, color: isDark ? Colors.white : Colors.black),
                            onPressed: () => setDialogState(() => tempYear--),
                          ),
                          Text(tempYear.toString(), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.w900)),
                          IconButton(
                            icon: Icon(LucideIcons.chevronRight, color: isDark ? Colors.white : Colors.black),
                            onPressed: () => setDialogState(() => tempYear++),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Selector de Mes
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(12, (index) {
                        final monthNum = index + 1;
                        final isSelected = monthNum == tempMonth;
                        String monthStr = DateFormat('MMM', 'es').format(DateTime(2000, monthNum));
                        monthStr = monthStr[0].toUpperCase() + monthStr.substring(1);
                        
                        return GestureDetector(
                          onTap: () => setDialogState(() => tempMonth = monthNum),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 65,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)])
                                  : null,
                              color: isSelected ? null : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? Colors.transparent 
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(color: const Color(0xFF10B981).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                              ] : [],
                            ),
                            child: Center(
                              child: Text(
                                monthStr,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    
                    // Botones de Acción
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancelar', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16)),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedMonth = tempMonth;
                                selectedYear = tempYear;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text('Confirmar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(transactionsProvider);
    final authState = ref.watch(authProvider);
    final currencyCode = authState.user?.currency ?? 'GTQ';
    final loc = ref.watch(localizationProvider);
    
    final paletteGradient = ref.watch(colorPaletteProvider.notifier).getGradient(isDark);

    String formattedMonth = DateFormat('MMMM yyyy', loc.intlLocale).format(DateTime(selectedYear, selectedMonth));
    formattedMonth = formattedMonth[0].toUpperCase() + formattedMonth.substring(1);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (transactions) {
          double totalIncome = 0;
          double totalExpense = 0;
          Map<String, double> categoryExpenses = {};

          for (var t in transactions) {
            if (t.isFixed) continue;
            if (t.date.month == selectedMonth && t.date.year == selectedYear) {
              if (t.type == 'income') {
                totalIncome += t.amount;
              } else if (t.type == 'expense') {
                // Ignore fixed templates? No, templates shouldn't be counted, only real expenses.
                if (t.isFixed) continue; 
                totalExpense += t.amount;
                
                // Exclude CC payments from category breakdown if they are just payments,
                // but normally expenses are standard categories.
                if (t.creditCardId == null) {
                   categoryExpenses[t.category] = (categoryExpenses[t.category] ?? 0) + t.amount;
                }
              } else if (t.type == 'cc_payment') {
                // Cash out
                totalExpense += t.amount;
              }
            }
          }
          
          final netBalance = totalIncome - totalExpense;

          var sortedCategories = categoryExpenses.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 24),
                    Text('Reporte Mensual', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    const SizedBox(height: 24),
                    
                    // Month Selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black),
                            onPressed: _previousMonth,
                          ),
                          InkWell(
                            onTap: _showMonthPicker,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formattedMonth, 
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(LucideIcons.calendar, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right, color: isDark ? Colors.white : Colors.black),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Totals
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Ingresos',
                              amount: totalIncome,
                              color: const Color(0xFF10B981),
                              icon: LucideIcons.trendingUp,
                              currencyCode: currencyCode,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              title: 'Gastos',
                              amount: totalExpense,
                              color: const Color(0xFFEF4444),
                              icon: LucideIcons.trendingDown,
                              currencyCode: currencyCode,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: paletteGradient),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: paletteGradient[0].withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Flujo Neto', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                            Text(CurrencyFormatter.format(netBalance, currencyCode), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Gastos por Categoría', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              
              if (sortedCategories.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text('No hay gastos en este mes.', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400])),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = sortedCategories[index];
                      final percentage = totalExpense > 0 ? (category.value / totalExpense) : 0.0;
                      return _buildCategoryItem(
                        loc.translateCategory(category.key),
                        category.value,
                        percentage,
                        currencyCode,
                        isDark,
                        emoji: loc.getCategoryEmoji(category.key),
                      );
                    },
                    childCount: sortedCategories.length,
                  ),
                ),
                
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required double amount, required Color color, required IconData icon, required String currencyCode}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(CurrencyFormatter.format(amount, currencyCode), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, double amount, double percentage, String currencyCode, bool isDark, {String emoji = '💰'}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                    Text(CurrencyFormatter.format(amount, currencyCode), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 8,
                ),
                const SizedBox(height: 4),
                Text('${(percentage * 100).toStringAsFixed(1)}%', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
