import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/modals/expenses_filter_modal.dart';
import '../widgets/modals/voice_expense_modal.dart';
import '../widgets/modals/category_detail_modal.dart';
import '../widgets/modals/add_debt_modal.dart';
import '../widgets/modals/add_expense_modal.dart';
import '../providers/color_palette_provider.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  String selectedMonth = 'Febrero';
  String selectedCategory = 'Todas';

  final expenses = [
    {'category': '🍔 Comida', 'amount': 450.50, 'percentage': 35, 'color': const Color(0xFFF43F5E)},
    {'category': '🚗 Transporte', 'amount': 280.00, 'percentage': 22, 'color': const Color(0xFF0EA5E9)},
    {'category': '🏠 Hogar', 'amount': 520.00, 'percentage': 40, 'color': const Color(0xFF6366F1)},
    {'category': '🎮 Entretenimiento', 'amount': 150.00, 'percentage': 12, 'color': const Color(0xFFD946EF)},
    {'category': '💊 Salud', 'amount': 95.00, 'percentage': 7, 'color': const Color(0xFF10B981)},
  ];

  final recentExpensesTree = [
    {
      'date': 'Hoy',
      'items': [
        {'icon': '🛒', 'name': 'Walmart', 'time': '10:30 AM', 'amount': 45.50, 'category': 'Hogar'},
      ]
    },
    {
      'date': 'Ayer',
      'items': [
        {'icon': '🚕', 'name': 'Uber', 'time': '6:15 PM', 'amount': 12.00, 'category': 'Transporte'},
        {'icon': '☕', 'name': 'Starbucks', 'time': '8:00 AM', 'amount': 8.50, 'category': 'Comida'},
      ]
    },
    {
      'date': '2 de Febrero',
      'items': [
        {'icon': '🍕', 'name': 'Pizza Hut', 'time': '8:00 PM', 'amount': 32.00, 'category': 'Comida'},
        {'icon': '⚡', 'name': 'Luz (CFE)', 'time': '12:00 PM', 'amount': 245.00, 'category': 'Servicios'},
        {'icon': '🎬', 'name': 'Netflix', 'time': '9:00 AM', 'amount': 15.00, 'category': 'Entretenimiento'},
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paletteGradient = ref.watch(colorPaletteProvider.notifier).getGradient(isDark);

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by AppShell
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

            // Action buttons: Agregar Gasto + Gasto Fijo
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
                      color: (selectedCategory != 'Todas' || selectedMonth != 'Febrero') 
                          ? const Color(0xFFEC4899) // pink active filter
                          : paletteGradient[0], 
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Icon(LucideIcons.filter, color: Colors.white, size: 20)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Total Expenses Card
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
                  const Text('\$2,550.00', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.67, // 67%
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('67% de tu presupuesto mensual (\$3800.00)', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Expenses by Category
            Text('Gastos por Categoría', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
            const SizedBox(height: 12),
            ...expenses.map((expense) {
              return InkWell(
                onTap: () => CategoryDetailModal.show(context, categoryData: expense),
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
                          Text(expense['category'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                          Text('\$${(expense['amount'] as double).toStringAsFixed(2)}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: ((expense['percentage'] as int) / 100).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: expense['color'] as Color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('${expense['percentage']}% del total', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            
            // Installments / Cuotas Activas
            Text('Deudas y Cuotas Activas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => AddDebtModal.show(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
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
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('📱', style: TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('iPhone 15 Pro', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('\$65.00/cuota', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 4 / 12,
                              child: Container(decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(8))),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('4 de 12 cuotas (Pulsa para editar)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Redesigned Recent Transactions History
            Text('Historial de Gastos', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
            const SizedBox(height: 12),
            ...recentExpensesTree.map((dayGroup) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayGroup['date'] as String,
                      style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ...(dayGroup['items'] as List<dynamic>).map((expense) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: Center(child: Text(expense['icon'] as String, style: const TextStyle(fontSize: 22))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(expense['name'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text('${expense['category']} • ${expense['time']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('-\$${(expense['amount'] as double).toStringAsFixed(2)}', style: TextStyle(color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 80), // For FAB
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
            gradient: isDark 
                ? const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF10B981)])
                : const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF10B981)]),
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
