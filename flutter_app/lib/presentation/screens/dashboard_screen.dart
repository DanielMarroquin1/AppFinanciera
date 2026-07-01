import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/rewards_shop_modal.dart';
import '../widgets/modals/add_expense_modal.dart';
import '../widgets/modals/add_income_modal.dart';
import '../widgets/modals/streak_modal.dart';
import '../widgets/modals/budget_limit_modal.dart';
import '../widgets/modals/ai_chat_modal.dart';
import '../widgets/modals/transactions_list_modal.dart';
import '../widgets/modals/credit_cards_modal.dart';
import '../widgets/modals/badges_modal.dart';
import '../widgets/modals/edit_profile_modal.dart';
import '../widgets/modals/daily_tip_modal.dart';
import '../widgets/modals/complete_profile_modal.dart';
import '../providers/color_palette_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/localization.dart';
import '../widgets/modals/quick_action_manager_modal.dart';
import '../widgets/modals/monthly_report_modal.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fireAnimController;
  bool _limitAlertShown = false;
  bool _fixedExpenseAlertShown = false;


  @override
  void initState() {
    super.initState();
    _fireAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fireAnimController.dispose();
    super.dispose();
  }

  bool _profileChecked = false;
  bool _tipChecked = false;
  bool _streakChecked = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    ref.listen(authProvider, (previous, next) {
      final prevStreak = previous?.user?.currentStreak ?? 0;
      final nextStreak = next.user?.currentStreak ?? 0;
      if (nextStreak > prevStreak && nextStreak > 0) {
        if (context.mounted) {
          StreakModal.show(context, streak: nextStreak, isActiveToday: true);
        }
      }
    });
    
    final realBadges = <Map<String, dynamic>>[];
    if (user != null) {
      if (user.profileComplete == true) {
        realBadges.add({'id': 'profile-complete', 'icon': LucideIcons.userCheck, 'name': 'Perfil Completo', 'color': const Color(0xFF3B82F6)});
      }
      if ((user.currentStreak ?? 0) >= 7) {
        realBadges.add({'id': 'week-streak', 'icon': LucideIcons.flame, 'name': 'Racha 7 Días', 'color': const Color(0xFFEF4444)});
      }
      if ((user.currentStreak ?? 0) >= 30) {
        realBadges.add({'id': 'month-streak', 'icon': LucideIcons.award, 'name': 'Racha 30 Días', 'color': const Color(0xFFF59E0B)});
      }
      if ((user.unlockedItems.isNotEmpty)) {
        realBadges.add({'id': 'shopper', 'icon': LucideIcons.shoppingBag, 'name': 'Comprador', 'color': const Color(0xFFEC4899)});
      }
      if ((user.unlockedItems.length) >= 5) {
        realBadges.add({'id': 'collector', 'icon': LucideIcons.crown, 'name': 'Coleccionista', 'color': const Color(0xFF8B5CF6)});
      }
      if ((user.points ?? 0) >= 100) {
        realBadges.add({'id': 'saver', 'icon': LucideIcons.piggyBank, 'name': 'Ahorrador', 'color': const Color(0xFF10B981)});
      }
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ref.watch(colorPaletteProvider);
    final paletteGradient = ref.read(colorPaletteProvider.notifier).getGradient(isDark);
    


    final transactionsAsync = ref.watch(transactionsProvider);
    final loc = ref.watch(localizationProvider);
    final currencyCode = user?.currency;

    if (user != null && !user.profileComplete && !_profileChecked) {
      _profileChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          CompleteProfileModal.show(context);
        }
      });
    }

    if (user != null && !_streakChecked && user.profileComplete) {
      _streakChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (context.mounted) {
          await ref.read(authProvider.notifier).checkStreakStatus();
          
          if (context.mounted) {
            final updatedUser = ref.read(authProvider).user;
            if (updatedUser != null && updatedUser.currentStreak > 0) {
              final now = DateTime.now();
              final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
              
              if (updatedUser.lastActiveDate != todayStr) {
                // Warning! They haven't done an action today
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(child: Text('¡Cuidado! Haz una transacción hoy para no perder tu racha de ${updatedUser.currentStreak} días.', style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    backgroundColor: Colors.orange[800],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    duration: const Duration(seconds: 5),
                    margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                  ),
                );
              }
            }
          }
        }
      });
    }

    // Old fixed expense alert removed. Using new Notifications system instead.

    // Show daily tip once per day (after profile modal if needed)
    if (user != null && !_tipChecked) {
      _tipChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (context.mounted) {
          // Small delay so it doesn't clash with the profile modal
          await Future.delayed(const Duration(milliseconds: 600));
          if (context.mounted) {
            DailyTipModal.showIfNeeded(context);
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by AppShell
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${loc.get('welcome_back')} ${user?.name ?? 'Usuario'}! 👋',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.get('on_track'),
                        style: TextStyle(
                          color: isDark ? Colors.orange[400] : Colors.orange[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Streak Badge & Rewards
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        final now = DateTime.now();
                        final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                        final isActiveToday = user?.lastActiveDate == todayStr;
                        StreakModal.show(context, streak: user?.currentStreak ?? 0, isActiveToday: isActiveToday);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedBuilder(
                        animation: _fireAnimController,
                        builder: (context, child) {
                          final now = DateTime.now();
                          final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                          final isActiveToday = user?.lastActiveDate == todayStr;
                          
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isActiveToday
                                ? (isDark 
                                    ? const LinearGradient(colors: [Color(0xFF7C2D12), Color(0xFF7F1D1D)]) 
                                    : const LinearGradient(colors: [Color(0xFFFFF7ED), Color(0xFFFEF2F2)]))
                                : (isDark
                                    ? const LinearGradient(colors: [Color(0xFF374151), Color(0xFF1F2937)])
                                    : const LinearGradient(colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)])),
                            border: Border.all(
                              color: isActiveToday
                                  ? (isDark ? const Color(0xFFC2410C) : const Color(0xFFFDBA74))
                                  : (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isActiveToday ? [
                              BoxShadow(
                                color: const Color(0xFFF97316).withValues(alpha: 0.3 + (_fireAnimController.value * 0.2)),
                                blurRadius: 8 + (_fireAnimController.value * 8),
                                spreadRadius: _fireAnimController.value * 2,
                              ),
                            ] : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: isActiveToday ? 1.0 + (_fireAnimController.value * 0.1) : 1.0,
                                child: Icon(
                                  LucideIcons.flame, 
                                  color: isActiveToday
                                      ? (isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C))
                                      : (isDark ? Colors.grey[500] : Colors.grey[400]),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${user?.currentStreak ?? 0}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isActiveToday
                                      ? (isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C))
                                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                ),
                              )
                            ],
                          ),
                        );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => RewardsShopModal.show(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.amber[900]?.withValues(alpha: 0.3) : Colors.amber[100],
                          border: Border.all(
                            color: Colors.amber,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          LucideIcons.shoppingBag,
                          color: isDark ? Colors.amber[400] : Colors.amber[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Balance Card — computed inside when() to avoid stale locals
            transactionsAsync.when(
              loading: () => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: paletteGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
              error: (err, stack) => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: paletteGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text('Error al cargar balance', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              data: (transactions) {
                double displayTotalIncome = 0;
                double actualTotalIncome = 0;
                double totalExpense = 0;
                
                final now = DateTime.now();
                final currentMonth = now.month;
                final currentYear = now.year;
                
                final monthNames = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
                final currentMonthName = monthNames[now.month - 1];

                for (var t in transactions) {
                  if (t.type == 'income') {
                    if (t.isFixed) {
                      displayTotalIncome += t.amount;
                    } else {
                      actualTotalIncome += t.amount;
                    }
                  } else if (t.type == 'expense' && t.creditCardId == null) {
                    // Handled in second loop
                  }
                }
                double allTimeExpense = 0;
                for (var t in transactions) {
                  if (t.isFixed) continue;
                  if (t.type == 'expense' && t.creditCardId == null) {
                    allTimeExpense += t.amount;
                    if (t.date.month == currentMonth && t.date.year == currentYear) {
                      totalExpense += t.amount;
                    }
                  } else if (t.type == 'cc_payment') {
                    allTimeExpense += t.amount;
                    if (t.date.month == currentMonth && t.date.year == currentYear) {
                      totalExpense += t.amount;
                    }
                  }
                }
                
                final totalBalance = actualTotalIncome - allTimeExpense;

                return InkWell(
                  onTap: () {
                    MonthlyReportModal.show(context);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: paletteGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${loc.get('total_balance')} - $currentMonthName', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(CurrencyFormatter.format(totalBalance, currencyCode), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(loc.get('income'), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(CurrencyFormatter.format(displayTotalIncome, currencyCode), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(loc.get('expenses'), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(CurrencyFormatter.format(totalExpense, currencyCode), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ));
              },
            ),
            const SizedBox(height: 24),

            // Limit Banner
            transactionsAsync.whenData((transactions) {
              final double limitPercentage = user?.monthlyLimit ?? 80.0;
              double totalExpense = 0;
              double totalIncome = 0;
              for (var t in transactions) {
                if (t.isFixed) continue; // Ignorar plantillas
                if (t.type == 'expense') totalExpense += t.amount;
                if (t.type == 'income') totalIncome += t.amount;
              }
              
              final double calculatedLimit = (totalIncome * limitPercentage) / 100.0;
              final isOverLimit = totalIncome > 0 && totalExpense >= calculatedLimit;
              
              if (isOverLimit && !_limitAlertShown) {
                _limitAlertShown = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.alertTriangle, color: Colors.red),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Text('¡Límite Alcanzado!', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Has superado el ${limitPercentage.toInt()}% de límite mensual de tus ingresos.',
                              style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Presupuesto:', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                      Text(CurrencyFormatter.format(calculatedLimit, currencyCode), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Gastado:', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                      Text(CurrencyFormatter.format(totalExpense, currencyCode), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        actions: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                });
              }

              final bannerColor = isOverLimit ? (isDark ? const Color(0xFF991B1B) : const Color(0xFFFEE2E2)) : (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE));
              final borderColor = isOverLimit ? (isDark ? const Color(0xFFDC2626) : const Color(0xFFF87171)) : (isDark ? const Color(0xFF2563EB) : const Color(0xFF60A5FA));
              final iconColor = isOverLimit ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626)) : (isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB));
              final textColor = isOverLimit ? (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C)) : (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A));

              return InkWell(
                onTap: () async {
                  final newValue = await BudgetLimitModal.show(context, initialValue: limitPercentage);
                  if (newValue != null) {
                    ref.read(authProvider.notifier).updateMonthlyLimit(newValue);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bannerColor,
                    border: Border.all(color: borderColor, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(isOverLimit ? LucideIcons.alertTriangle : LucideIcons.target, color: iconColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isOverLimit 
                            ? '¡Cuidado! Has alcanzado el ${limitPercentage.toInt()}% de tu límite.'
                            : 'Límite Mensual: ${limitPercentage.toInt()}% de ingresos',
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.pencil, size: 16, color: iconColor),
                    ],
                  ),
                ),
              );
            }).value ?? const SizedBox(),
            const SizedBox(height: 24),

            // Quick Actions inline
            Text(loc.get('quick_actions'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => context.push('/incomes'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF14532D).withValues(alpha: 0.3) : const Color(0xFFF0FDF4),
                          border: Border.all(color: isDark ? const Color(0xFF166534) : const Color(0xFFBBF7D0), width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(LucideIcons.trendingUp, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), size: 22),
                            const SizedBox(height: 6),
                            Text('Ingresos', style: TextStyle(color: isDark ? const Color(0xFFBBF7D0) : const Color(0xFF14532D), fontSize: 10, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: InkWell(
                      onTap: () => AddExpenseModal.show(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.3) : const Color(0xFFFEF2F2),
                          border: Border.all(color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA), width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(LucideIcons.trendingDown, color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626), size: 22),
                            const SizedBox(height: 6),
                            Text('Gastos', style: TextStyle(color: isDark ? const Color(0xFFFECACA) : const Color(0xFF7F1D1D), fontSize: 10, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: InkWell(
                      onTap: () => context.go('/debts'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3A5F).withValues(alpha: 0.3) : const Color(0xFFEFF6FF),
                          border: Border.all(color: isDark ? const Color(0xFF1D4ED8) : const Color(0xFFBFDBFE), width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(LucideIcons.wallet, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 22),
                            const SizedBox(height: 6),
                            Text('Deudas', style: TextStyle(color: isDark ? const Color(0xFFBFDBFE) : const Color(0xFF1E3A8A), fontSize: 10, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: InkWell(
                      onTap: () => CreditCardsModal.show(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF92400E).withValues(alpha: 0.3) : const Color(0xFFFFFBEB),
                          border: Border.all(color: isDark ? const Color(0xFFD97706) : const Color(0xFFFDE68A), width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(LucideIcons.creditCard, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706), size: 22),
                            const SizedBox(height: 6),
                            Text('Tarjetas', style: TextStyle(color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E), fontSize: 10, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Badges Section (Insignias Desbloqueadas)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.get('unlocked_badges'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                TextButton(
                  onPressed: () => BadgesModal.show(context),
                  child: Text(loc.get('see_all'), style: TextStyle(color: paletteGradient[0], fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: realBadges.isEmpty 
              ? Center(
                  child: Text('Aún no tienes insignias desbloqueadas', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 14)),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: realBadges.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final badge = realBadges[index];
                    final Color baseColor = badge['color'];
                    return Container(
                      width: 90,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: Border.all(color: baseColor.withOpacity(0.5), width: 2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: baseColor.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: baseColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(badge['icon'], color: baseColor, size: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            badge['name']!,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ),
            const SizedBox(height: 24),

            // Investment Assistant
            InkWell(
              onTap: () => AIChatModal.show(context),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: paletteGradient,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: Stack(
                  children: [
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B), // amber-500
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.crown, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.trendingUp, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.get('ai_assistant'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                            SizedBox(height: 4),
                            Text('Descubre cómo invertir tu dinero basado en tu negocio 💰', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

            // Recent Transactions (simulated)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.get('recent_transactions'), style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                TextButton(
                  onPressed: () => TransactionsListModal.show(context),
                  child: Text(loc.get('see_all'), style: TextStyle(color: paletteGradient[0], fontSize: 12)),
                )
              ],
            ),
            transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text('No hay transacciones aún', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400])),
                    ),
                  );
                }
                final sorted = transactions.where((t) => !t.isFixed).toList()..sort((a, b) => b.date.compareTo(a.date));
                final recent = sorted.take(3).toList();
                return Column(
                  children: recent.map((t) {
                    final isIncome = t.type == 'income';
                    final emoji = _getCategoryEmoji(t.category);
                    final formattedDate = DateFormat('dd MMM, yyyy').format(t.date);
                    
                    String paymentMethod = t.creditCardId != null ? 'Tarjeta de Crédito' : (t.type == 'cc_payment' ? 'Pago a Tarjeta' : 'Efectivo / Débito');
                    String paymentIcon = t.creditCardId != null ? '💳' : (t.type == 'cc_payment' ? '🏦' : '💵');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTransactionItem(
                        isDark,
                        icon: emoji,
                        bgColor: isIncome
                            ? (isDark ? const Color(0xFF14532D).withValues(alpha: 0.3) : const Color(0xFFF0FDF4))
                            : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.3) : const Color(0xFFFEF2F2)),
                        title: t.description.isNotEmpty ? t.description : t.category,
                        subtitle: '$formattedDate • $paymentIcon $paymentMethod',
                        amount: '${isIncome ? '+' : '-'}${CurrencyFormatter.format(t.amount, currencyCode)}',
                        amountColor: isIncome
                            ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
                            : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error al cargar transacciones'),
            ),
            const SizedBox(height: 24),

            // Achievements Card (¡Logro Desbloqueado!)
            InkWell(
              onTap: () => BadgesModal.show(context),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [paletteGradient[0], paletteGradient.length > 1 ? paletteGradient[1] : paletteGradient[0]],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(LucideIcons.medal, color: Colors.white, size: 24),
                            SizedBox(width: 12),
                            Text('¡Logro Desbloqueado!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text('Ver todas →', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        final List<IconData> unlockedBadges = [
                          if (user?.profileComplete == true) LucideIcons.userCheck,
                          if ((user?.currentStreak ?? 0) >= 7) LucideIcons.flame,
                          if ((user?.currentStreak ?? 0) >= 30) LucideIcons.award,
                          if ((user?.unlockedItems.isNotEmpty ?? false)) LucideIcons.shoppingBag,
                          if ((user?.unlockedItems.length ?? 0) >= 5) LucideIcons.crown,
                          if ((user?.points ?? 0) >= 100) LucideIcons.piggyBank,
                        ];

                        if (unlockedBadges.isEmpty) {
                          return Text(
                            'Aún no tienes insignias. ¡Cumple metas para desbloquearlas!',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Has desbloqueado ${unlockedBadges.length} insignia${unlockedBadges.length == 1 ? '' : 's'}:',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: unlockedBadges.map((icon) => Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: Colors.white, size: 24),
                              )).toList(),
                            ),
                          ],
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80), // for bottom nav padding
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(bool isDark, {required String icon, required Color bgColor, required String title, required String subtitle, required String amount, required Color amountColor}) {
    return Container(
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
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getCategoryEmoji(String category) {
    const map = {
      'food': '🍔', 'transport': '🚗', 'shopping': '🛍️', 'bills': '📱',
      'entertainment': '🎮', 'health': '💊', 'education': '📚', 'home': '🏠',
      'salary': '💼', 'freelance': '💻', 'bonus': '🎁', 'investment': '📈',
      'sale': '🏷️', 'gift': '🎉', 'other': '💸',
    };
    // If the category itself is an emoji, return it directly
    if (category.runes.isNotEmpty && category.runes.first > 127) return category;
    return map[category] ?? '💰';
  }
}
