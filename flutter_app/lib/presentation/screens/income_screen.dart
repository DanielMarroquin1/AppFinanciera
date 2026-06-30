import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../domain/entities/transaction.dart';
import '../widgets/modals/add_income_modal.dart';
import '../providers/color_palette_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/debts_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/localization.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
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

  List<dynamic> _getFilteredIncomes(List<dynamic> transactions) {
    final allIncomes = transactions.where((t) => t.type == 'income' && !t.isFixed).toList();
    
    // Filter by month and year
    var timeFiltered = allIncomes.where((t) {
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



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ref.watch(colorPaletteProvider);
    final paletteGradient = ref.read(colorPaletteProvider.notifier).getGradient(isDark);
    
    final transactionsAsync = ref.watch(transactionsProvider);
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
            Row(
              children: [
                InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.arrowLeft, color: isDark ? Colors.white : Colors.black),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.get('my_incomes') ?? 'Mis Ingresos',
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => AddIncomeModal.show(context),
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
                          Text(loc.get('add_income'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => AddIncomeModal.show(context, isFixed: true),
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
                          Text(loc.get('fixed_income'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search
            Container(
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
                        hintText: 'Buscar ingreso...',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Total Incomes Card — real data
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
                child: Text('Error al cargar ingresos: $e', style: const TextStyle(color: Colors.white, fontSize: 14)),
              ),
              data: (transactions) {
                final filteredIncomes = _getFilteredIncomes(transactions);
                final totalIncomes = filteredIncomes.fold(0.0, (sum, t) => sum + t.amount);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.trendingUp, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ingresos de $displayMonthStr', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(CurrencyFormatter.format(totalIncomes, currencyCode), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Active Fixed Incomes Section
                Builder(
                      builder: (context) {
                        final allIncomes = transactionsAsync.value ?? [];
                        final fixedIncomes = allIncomes.where((t) => t.isFixed && t.type == 'income').toList();
                        fixedIncomes.sort((a, b) => b.date.compareTo(a.date)); // Sort to get latest
                        final uniqueFixedIncomes = <String, dynamic>{};
                        for (var t in fixedIncomes) {
                          final key = t.description.isNotEmpty ? t.description : t.category;
                          if (!uniqueFixedIncomes.containsKey(key)) {
                            uniqueFixedIncomes[key] = t;
                          }
                        }
                        final activeFixedList = uniqueFixedIncomes.values.toList();

                        if (activeFixedList.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ingreso Fijo', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
                            const SizedBox(height: 12),
                            ...activeFixedList.map((income) {
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
                                            Text('Detalle de Ingreso Fijo', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 16),
                                            Text('Concepto: ${income.description.isNotEmpty ? income.description : income.category}', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 16)),
                                            const SizedBox(height: 8),
                                            Text('Monto: ${CurrencyFormatter.format(income.amount, currencyCode)}', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 16)),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Día de cobro: ${income.recurrenceType == 'bimonthly' ? '${income.recurrenceDay} y ${income.recurrenceDay2}' : income.recurrenceDay}',
                                              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 16)
                                            ),
                                            const SizedBox(height: 8),
                                            Text('Frecuencia: ${income.recurrenceType == 'weekly' ? 'Semanal' : (income.recurrenceType == 'bimonthly' ? 'Quincenal' : 'Mensual')}', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 16)),
                                            const SizedBox(height: 24),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isDark ? const Color(0xFF4F46E5) : const Color(0xFF4338CA),
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                ),
                                                child: const Text('Cerrar'),
                                              ),
                                            )
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
                                    border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48, height: 48,
                                        decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), shape: BoxShape.circle),
                                        child: Center(child: Text(_getCategoryEmoji(income.category), style: const TextStyle(fontSize: 22))),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(income.description.isNotEmpty ? income.description : income.category, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Cobro ${income.recurrenceType == 'weekly' ? 'Semanal' : (income.recurrenceType == 'bimonthly' ? 'Quincenal' : 'Mensual')}',
                                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(CurrencyFormatter.format(income.amount, currencyCode), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                                      PopupMenuButton<String>(
                                        icon: Icon(LucideIcons.moreVertical, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
                                        color: isDark ? const Color(0xFF374151) : Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            AddIncomeModal.show(context, isFixed: true, existingTransaction: income);
                                          } else if (value == 'delete') {
                                            ref.read(transactionNotifierProvider.notifier).deleteTransaction(income.id);
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

                    // Recent income history
                    Text('Historial de Ingresos', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
                    const SizedBox(height: 12),
                    if (filteredIncomes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('No hay ingresos recientes.', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]))),
                      ),
                    ...filteredIncomes.map((income) {
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
                              child: Center(child: Text(_getCategoryEmoji(income.category), style: const TextStyle(fontSize: 22))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(income.description.isNotEmpty ? income.description : income.category, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${categoryLabels[income.category] ?? income.category} • ${DateFormat('d MMM, HH:mm').format(income.date)}${income.isFixed ? ' • Fijo' : ''}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text('+${CurrencyFormatter.format(income.amount, currencyCode)}', style: TextStyle(color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 16)),
                            PopupMenuButton<String>(
                              icon: Icon(LucideIcons.moreVertical, size: 20, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              color: isDark ? const Color(0xFF1F2937) : Colors.white,
                              onSelected: (value) {
                                if (value == 'edit') {
                                  AddIncomeModal.show(context, existingTransaction: income, isFixed: income.isFixed);
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                                      title: Text('Eliminar Ingreso', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                                      content: Text('¿Estás seguro de que quieres eliminar este ingreso? Esta acción no se puede deshacer.', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700])),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(),
                                          child: Text('Cancelar', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            ref.read(transactionNotifierProvider.notifier).deleteTransaction(income.id);
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
          ],
        ),
      ),
    );
  }
}
