import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import 'premium_modal.dart';

class CategoryBudgetModal extends ConsumerStatefulWidget {
  const CategoryBudgetModal({super.key});

  static Future<void> show(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);
    final isPremium = container.read(authProvider).user?.isPremium ?? false;
    if (!isPremium) {
      PremiumModal.show(context);
      return Future.value();
    }
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
    final loc = ref.watch(localizationProvider);
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
                    Text(loc.get('category_budget_title'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    const SizedBox(height: 2),
                    Text(loc.get('category_budget_subtitle'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
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
                      // Quick Preset Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            0.0, 100.0, 300.0, 500.0, 1000.0, 2000.0, 5000.0
                          ].map((preset) {
                            final isSelected = budget == preset;
                            final label = preset == 0.0 ? 'Sin límite' : '$sym${preset.toStringAsFixed(0)}';
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (preset == 0.0) {
                                      tempBudgets.remove(catId);
                                    } else {
                                      tempBudgets[catId] = preset;
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? catColor : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? catColor : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                                    ),
                                  ),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // - $50 Button
                          InkWell(
                            onTap: () {
                              setState(() {
                                final current = tempBudgets[catId] ?? 0.0;
                                final next = (current - 50.0).clamp(0.0, 10000.0);
                                if (next <= 0) {
                                  tempBudgets.remove(catId);
                                } else {
                                  tempBudgets[catId] = next;
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(LucideIcons.minus, size: 16, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: budget.clamp(0.0, 5000.0),
                              min: 0,
                              max: 5000,
                              divisions: 100,
                              activeColor: catColor,
                              inactiveColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                              label: '$sym${budget.toStringAsFixed(0)}',
                              onChanged: (val) {
                                setState(() {
                                  if (val <= 0) {
                                    tempBudgets.remove(catId);
                                  } else {
                                    tempBudgets[catId] = val;
                                  }
                                });
                              },
                            ),
                          ),
                          // + $50 Button
                          InkWell(
                            onTap: () {
                              setState(() {
                                final current = tempBudgets[catId] ?? 0.0;
                                tempBudgets[catId] = (current + 50.0).clamp(0.0, 10000.0);
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(LucideIcons.plus, size: 16, color: isDark ? Colors.grey[300] : Colors.grey[700]),
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
                            budget > 0 ? '${percentage.toStringAsFixed(0)}% usado' : 'Sin límite',
                            style: TextStyle(
                              color: budget <= 0 ? Colors.grey : (percentage >= 100 
                                  ? Colors.red 
                                  : (percentage >= 80 ? Colors.orange : Colors.grey)),
                              fontSize: 12,
                              fontWeight: percentage >= 80 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (budget > 0 && percentage >= 100)
                            Text(loc.get('budget_limit_reached'), style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold))
                          else if (budget > 0 && percentage >= 80)
                            Text(loc.get('budget_near_limit'), style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
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
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    
                    // Check if any category alert triggered
                    String? breachedCategoryName;
                    double breachedLimit = 0.0;
                    double breachedSpent = 0.0;
                    
                    for (var entry in tempBudgets.entries) {
                      final cLimit = entry.value;
                      if (cLimit > 0) {
                        final cSpent = spentByCategory[entry.key] ?? 0.0;
                        if (cSpent >= cLimit) {
                          breachedLimit = cLimit;
                          breachedSpent = cSpent;
                          final match = categories.firstWhere((element) => element['id'] == entry.key, orElse: () => {'name': entry.key});
                          breachedCategoryName = match['name'] as String;
                          break;
                        }
                      }
                    }

                    if (breachedCategoryName != null) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                          title: Row(
                            children: [
                              const Icon(LucideIcons.alertOctagon, color: Colors.red, size: 28),
                              const SizedBox(width: 12),
                              const Text('¡Límite Excedido! 🚨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: Text(
                            'Has agotado el 100% o más de tu presupuesto mensual para la categoría "$breachedCategoryName".\n\n'
                            'Límite fijado: $sym${breachedLimit.toStringAsFixed(0)}\n'
                            'Gasto actual: $sym${breachedSpent.toStringAsFixed(0)}',
                            style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800]),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Entendido', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(loc.get('budget_saved_snack')), backgroundColor: Colors.green),
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
                child: Text(loc.get('save_budgets'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
