import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../../core/utils/currency_formatter.dart';

class CategoryBudgetModal extends ConsumerStatefulWidget {
  const CategoryBudgetModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CategoryBudgetModal(),
    );
  }

  @override
  ConsumerState<CategoryBudgetModal> createState() => _CategoryBudgetModalState();
}

class _CategoryBudgetModalState extends ConsumerState<CategoryBudgetModal> {
  final Map<String, double> tempBudgets = {};

  final categories = [
    {'id': 'food', 'name': 'Comida 🍔', 'color': const Color(0xFFF43F5E)},
    {'id': 'transport', 'name': 'Transporte 🚗', 'color': const Color(0xFF0EA5E9)},
    {'id': 'bills', 'name': 'Servicios 📱', 'color': const Color(0xFF06B6D4)},
    {'id': 'home', 'name': 'Hogar 🏠', 'color': const Color(0xFF6366F1)},
    {'id': 'entertainment', 'name': 'Entretenimiento 🎮', 'color': const Color(0xFFD946EF)},
    {'id': 'health', 'name': 'Salud 💊', 'color': const Color(0xFF10B981)},
    {'id': 'shopping', 'name': 'Compras 🛍️', 'color': const Color(0xFFF59E0B)},
    {'id': 'education', 'name': 'Educación 🎓', 'color': const Color(0xFF8B5CF6)},
    {'id': 'other', 'name': 'Otros 📦', 'color': const Color(0xFF6B7280)},
  ];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null && user.categoryBudgets != null) {
      user.categoryBudgets!.forEach((key, value) {
        tempBudgets[key] = (value as num).toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final transactions = ref.watch(transactionsProvider).value ?? [];
    final sym = CurrencyFormatter.getSymbol(user?.currency);

    // Calculate current month's expenses grouped by category
    final now = DateTime.now();
    final currentMonthExpenses = transactions.where((t) =>
        t.type == 'expense' &&
        t.date.year == now.year &&
        t.date.month == now.month);

    final Map<String, double> spentByCategory = {};
    for (var tx in currentMonthExpenses) {
      final mainCat = tx.category.split('_')[0];
      spentByCategory[mainCat] = (spentByCategory[mainCat] ?? 0.0) + tx.amount;
    }

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Presupuesto por Categoría', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    const SizedBox(height: 2),
                    Text('Límites mensuales de gasto', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final catId = cat['id'] as String;
                final catName = cat['name'] as String;
                final catColor = cat['color'] as Color;
                
                final budget = tempBudgets[catId] ?? 0.0;
                final spent = spentByCategory[catId] ?? 0.0;
                final percentage = budget > 0 ? ((spent / budget) * 100).clamp(0.0, 100.0) : 0.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(catName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            '$sym${spent.toStringAsFixed(0)} / $sym${budget.toStringAsFixed(0)}',
                            style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: budget.clamp(0.0, 2000.0),
                              min: 0,
                              max: 2000,
                              divisions: 40,
                              activeColor: catColor,
                              inactiveColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                              label: '$sym${budget.toStringAsFixed(0)}',
                              onChanged: (val) {
                                setState(() {
                                  tempBudgets[catId] = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: catColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${percentage.toStringAsFixed(0)}% usado',
                            style: TextStyle(
                              color: percentage >= 100 
                                  ? Colors.red 
                                  : (percentage >= 80 ? Colors.orange : Colors.grey),
                              fontSize: 12,
                              fontWeight: percentage >= 80 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (percentage >= 100)
                            const Text('⚠️ ¡Límite alcanzado!', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold))
                          else if (percentage >= 80)
                            const Text('⚠️ Cerca del límite', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (user != null) {
                    final updated = user.copyWith(categoryBudgets: tempBudgets);
                    await ref.read(authProvider.notifier).updateProfile(updated);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Presupuestos actualizados correctamente'), backgroundColor: Colors.green),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Guardar Presupuestos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
