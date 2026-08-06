import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../domain/entities/credit_card.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import 'package:intl/intl.dart';

class CreditCardHistoryModal extends ConsumerStatefulWidget {
  final CreditCard card;
  final ScrollController scrollController;

  const CreditCardHistoryModal({super.key, required this.card, required this.scrollController});

  @override
  ConsumerState<CreditCardHistoryModal> createState() => _CreditCardHistoryModalState();

  static void show(BuildContext context, CreditCard card) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (_, controller) => CreditCardHistoryModal(card: card, scrollController: controller),
      ),
    );
  }

}

class _CreditCardHistoryModalState extends ConsumerState<CreditCardHistoryModal> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (ctx) {
        int tempMonth = _selectedMonth;
        int tempYear = _selectedYear;
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
                                _selectedMonth = tempMonth;
                                _selectedYear = tempYear;
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
    final loc = ref.watch(localizationProvider);
    final currencyCode = ref.watch(authProvider).user?.currency ?? 'GTQ';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 14, bottom: 8),
            height: 5,
            width: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.card.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: widget.card.color.withValues(alpha: 0.3)),
                      ),
                      child: Icon(LucideIcons.history, color: widget.card.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.get('credit_card_history'),
                          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          widget.card.name,
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          
          // Filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black),
                  onPressed: () {
                    setState(() {
                      if (_selectedMonth == 1) {
                        _selectedMonth = 12;
                        _selectedYear--;
                      } else {
                        _selectedMonth--;
                      }
                    });
                  },
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
                          '${['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'][_selectedMonth - 1]} $_selectedYear', 
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
                  onPressed: () {
                    setState(() {
                      if (_selectedMonth == 12) {
                        _selectedMonth = 1;
                        _selectedYear++;
                      } else {
                        _selectedMonth++;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          
          Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), height: 1),

          // Content
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
              data: (allTransactions) {
                final cardTransactions = allTransactions.where((t) => 
                  t.creditCardId == widget.card.id && 
                  !t.isFixed &&
                  t.date.month == _selectedMonth &&
                  t.date.year == _selectedYear
                ).toList();
                cardTransactions.sort((a, b) => b.date.compareTo(a.date));

                if (cardTransactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(50),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(24),
                  itemCount: cardTransactions.length,
                  itemBuilder: (context, index) {
                    final t = cardTransactions[index];
                    final isPayment = t.type == 'cc_payment';
                    final isIncome = t.type == 'income' || isPayment;
                    final categoryLabel = loc.translateCategory(t.category);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                            width: 54, height: 54,
                            decoration: BoxDecoration(
                              color: isIncome 
                                ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.6) : const Color(0xFFECFDF5))
                                : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.6) : const Color(0xFFFEF2F2)),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(
                                isPayment ? '💸' : loc.getCategoryEmoji(t.category),
                                style: const TextStyle(fontSize: 26),
                              ),
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
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text('Abono', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
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
    );
  }
}
