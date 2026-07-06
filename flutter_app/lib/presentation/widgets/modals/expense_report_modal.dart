import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../modals/category_detail_modal.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';

class ExpenseReportModal extends ConsumerStatefulWidget {
  final List<MapEntry<String, double>> categoryList;
  final double totalExpenses;
  final String selectedMonth;
  final String selectedCategory;
  final String? currencyCode;
  final List<dynamic>? transactions;
  
  const ExpenseReportModal({
    super.key,
    required this.categoryList,
    required this.totalExpenses,
    required this.selectedMonth,
    required this.selectedCategory,
    this.currencyCode,
    this.transactions,
  });

  static Future<void> show(BuildContext context, {
    required List<MapEntry<String, double>> categoryList,
    required double totalExpenses,
    required String selectedMonth,
    required String selectedCategory,
    String? currencyCode,
    List<dynamic>? transactions,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseReportModal(
        categoryList: categoryList,
        totalExpenses: totalExpenses,
        selectedMonth: selectedMonth,
        selectedCategory: selectedCategory,
        currencyCode: currencyCode,
        transactions: transactions,
      ),
    );
  }

  @override
  ConsumerState<ExpenseReportModal> createState() => _ExpenseReportModalState();
}

class _ExpenseReportModalState extends ConsumerState<ExpenseReportModal> {
  int touchedIndex = -1;

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
    'debt': Color(0xFF14B8A6),
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4, width: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gastos por Categoría', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${widget.selectedCategory == "All" ? "Total" : widget.selectedCategory} • ${widget.selectedMonth}', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  style: IconButton.styleFrom(backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), padding: const EdgeInsets.all(8)),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: widget.categoryList.isEmpty
              ? Center(
                  child: Text('No hay gastos para este filtro.', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 16)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Total summary card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TOTAL GASTADO', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(widget.totalExpenses, widget.currencyCode),
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Chart
                      Container(
                        height: 320,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151).withOpacity(0.3) : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(color: (isDark ? Colors.black : const Color(0xFF6366F1)).withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 15)),
                          ],
                          border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB).withOpacity(0.5)),
                        ),
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            sectionsSpace: 4,
                            centerSpaceRadius: 50,
                            sections: widget.categoryList.asMap().entries.map((mapEntry) {
                              final index = mapEntry.key;
                              final entry = mapEntry.value;
                              final isTouched = index == touchedIndex;
                              final percentage = widget.totalExpenses > 0 ? (entry.value / widget.totalExpenses * 100) : 0.0;
                              final mainCategory = entry.key.split('_')[0];
                              final color = categoryColors[mainCategory] ?? categoryColors[entry.key] ?? const Color(0xFF8B5CF6);
                              final emoji = loc.getCategoryEmoji(entry.key);
                              
                              final radius = isTouched ? 80.0 : 70.0;
                              final fontSize = isTouched ? 16.0 : 14.0;
                              final badgeSize = isTouched ? 48.0 : 40.0;
                              final badgeOffset = isTouched ? 1.25 : 1.15;
                              
                              return PieChartSectionData(
                                color: color,
                                value: entry.value,
                                title: '${percentage.toStringAsFixed(0)}%',
                                radius: radius,
                                titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w900, color: Colors.white, shadows: const [Shadow(color: Colors.black45, blurRadius: 4)]),
                                badgeWidget: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: badgeSize,
                                  height: badgeSize,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(isTouched ? 0.4 : 0.2), 
                                        blurRadius: isTouched ? 10 : 6, 
                                        offset: Offset(0, isTouched ? 5 : 3)
                                      )
                                    ],
                                  ),
                                  child: Center(child: Text(emoji, style: TextStyle(fontSize: isTouched ? 24 : 20))),
                                ),
                                badgePositionPercentageOffset: badgeOffset,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Legend / Details
                      Text('Desglose Detallado', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...widget.categoryList.map((entry) {
                        final percentage = widget.totalExpenses > 0 ? (entry.value / widget.totalExpenses * 100) : 0.0;
                        final mainCat = entry.key.split('_')[0];
                        
                        String label = loc.translateCategory(entry.key);
                        final color = categoryColors[mainCat] ?? categoryColors[entry.key] ?? const Color(0xFF64748B);
                        final emoji = loc.getCategoryEmoji(entry.key);
                        
                        // Obtenemos transacciones reales de esta categoria
                        final transactionsForCat = widget.transactions?.where((t) => t.category == entry.key).toList() ?? [];
                        
                        final categoryData = {
                          'category': label,
                          'amount': entry.value,
                          'percentage': percentage.round(),
                          'color': color,
                          'transactions': transactionsForCat,
                          'currencyCode': widget.currencyCode,
                          'emoji': emoji,
                        };
                        return InkWell(
                          onTap: () => CategoryDetailModal.show(context, categoryData: categoryData),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF374151).withOpacity(0.3) : Colors.white,
                              border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(label.replaceAll(RegExp(r'^[^\w\s]+ '), ''), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text('${percentage.toStringAsFixed(1)}% del total', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(CurrencyFormatter.format(entry.value, widget.currencyCode), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
