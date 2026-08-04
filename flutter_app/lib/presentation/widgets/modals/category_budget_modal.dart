import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import 'premium_paywall_dialog.dart';

class CategoryBudgetModal extends ConsumerStatefulWidget {
  const CategoryBudgetModal({super.key});

  static Future<void> show(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);
    final isPremium = container.read(authProvider).user?.isPremium ?? false;
    if (!isPremium) {
      PremiumPaywallDialog.show(context, customMessage: 'Establece límites de presupuesto por categoría y mantén tus gastos bajo control con el Plan Premium.');
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
  String? _expandedCategoryId;

  final categories = [
    {'id': 'food', 'name': 'Comida', 'emoji': '🍔', 'color': const Color(0xFFF43F5E)},
    {'id': 'transport', 'name': 'Transporte', 'emoji': '🚗', 'color': const Color(0xFF0EA5E9)},
    {'id': 'bills', 'name': 'Servicios', 'emoji': '📱', 'color': const Color(0xFF06B6D4)},
    {'id': 'home', 'name': 'Hogar', 'emoji': '🏠', 'color': const Color(0xFF6366F1)},
    {'id': 'entertainment', 'name': 'Entretenimiento', 'emoji': '🎮', 'color': const Color(0xFFD946EF)},
    {'id': 'health', 'name': 'Salud', 'emoji': '💊', 'color': const Color(0xFF10B981)},
    {'id': 'shopping', 'name': 'Compras', 'emoji': '🛍️', 'color': const Color(0xFFF59E0B)},
    {'id': 'education', 'name': 'Educación', 'emoji': '🎓', 'color': const Color(0xFF8B5CF6)},
    {'id': 'other', 'name': 'Otros', 'emoji': '📦', 'color': const Color(0xFF6B7280)},
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
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, -10))
        ],
      ),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Icon(LucideIcons.sliders, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.get('category_budget_title'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text(loc.get('category_budget_subtitle'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(LucideIcons.xCircle, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 28),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final catId = cat['id'] as String;
                final catName = cat['name'] as String;
                final catEmoji = cat['emoji'] as String;
                final catColor = cat['color'] as Color;
                
                final budget = tempBudgets[catId] ?? 0.0;
                final spent = spentByCategory[catId] ?? 0.0;
                final percentage = budget > 0 ? ((spent / budget) * 100).clamp(0.0, 100.0) : 0.0;
                final isExpanded = _expandedCategoryId == catId;

                final isOverLimit = percentage >= 100.0 && budget > 0;
                final hasBudget = budget > 0;
                
                final bannerColor = isOverLimit 
                    ? (isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2))
                    : (hasBudget ? catColor.withValues(alpha: isDark ? 0.2 : 0.1) : (isDark ? const Color(0xFF1F2937) : Colors.white));
                
                final borderColor = isOverLimit 
                    ? (isDark ? const Color(0xFFDC2626) : const Color(0xFFF87171)) 
                    : (hasBudget ? catColor.withValues(alpha: 0.5) : (isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)));

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _expandedCategoryId = isExpanded ? null : catId;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: bannerColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: borderColor,
                        width: isExpanded || hasBudget ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isExpanded)
                          BoxShadow(color: catColor.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))
                        else
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(child: Text(catEmoji, style: const TextStyle(fontSize: 26))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(catName, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    // Linear Progress Bar
                                    Container(
                                      height: 6,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: catColor,
                                            borderRadius: BorderRadius.circular(3),
                                            boxShadow: [BoxShadow(color: catColor.withValues(alpha: 0.5), blurRadius: 4)],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    budget > 0 ? '$sym${budget.toStringAsFixed(0)}' : 'Ilimitado',
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    budget > 0 ? '${percentage.toStringAsFixed(0)}% usado' : 'Sin límite',
                                    style: TextStyle(
                                      color: budget <= 0 ? (isDark ? Colors.grey[500] : Colors.grey[400]) : (percentage >= 100 
                                          ? const Color(0xFFEF4444) 
                                          : (percentage >= 80 ? const Color(0xFFF59E0B) : (isDark ? Colors.grey[400] : Colors.grey[500]))),
                                      fontSize: 11,
                                      fontWeight: percentage >= 80 ? FontWeight.bold : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Expanded Section (Editor)
                        AnimatedCrossFade(
                          firstChild: const SizedBox(width: double.infinity, height: 0),
                          secondChild: Container(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Fijar límite mensual', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
                                    if (budget > 0)
                                      InkWell(
                                        onTap: () => setState(() => tempBudgets.remove(catId)),
                                        child: const Text('Eliminar Límite', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    // Custom input field
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(sym, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 18, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: budget > 0 ? budget.toStringAsFixed(0) : '',
                                              keyboardType: TextInputType.number,
                                              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Ingresa un límite manual...',
                                                hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 14, fontWeight: FontWeight.normal),
                                              ),
                                              onChanged: (value) {
                                                final val = double.tryParse(value);
                                                if (val != null && val > 0) {
                                                  setState(() => tempBudgets[catId] = val);
                                                } else if (value.isEmpty) {
                                                  setState(() => tempBudgets.remove(catId));
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Presets
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [50.0, 100.0, 300.0, 500.0, 1000.0, 2000.0, 5000.0].map((preset) {
                                          final isSelected = budget == preset;
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: InkWell(
                                              onTap: () {
                                                // FocusScope.of(context).unfocus(); // Optional to hide keyboard when selecting preset
                                                setState(() => tempBudgets[catId] = preset);
                                              },
                                              borderRadius: BorderRadius.circular(16),
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: isSelected ? catColor : (isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9)),
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: isSelected ? catColor : (isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                                                  ),
                                                  boxShadow: isSelected ? [BoxShadow(color: catColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                                                ),
                                                child: Text(
                                                  '$sym${preset.toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                                                    fontSize: 13,
                                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                          sizeCurve: Curves.easeInOutCubic,
                        ),
                      ],
                    ),
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
                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                                child: const Icon(LucideIcons.alertOctagon, color: Colors.red, size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Text('¡Límite Excedido!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          content: Text(
                            'Has agotado el 100% o más de tu presupuesto mensual para la categoría "$breachedCategoryName".\n\n'
                            'Límite fijado: $sym${breachedLimit.toStringAsFixed(0)}\n'
                            'Gasto actual: $sym${breachedSpent.toStringAsFixed(0)}',
                            style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], height: 1.5),
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
                        SnackBar(
                          content: Text(loc.get('budget_saved_snack')), 
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
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
