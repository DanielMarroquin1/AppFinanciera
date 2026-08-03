import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/transaction.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/color_palette_provider.dart';

class PremiumIncomeModal extends ConsumerStatefulWidget {
  final int initialMonth;
  final int initialYear;

  const PremiumIncomeModal({
    super.key,
    required this.initialMonth,
    required this.initialYear,
  });

  static Future<void> show(BuildContext context, int month, int year) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PremiumIncomeModal(initialMonth: month, initialYear: year),
    );
  }

  @override
  ConsumerState<PremiumIncomeModal> createState() => _PremiumIncomeModalState();
}

class _PremiumIncomeModalState extends ConsumerState<PremiumIncomeModal> {
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
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
                                BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))
                              ] : [],
                            ),
                            child: Center(
                              child: Text(
                                monthStr,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    
                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text('Cancelar', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedMonth = tempMonth;
                                selectedYear = tempYear;
                              });
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text('Confirmar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
    final currencyCode = ref.watch(authProvider).user?.currency;
    final loc = ref.watch(localizationProvider);
    final paletteGradient = ref.watch(colorPaletteProvider.notifier).getGradient(isDark);
    
    final transactionsAsync = ref.watch(transactionsProvider);
    final allIncomes = transactionsAsync.value?.where((t) => t.type == 'income' && !t.isFixed).toList() ?? [];
    
    final filteredIncomes = allIncomes.where((t) {
      return t.date.month == selectedMonth && t.date.year == selectedYear;
    }).toList();
    
    filteredIncomes.sort((a, b) => b.date.compareTo(a.date));
    final total = filteredIncomes.fold(0.0, (sum, item) => sum + item.amount);

    String formattedMonth = DateFormat('MMMM', 'es').format(DateTime(selectedYear, selectedMonth));
    formattedMonth = formattedMonth[0].toUpperCase() + formattedMonth.substring(1);
    final displayMonthStr = '$formattedMonth $selectedYear';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, -10)),
        ],
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
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
                      Text(
                        'Ingresos Mensuales',
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(LucideIcons.xCircle, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 28),
                      ),
                    ],
                  ),
                ),
                
                // Selector de fecha
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(LucideIcons.chevronLeft, color: isDark ? Colors.white : Colors.black, size: 28),
                        onPressed: _previousMonth,
                      ),
                      InkWell(
                        onTap: _showMonthPicker,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Text(displayMonthStr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                              const SizedBox(width: 8),
                              Icon(LucideIcons.calendar, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.chevronRight, color: isDark ? Colors.white : Colors.black, size: 28),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Caja de Total
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: paletteGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: paletteGradient[0].withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Percibido', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(total, currencyCode),
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(LucideIcons.trendingUp, color: Colors.white, size: 32),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Historial de Ingresos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          if (filteredIncomes.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(LucideIcons.inbox, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No hay ingresos en $displayMonthStr', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = filteredIncomes[index];
                    final isExtra = tx.description.contains('(Extra)');
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.transparent),
                            ),
                            child: Center(child: Text(loc.getCategoryEmoji(tx.category), style: const TextStyle(fontSize: 28))),
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
                                        tx.description.isNotEmpty ? tx.description : loc.translateCategory(tx.category),
                                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (isExtra)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                                        ),
                                        child: const Text('EXTRA', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  DateFormat('dd MMM, yyyy').format(tx.date),
                                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '+${CurrencyFormatter.format(tx.amount, currencyCode)}',
                            style: const TextStyle(color: Color(0xFF10B981), fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: filteredIncomes.length,
                ),
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
        ],
      ),
    );
  }
}
