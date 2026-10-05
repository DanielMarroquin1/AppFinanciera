import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/saving_goals_provider.dart';
import '../../../core/utils/localization.dart';
import 'dart:ui';

class BadgesModal extends ConsumerStatefulWidget {
  const BadgesModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BadgesModal(),
    );
  }

  @override
  ConsumerState<BadgesModal> createState() => _BadgesModalState();
}

class _BadgesModalState extends ConsumerState<BadgesModal> {
  Map<String, dynamic>? _selectedBadge;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox();

    final transactionsAsync = ref.watch(transactionsProvider);
    final goalsAsync = ref.watch(savingGoalsProvider);

    final transactions = transactionsAsync.value ?? [];
    final goals = goalsAsync.value ?? [];

    final int streak = user.currentStreak;
    final int expensesCount = transactions.where((t) => t.type == 'expense').length;
    final int incomesCount = transactions.where((t) => t.type == 'income').length;
    final int allTransactionsCount = transactions.length;
    final double totalSaved = goals.fold(0.0, (sum, g) => sum + g.currentAmount);

    final badges = [
      {
        'id': 'first_expense',
        'title': 'Primer Paso',
        'desc': 'Registra tu primer gasto para tomar control.',
        'icon': LucideIcons.trendingDown,
        'color': const Color(0xFF3B82F6),
        'current': expensesCount,
        'target': 1,
      },
      {
        'id': 'first_income',
        'title': 'Dinero Nuevo',
        'desc': 'Registra tu primer ingreso y empieza a sumar.',
        'icon': LucideIcons.trendingUp,
        'color': const Color(0xFF10B981),
        'current': incomesCount,
        'target': 1,
      },
      {
        'id': 'streak_7',
        'title': 'Constancia',
        'desc': 'Alcanza una racha de 7 días usando la app.',
        'icon': LucideIcons.flame,
        'color': const Color(0xFFF59E0B),
        'current': streak,
        'target': 7,
      },
      {
        'id': 'streak_30',
        'title': 'Hábito Financiero',
        'desc': 'Mantén una racha de 30 días sin fallar.',
        'icon': LucideIcons.zap,
        'color': const Color(0xFFEF4444),
        'current': streak,
        'target': 30,
      },
      {
        'id': 'saved_1000',
        'title': 'Ahorrador Plata',
        'desc': 'Acumula \$1,000 en tus metas de ahorro.',
        'icon': LucideIcons.piggyBank,
        'color': const Color(0xFF94A3B8),
        'current': totalSaved.toInt(),
        'target': 1000,
      },
      {
        'id': 'saved_10000',
        'title': 'Ahorrador Oro',
        'desc': 'Acumula \$10,000 en tus metas de ahorro.',
        'icon': LucideIcons.crown,
        'color': const Color(0xFFEAB308),
        'current': totalSaved.toInt(),
        'target': 10000,
      },
      {
        'id': '100_transactions',
        'title': 'Centurión',
        'desc': 'Registra un total de 100 transacciones.',
        'icon': LucideIcons.activity,
        'color': const Color(0xFF06B6D4),
        'current': allTransactionsCount,
        'target': 100,
      },
      {
        'id': 'premium_user',
        'title': 'Miembro Premium',
        'desc': 'Adquiere la suscripción Finanza Premium.',
        'icon': LucideIcons.star,
        'color': const Color(0xFF8B5CF6),
        'current': user.isPremium ? 1 : 0,
        'target': 1,
      },
      {
        'id': 'first_custom_cat',
        'title': 'Organizador',
        'desc': 'Crea tu primera categoría personalizada.',
        'icon': LucideIcons.shoppingBag,
        'color': const Color(0xFFEC4899),
        'current': user.unlockedItems.isNotEmpty ? 1 : 0,
        'target': 1,
      },
    ];

    int unlockedCount = badges.where((b) => (b['current'] as int) >= (b['target'] as int)).length;
    double progress = unlockedCount / badges.length;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark 
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
              ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Pill
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Header: A beautiful premium card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tus Logros',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Has completado $unlockedCount de ${badges.length} trofeos.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 6,
                            backgroundColor: Colors.black.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        const Icon(
                          LucideIcons.trophy,
                          color: Colors.white,
                          size: 28,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Active Badge Info
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _selectedBadge == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: (_selectedBadge!['color'] as Color).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_selectedBadge!['color'] as Color).withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: (_selectedBadge!['color'] as Color).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                _selectedBadge!['icon'] as IconData,
                                color: _selectedBadge!['color'] as Color,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedBadge!['title'] as String,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      if ((_selectedBadge!['current'] as int) >= (_selectedBadge!['target'] as int))
                                        Icon(Icons.check_circle, color: _selectedBadge!['color'] as Color, size: 20)
                                      else
                                        Icon(LucideIcons.lock, color: isDark ? Colors.grey[600] : Colors.grey[400], size: 18)
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _selectedBadge!['desc'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Progress bar always visible
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: ((_selectedBadge!['current'] as int) / (_selectedBadge!['target'] as int)).clamp(0.0, 1.0),
                                            backgroundColor: isDark ? Colors.black26 : Colors.grey[200],
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              (_selectedBadge!['color'] as Color),
                                            ),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '${_selectedBadge!['current']} / ${_selectedBadge!['target']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Grid of Badges
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  final cCurrent = badge['current'] as int;
                  final cTarget = badge['target'] as int;
                  final isUnlocked = cCurrent >= cTarget;
                  final bColor = badge['color'] as Color;
                  final isSelected = _selectedBadge?['id'] == badge['id'];

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedBadge = isSelected ? null : badge;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      transform: Matrix4.identity()..scale(isSelected ? 0.95 : 1.0),
                      decoration: BoxDecoration(
                        color: isUnlocked 
                            ? bColor.withValues(alpha: isSelected ? 0.2 : 0.1)
                            : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isUnlocked
                              ? bColor.withValues(alpha: isSelected ? 1.0 : 0.3)
                              : (isSelected
                                  ? (isDark ? Colors.white54 : Colors.black45)
                                  : (isDark ? Colors.white12 : Colors.black12)),
                          width: isSelected ? 2 : 1.5,
                        ),
                        boxShadow: (isUnlocked && isSelected)
                            ? [
                                BoxShadow(
                                  color: bColor.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            badge['icon'] as IconData,
                            color: isUnlocked 
                                ? bColor 
                                : (isDark ? Colors.grey[600] : Colors.grey[400]),
                            size: 32,
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              badge['title'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.1,
                                fontWeight: isUnlocked ? FontWeight.w800 : FontWeight.w600,
                                color: isUnlocked
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : (isDark ? Colors.grey[500] : Colors.grey[500]),
                              ),
                            ),
                          ),
                          if (!isUnlocked) ...[
                            const SizedBox(height: 6),
                            Icon(
                              LucideIcons.lock,
                              size: 12,
                              color: isDark ? Colors.grey[700] : Colors.grey[400],
                            )
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
