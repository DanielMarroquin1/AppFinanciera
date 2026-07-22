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
import '../providers/credit_card_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/localization.dart';
import '../widgets/modals/quick_action_manager_modal.dart';
import '../widgets/modals/monthly_report_modal.dart';
import '../widgets/modals/premium_modal.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../providers/notification_provider.dart';
import '../widgets/modals/notifications_modal.dart';
import '../widgets/modals/app_tutorial_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/ai_insights_provider.dart';
import '../widgets/common/micro_insights_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fireAnimController;
  bool _limitAlertShown = false;
  bool _fixedExpenseAlertShown = false;
  bool _insightsLoaded = false;

  @override
  void initState() {
    super.initState();
    _fireAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    // Cargar insights de forma diferida para no bloquear el primer render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_insightsLoaded && mounted) {
        _insightsLoaded = true;
        ref.read(aiInsightsProvider.notifier).loadInsightsAndForecast();
      }
    });
  }

  @override
  void dispose() {
    _fireAnimController.dispose();
    super.dispose();
  }

  bool _profileChecked = false;
  bool _tipChecked = false;
  bool _streakChecked = false;
  bool _tutorialChecked = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    ref.listen(authProvider, (previous, next) {
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final wasActiveToday = previous?.user?.lastActiveDate == todayStr;
      final isActiveToday = next.user?.lastActiveDate == todayStr;
      
      final prevStreak = previous?.user?.currentStreak ?? 0;
      final nextStreak = next.user?.currentStreak ?? 0;

      if (previous?.user != null && !wasActiveToday && isActiveToday) {
        if (context.mounted) {
          StreakModal.show(context, streak: nextStreak > 0 ? nextStreak : 1, isActiveToday: true);
        }
      }
    });
    
    final loc = ref.watch(localizationProvider);
    
    final realBadges = <Map<String, dynamic>>[];
    if (user != null) {
      if (user.profileComplete == true) {
        realBadges.add({'id': 'profile-complete', 'icon': LucideIcons.userCheck, 'name': loc.get('badge_pioneer'), 'color': const Color(0xFF3B82F6)});
      }
      if ((user.currentStreak ?? 0) >= 7) {
        realBadges.add({'id': 'week-streak', 'icon': LucideIcons.flame, 'name': loc.get('badge_constant_fire'), 'color': const Color(0xFFEF4444)});
      }
      if ((user.currentStreak ?? 0) >= 30) {
        realBadges.add({'id': 'month-streak', 'icon': LucideIcons.award, 'name': loc.get('badge_habit_master'), 'color': const Color(0xFFF59E0B)});
      }
      if ((user.unlockedItems.isNotEmpty)) {
        realBadges.add({'id': 'shopper', 'icon': LucideIcons.shoppingBag, 'name': loc.get('badge_vip_shopper'), 'color': const Color(0xFFEC4899)});
      }
      if ((user.unlockedItems.length) >= 5) {
        realBadges.add({'id': 'collector', 'icon': LucideIcons.crown, 'name': loc.get('badge_supreme_collector'), 'color': const Color(0xFF8B5CF6)});
      }
      if ((user.points ?? 0) >= 100) {
        realBadges.add({'id': 'saver', 'icon': LucideIcons.piggyBank, 'name': loc.get('badge_financial_mind'), 'color': const Color(0xFF10B981)});
      }
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ref.watch(colorPaletteProvider);
    final paletteGradient = ref.read(colorPaletteProvider.notifier).getGradient(isDark);
    


    final transactionsAsync = ref.watch(transactionsProvider);
    final currencyCode = user?.currency;
    final unreadNotificationsCount = ref.watch(unreadNotificationsCountProvider);
    final creditCardsAsync = ref.watch(computedCreditCardsProvider);
    final hasOverlimitCard = creditCardsAsync.value?.any((card) => card.currentBalance >= card.limit && card.limit > 0) ?? false;

    if (user != null && !user.profileComplete && !_profileChecked) {
      _profileChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          CompleteProfileModal.show(context);
        }
      });
    }

    if (user != null && !_tutorialChecked) {
      _tutorialChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final prefs = await SharedPreferences.getInstance();
        final hasSeen = prefs.getBool('has_seen_app_tutorial') ?? false;
        if (!hasSeen && !user.hasCompletedTour && context.mounted) {
          AppTutorialModal.show(context);
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

    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final isActiveToday = user?.lastActiveDate == todayStr;
    final currentStreak = user?.currentStreak ?? 0;
    bool isFrozenGrace = false;
    if (user?.lastActiveDate != null) {
      final lastDate = DateTime.tryParse(user!.lastActiveDate!);
      if (lastDate != null) {
        final dOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final tOnly = DateTime(now.year, now.month, now.day);
        final hasFreeze = user.unlockedItems.contains('spec2') || user.unlockedItems.contains('streak_freeze');
        isFrozenGrace = tOnly.difference(dOnly).inDays == 2 && currentStreak > 0 && hasFreeze;
      }
    }
    final isStreakActive = currentStreak >= 2 || isFrozenGrace;

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
                      if (isStreakActive) ...[
                        const SizedBox(height: 4),
                        Text(
                          loc.get('on_track'),
                          style: TextStyle(
                            color: isDark ? Colors.orange[400] : Colors.orange[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Streak Badge & Rewards
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isStreakActive) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            InkWell(
                              onTap: () {
                                StreakModal.show(
                                  context,
                                  streak: currentStreak,
                                  isActiveToday: isActiveToday,
                                  isFrozen: isFrozenGrace,
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedBuilder(
                                animation: _fireAnimController,
                                builder: (context, child) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: isFrozenGrace
                                          ? (isDark
                                              ? const LinearGradient(colors: [Color(0xFF0C4A6E), Color(0xFF075985)])
                                              : const LinearGradient(colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)]))
                                          : isActiveToday
                                              ? (isDark
                                                  ? const LinearGradient(colors: [Color(0xFF7C2D12), Color(0xFF7F1D1D)])
                                                  : const LinearGradient(colors: [Color(0xFFFFF7ED), Color(0xFFFEF2F2)]))
                                              : (isDark
                                                  ? const LinearGradient(colors: [Color(0xFF374151), Color(0xFF1F2937)])
                                                  : const LinearGradient(colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)])),
                                      border: Border.all(
                                        color: isFrozenGrace
                                            ? const Color(0xFF0EA5E9)
                                            : isActiveToday
                                                ? (isDark ? const Color(0xFFC2410C) : const Color(0xFFFDBA74))
                                                : (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: isActiveToday
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFFF97316).withValues(alpha: 0.3 + (_fireAnimController.value * 0.2)),
                                                blurRadius: 8 + (_fireAnimController.value * 8),
                                                spreadRadius: _fireAnimController.value * 2,
                                              ),
                                            ]
                                          : isFrozenGrace
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.35),
                                                    blurRadius: 10,
                                                  ),
                                                ]
                                              : [],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Transform.scale(
                                          scale: isActiveToday ? 1.0 + (_fireAnimController.value * 0.1) : 1.0,
                                          child: Icon(
                                            isFrozenGrace ? LucideIcons.snowflake : LucideIcons.flame,
                                            color: isFrozenGrace
                                                ? const Color(0xFF0EA5E9)
                                                : isActiveToday
                                                    ? (isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C))
                                                    : (isDark ? Colors.grey[500] : Colors.grey[400]),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$currentStreak',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isFrozenGrace
                                                ? const Color(0xFF0EA5E9)
                                                : isActiveToday
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
                          ],
                        ),
                    ],
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        InkWell(
                          onTap: () => NotificationsModal.show(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: unreadNotificationsCount > 0
                                  ? (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.4) : const Color(0xFFFEF2F2))
                                  : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                              border: Border.all(
                                color: unreadNotificationsCount > 0
                                    ? const Color(0xFFEF4444)
                                    : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: unreadNotificationsCount > 0
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              LucideIcons.bell,
                              color: unreadNotificationsCount > 0
                                  ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
                                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                          ),
                        ),
                        if (unreadNotificationsCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                              child: Text(
                                unreadNotificationsCount > 9 ? '9+' : '$unreadNotificationsCount',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Builder(
              builder: (context) {
                final now = DateTime.now();
                final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                final isActiveToday = user?.lastActiveDate == todayStr;
                final currentStreak = user?.currentStreak ?? 0;

                bool isFrozenGrace = false;
                if (user?.lastActiveDate != null) {
                  final lastDate = DateTime.tryParse(user!.lastActiveDate!);
                  if (lastDate != null) {
                    final dOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
                    final tOnly = DateTime(now.year, now.month, now.day);
                    final hasFreeze = user!.unlockedItems.contains('spec2') || user!.unlockedItems.contains('streak_freeze');
                    isFrozenGrace = tOnly.difference(dOnly).inDays == 2 && currentStreak > 0 && hasFreeze;
                  }
                }

                if (!isActiveToday && (currentStreak >= 2 || isFrozenGrace)) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 20),
                    child: _buildFloatingStreakPrompt(
                      context,
                      isDark,
                      currentStreak,
                      loc,
                      isFrozen: isFrozenGrace,
                    ),
                  );
                }
                return const SizedBox(height: 24);
              },
            ),

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
                  final isPremium = ref.read(authProvider).user?.isPremium ?? false;
                  if (!isPremium) {
                    PremiumModal.show(context);
                    return;
                  }
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
                      if (!(ref.watch(authProvider).user?.isPremium ?? false))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFD97706), borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.lock, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      else
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
                          border: Border.all(color: isDark ? const Color(0xFF166534) : const Color(0xFFBBF7D0), width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.transparent : const Color(0xFF16A34A).withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(LucideIcons.trendingUp, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), size: 22),
                            const SizedBox(height: 6),
                            Text(loc.get('dashboard_income'), style: TextStyle(color: isDark ? const Color(0xFFBBF7D0) : const Color(0xFF14532D), fontSize: 10, fontWeight: FontWeight.w600)),
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
                          border: Border.all(color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA), width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.transparent : const Color(0xFFDC2626).withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(LucideIcons.trendingDown, color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626), size: 22),
                            const SizedBox(height: 6),
                            Text(loc.get('dashboard_expenses'), style: TextStyle(color: isDark ? const Color(0xFFFECACA) : const Color(0xFF7F1D1D), fontSize: 10, fontWeight: FontWeight.w600)),
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
                          border: Border.all(color: isDark ? const Color(0xFF1D4ED8) : const Color(0xFFBFDBFE), width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.transparent : const Color(0xFF2563EB).withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(LucideIcons.wallet, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 22),
                            const SizedBox(height: 6),
                            Text(loc.get('dashboard_debts'), style: TextStyle(color: isDark ? const Color(0xFFBFDBFE) : const Color(0xFF1E3A8A), fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: InkWell(
                            onTap: () => CreditCardsModal.show(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF92400E).withValues(alpha: 0.3) : const Color(0xFFFFFBEB),
                                border: Border.all(color: isDark ? const Color(0xFFD97706) : const Color(0xFFFDE68A), width: 1.5),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark ? Colors.transparent : const Color(0xFFD97706).withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(LucideIcons.creditCard, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706), size: 22),
                                  const SizedBox(height: 6),
                                  Text(loc.get('dashboard_cards'), style: TextStyle(color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E), fontSize: 10, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (hasOverlimitCard)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.alertTriangle, color: Colors.white, size: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // ── Micro-Insights de Zent AI ────────────────────────────────────
            const MicroInsightsSection(),
            Builder(
              builder: (context) {
                final insights = ref.watch(microInsightsProvider);
                return insights.isNotEmpty
                    ? const SizedBox(height: 20)
                    : const SizedBox.shrink();
              },
            ),

            // ── Proyección de Fin de Mes ─────────────────────────────────────
            Builder(
              builder: (context) {
                final forecast = ref.watch(cashFlowForecastProvider);
                if (forecast == null) return const SizedBox.shrink();
                final sym = CurrencyFormatter.getSymbol(user?.currency);
                return Column(
                  children: [
                    CashFlowForecastCard(currencySymbol: sym),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),

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
                            const SizedBox(height: 4),
                            Text(loc.get('ai_assistant_subtitle'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

            // "What If?" AI Simulator Card
            InkWell(
              onTap: () {
                final isPremium = ref.read(authProvider).user?.isPremium ?? false;
                if (!isPremium) {
                  PremiumModal.show(context);
                  return;
                }
                context.push('/what-if');
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? const [Color(0xFF1E1B4B), Color(0xFF312E81)]
                        : const [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(LucideIcons.cpu, color: Color(0xFF6366F1), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.get('what_if_title'),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.get('what_if_subtitle'),
                            style: TextStyle(
                              color: isDark ? Colors.grey[300] : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!(ref.watch(authProvider).user?.isPremium ?? false))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFD97706), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.crown, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text('PRO', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    else
                      Icon(
                        LucideIcons.chevronRight,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                      child: Text(loc.get('tx_empty_recent'), style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400])),
                    ),
                  );
                }
                final sorted = transactions.where((t) => !t.isFixed).toList()..sort((a, b) => b.date.compareTo(a.date));
                final recent = sorted.take(3).toList();
                return Column(
                  children: recent.map((t) {
                    final isIncome = t.type == 'income';
                    final emoji = loc.getCategoryEmoji(t.category);
                    final formattedDate = DateFormat('dd MMM, yyyy').format(t.date);
                    
                    String paymentMethod = t.creditCardId != null ? loc.get('tx_payment_cc') : (t.type == 'cc_payment' ? loc.get('tx_payment_pay') : loc.get('tx_payment_cash'));
                    String paymentIcon = t.creditCardId != null ? '💳' : (t.type == 'cc_payment' ? '🏦' : '💵');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTransactionItem(
                        isDark,
                        icon: emoji,
                        bgColor: isIncome
                            ? (isDark ? const Color(0xFF14532D).withValues(alpha: 0.3) : const Color(0xFFF0FDF4))
                            : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.3) : const Color(0xFFFEF2F2)),
                        title: t.description.isNotEmpty ? t.description : loc.translateCategory(t.category),
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
              error: (_, __) => Text(loc.get('tx_load_err')),
            ),
            const SizedBox(height: 24),

            // Rewards Shop Card (Tienda de Recompensas)
            InkWell(
              onTap: () => RewardsShopModal.show(context),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(colors: [Color(0xFF9A3412), Color(0xFF7C2D12)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEA580C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.shoppingBag, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.get('quick_actions_rewards_shop'),
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      loc.get('rewards_shop_subtitle'),
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.coins, color: Color(0xFFFBBF24), size: 16),
                              const SizedBox(width: 4),
                              Text('${user?.points ?? 0} pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loc.get('rewards_shop_desc'),
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildShopPreviewChip('🦸', loc.get('rewards_shop_avatars')),
                                const SizedBox(width: 8),
                                _buildShopPreviewChip('🎨', loc.get('rewards_shop_themes')),
                                const SizedBox(width: 8),
                                _buildShopPreviewChip('💡', loc.get('rewards_shop_tips')),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                loc.get('rewards_shop_enter'),
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(LucideIcons.arrowRight, color: Colors.white, size: 16),
                          ],
                        ),
                      ],
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

  Widget _buildShopPreviewChip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFloatingStreakPrompt(BuildContext context, bool isDark, int currentStreak, AppLocalizations loc, {bool isFrozen = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isFrozen
            ? (isDark
                ? LinearGradient(colors: [const Color(0xFF0C4A6E).withValues(alpha: 0.4), const Color(0xFF075985).withValues(alpha: 0.3)])
                : const LinearGradient(colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)]))
            : (isDark
                ? LinearGradient(colors: [const Color(0xFF7C2D12).withValues(alpha: 0.4), const Color(0xFF451A03).withValues(alpha: 0.3)])
                : const LinearGradient(colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)])),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFrozen
              ? const Color(0xFF0EA5E9)
              : (isDark ? const Color(0xFFEA580C) : const Color(0xFFF97316)),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFrozen ? const Color(0xFF0EA5E9) : const Color(0xFFF97316)).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _fireAnimController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_fireAnimController.value * 0.15),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isFrozen ? const Color(0xFF0EA5E9) : const Color(0xFFF97316),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isFrozen ? const Color(0xFF0EA5E9) : const Color(0xFFF97316)).withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: _fireAnimController.value * 4,
                      )
                    ],
                  ),
                  child: Icon(isFrozen ? LucideIcons.snowflake : LucideIcons.flame, color: Colors.white, size: 24),
                ),
              );
            },
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
                        isFrozen ? loc.get('streak_prompt_frozen_title') : loc.get('streak_prompt_risk_title'),
                        style: TextStyle(
                          color: isFrozen
                              ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7))
                              : (isDark ? const Color(0xFFFB923C) : const Color(0xFFC2410C)),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isFrozen
                      ? loc.get('streak_prompt_frozen_desc')
                      : loc.get('streak_prompt_risk_desc'),
                  style: TextStyle(
                    color: isDark ? Colors.grey[200] : Colors.grey[800],
                    fontSize: 12.5,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => AddExpenseModal.show(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isFrozen
                    ? const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF0284C7)])
                    : const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEA580C)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: (isFrozen ? const Color(0xFF0284C7) : const Color(0xFFF97316)).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Activar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  SizedBox(width: 4),
                  Icon(LucideIcons.arrowRight, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
