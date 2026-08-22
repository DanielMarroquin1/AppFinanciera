import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import 'premium_paywall_dialog.dart';
import 'dart:ui';

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
  String? _editingCategoryId;

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

  void _showAddCategorySelector(BuildContext context, List<Map<String, Object>> availableCategories, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Selecciona una Categoría', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                const SizedBox(height: 16),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: availableCategories.length,
                    itemBuilder: (ctx, i) {
                      final acat = availableCategories[i];
                      final catColor = acat['color'] as Color;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(ctx);
                          setState(() {
                            tempBudgets[acat['id'] as String] = 500.0; // Default budget
                            _editingCategoryId = acat['id'] as String;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: catColor.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(acat['emoji'] as String, style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 8),
                              Text(
                                acat['name'] as String,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }
    );
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
        t.type == 'expense' && t.date.year == now.year && t.date.month == now.month);

    final Map<String, double> spentByCategory = {};
    for (var tx in currentMonthExpenses) {
      final mainCat = tx.category.split('_')[0];
      spentByCategory[mainCat] = (spentByCategory[mainCat] ?? 0.0) + tx.amount;
    }

    final activeCategories = categories.where((cat) {
      final id = cat['id'] as String;
      return tempBudgets.containsKey(id) && tempBudgets[id]! > 0;
    }).toList();
    
    final availableCategories = categories.where((cat) {
      final id = cat['id'] as String;
      return !tempBudgets.containsKey(id) || tempBudgets[id]! <= 0;
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.95) : const Color(0xFFF8FAFC).withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[300], borderRadius: BorderRadius.circular(3)),
                ),
                
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Presupuestos', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          Text('${activeCategories.length} activos', style: TextStyle(color: const Color(0xFF8B5CF6), fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 28),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: activeCategories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20)],
                                ),
                                child: Icon(LucideIcons.target, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                              ),
                              const SizedBox(height: 24),
                              Text('Sin límites', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 8),
                              Text('Agrega una categoría para empezar\na controlar tus gastos.', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 14, height: 1.5)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                          physics: const BouncingScrollPhysics(),
                          itemCount: activeCategories.length,
                          itemBuilder: (context, index) {
                            final cat = activeCategories[index];
                            final catId = cat['id'] as String;
                            final catName = cat['name'] as String;
                            final catEmoji = cat['emoji'] as String;
                            final catColor = cat['color'] as Color;
                            
                            final budget = tempBudgets[catId] ?? 0.0;
                            final spent = spentByCategory[catId] ?? 0.0;
                            final percentage = budget > 0 ? ((spent / budget) * 100).clamp(0.0, 100.0) : 0.0;
                            final isOverLimit = percentage >= 100.0 && budget > 0;
                            final isEditing = _editingCategoryId == catId;
                            
                            // Dynamic Slider Max
                            final sliderMax = budget > 5000 ? (budget * 1.5).ceilToDouble() : 5000.0;
                            
                            // Color dynamic based on percentage
                            final dynamicColor = percentage >= 90 ? const Color(0xFFEF4444) : (percentage >= 80 ? const Color(0xFFF59E0B) : catColor);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Dismissible(
                                key: Key(catId),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) {
                                  HapticFeedback.mediumImpact();
                                  setState(() => tempBudgets.remove(catId));
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(32)),
                                  child: const Icon(LucideIcons.trash2, color: Colors.white, size: 28),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _editingCategoryId = isEditing ? null : catId);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutBack,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(color: isEditing ? dynamicColor : (isDark ? Colors.transparent : Colors.grey[100]!), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isOverLimit ? const Color(0xFFEF4444) : (isEditing ? dynamicColor : Colors.black)).withValues(alpha: isEditing ? 0.15 : 0.05),
                                          blurRadius: isEditing ? 20 : 10,
                                          offset: Offset(0, isEditing ? 10 : 4),
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(catEmoji, style: const TextStyle(fontSize: 32)),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(catName, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.w900)),
                                                  const SizedBox(height: 4),
                                                  Text('Gastado: $sym${spent.toStringAsFixed(0)}', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '$sym${budget.toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    color: isOverLimit ? const Color(0xFFEF4444) : (isDark ? Colors.white : Colors.black), 
                                                    fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${percentage.toStringAsFixed(0)}%',
                                                  style: TextStyle(
                                                    color: isOverLimit ? const Color(0xFFEF4444) : (isDark ? Colors.grey[500] : Colors.grey[400]), 
                                                    fontSize: 12, fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (isEditing) ...[
                                              const SizedBox(width: 12),
                                              IconButton(
                                                onPressed: () {
                                                  HapticFeedback.mediumImpact();
                                                  setState(() => tempBudgets.remove(catId));
                                                },
                                                icon: const Icon(LucideIcons.trash2, color: Color(0xFFEF4444)),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              ),
                                            ]
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 20),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: percentage / 100,
                                            backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                            valueColor: AlwaysStoppedAnimation<Color>(dynamicColor),
                                            minHeight: 8,
                                          ),
                                        ),

                                        if (isEditing) ...[
                                          const SizedBox(height: 32),
                                          // Minimalist Text Input
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(sym, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 32, fontWeight: FontWeight.bold)),
                                              const SizedBox(width: 8),
                                              IntrinsicWidth(
                                                child: TextFormField(
                                                  initialValue: budget.toStringAsFixed(0),
                                                  keyboardType: TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1),
                                                  decoration: const InputDecoration(
                                                    border: InputBorder.none,
                                                    isDense: true,
                                                    contentPadding: EdgeInsets.zero,
                                                  ),
                                                  onChanged: (value) {
                                                    final val = double.tryParse(value);
                                                    if (val != null && val > 0) {
                                                      setState(() => tempBudgets[catId] = val);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          
                                          // Dynamic Slider (like budget_limit_modal)
                                          SliderTheme(
                                            data: SliderTheme.of(context).copyWith(
                                              trackHeight: 8,
                                              activeTrackColor: dynamicColor,
                                              inactiveTrackColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                              thumbColor: Colors.white,
                                              overlayColor: dynamicColor.withValues(alpha: 0.2),
                                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14, elevation: 4),
                                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                                            ),
                                            child: Slider(
                                              value: budget.clamp(1.0, sliderMax),
                                              min: 1.0,
                                              max: sliderMax,
                                              onChanged: (value) {
                                                setState(() => tempBudgets[catId] = value);
                                              },
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            
            // FAB & Guardar Button
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Row(
                children: [
                  if (availableCategories.isNotEmpty)
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => _showAddCategorySelector(context, availableCategories, isDark),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: const Icon(LucideIcons.plus, size: 28),
                        ),
                      ),
                    ),
                  if (availableCategories.isNotEmpty) const SizedBox(width: 16),
                  
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () async {
                        HapticFeedback.heavyImpact();
                        if (user != null) {
                          final updated = user.copyWith(categoryBudgets: tempBudgets);
                          await ref.read(authProvider.notifier).updateProfile(updated);
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(loc.get('budget_saved_snack')), 
                              backgroundColor: const Color(0xFF8B5CF6),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: const Center(
                          child: Text(
                            'Guardar',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
