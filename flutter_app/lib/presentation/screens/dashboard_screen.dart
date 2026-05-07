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
import '../widgets/modals/edit_profile_modal.dart';
import '../widgets/modals/daily_tip_modal.dart';
import '../providers/color_palette_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  int _budgetLimitPercentage = 80;
  late AnimationController _fireAnimController;

  // Mock badge data
  final List<Map<String, String>> unlockedBadges = [
    {'id': 'first-save', 'emoji': '🎯', 'name': 'Primer Ahorro'},
    {'id': 'week-streak', 'emoji': '🔥', 'name': 'Racha Semanal'},
    {'id': 'budget-control', 'emoji': '✅', 'name': 'Bajo Control'},
    {'id': 'profile-complete', 'emoji': '👤', 'name': 'Perfil Completo'},
  ];

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ref.watch(colorPaletteProvider);
    final paletteGradient = ref.read(colorPaletteProvider.notifier).getGradient(isDark);
    
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final transactionsAsync = ref.watch(transactionsProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    if (user != null && !user.profileComplete && !_profileChecked) {
      _profileChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          EditProfileModal.show(context);
        }
      });
    }

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
                        '¡Hola, ${user?.name ?? 'Usuario'}! 👋',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¡Increíble! Estás en racha 🔥',
                        style: TextStyle(
                          color: isDark ? Colors.orange[400] : Colors.orange[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Aquí está tu resumen financiero',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
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
                      onTap: () => StreakModal.show(context, streak: 5),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedBuilder(
                        animation: _fireAnimController,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isDark 
                                ? const LinearGradient(colors: [Color(0xFF7C2D12), Color(0xFF7F1D1D)]) 
                                : const LinearGradient(colors: [Color(0xFFFFF7ED), Color(0xFFFEF2F2)]),
                            border: Border.all(
                              color: isDark ? const Color(0xFFC2410C) : const Color(0xFFFDBA74),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF97316).withValues(alpha: 0.3 + (_fireAnimController.value * 0.2)),
                                blurRadius: 8 + (_fireAnimController.value * 8),
                                spreadRadius: _fireAnimController.value * 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: 1.0 + (_fireAnimController.value * 0.1),
                                child: Icon(
                                  LucideIcons.flame, 
                                  color: isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '5',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C),
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
                      onTap: () => RewardsShopModal.show(context, points: 150),
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
                double totalIncome = 0;
                double totalExpense = 0;
                for (var t in transactions) {
                  if (t.type == 'income') {
                    totalIncome += t.amount;
                  } else if (t.type == 'expense') {
                    totalExpense += t.amount;
                  }
                }
                final totalBalance = totalIncome - totalExpense;

                return Container(
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
                      Text('Balance Total', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(currencyFormatter.format(totalBalance), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
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
                                  Text('Ingresos', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(currencyFormatter.format(totalIncome), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
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
                                  Text('Gastos', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(currencyFormatter.format(totalExpense), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Alert Banner
            InkWell(
              onTap: () async {
                final newValue = await BudgetLimitModal.show(context, initialValue: _budgetLimitPercentage);
                if (newValue != null) {
                  setState(() {
                    _budgetLimitPercentage = newValue;
                  });
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFFFBEB),
                  border: Border.all(
                    color: isDark ? const Color(0xFF92400E) : const Color(0xFFFDE68A),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertCircle, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: '¡Cuidado! ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: 'Has alcanzado el $_budgetLimitPercentage% del límite mensual.'),
                          ],
                        ),
                        style: const TextStyle(color: Color(0xFF92400E)), // Matches amber-900
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(LucideIcons.pencil, size: 16, color: isDark ? const Color(0xFF92400E) : const Color(0xFFD97706)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Badges Section (Insignias Desbloqueadas)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Insignias Desbloqueadas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                TextButton(
                  onPressed: () => RewardsShopModal.show(context, points: 150),
                  child: Text('Ver todas', style: TextStyle(color: paletteGradient[0], fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: unlockedBadges.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final badge = unlockedBadges[index];
                  return Container(
                    width: 88,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF78350F).withValues(alpha: 0.3), const Color(0xFF7C2D12).withValues(alpha: 0.3)]
                            : [const Color(0xFFFFFBEB), const Color(0xFFFFF7ED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: isDark ? const Color(0xFF92400E) : const Color(0xFFFCD34D),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.5) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(child: Text(badge['emoji']!, style: const TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          badge['name']!,
                          style: TextStyle(
                            color: isDark ? const Color(0xFFFCD34D) : const Color(0xFF78350F),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions inline
            Text('Acciones Rápidas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => AddIncomeModal.show(context),
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
                          Text('Ingreso', style: TextStyle(color: isDark ? const Color(0xFFBBF7D0) : const Color(0xFF14532D), fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                          Text('Gasto', style: TextStyle(color: isDark ? const Color(0xFFFECACA) : const Color(0xFF7F1D1D), fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => AddIncomeModal.show(context, isFixed: true),
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
                          Icon(LucideIcons.repeat, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB), size: 22),
                          const SizedBox(height: 6),
                          Text('Ingreso Fijo', style: TextStyle(color: isDark ? const Color(0xFFBFDBFE) : const Color(0xFF1E3A8A), fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Asistente de Inversión', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
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
                Text('Transacciones Recientes', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                TextButton(
                  onPressed: () => TransactionsListModal.show(context),
                  child: Text('Ver todas', style: TextStyle(color: paletteGradient[0], fontSize: 12)),
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
                final sorted = List.of(transactions)..sort((a, b) => b.date.compareTo(a.date));
                final recent = sorted.take(3).toList();
                return Column(
                  children: recent.map((t) {
                    final isIncome = t.type == 'income';
                    final emoji = _getCategoryEmoji(t.category);
                    final formattedDate = DateFormat('dd MMM, yyyy').format(t.date);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTransactionItem(
                        isDark,
                        icon: emoji,
                        bgColor: isIncome
                            ? (isDark ? const Color(0xFF14532D).withValues(alpha: 0.3) : const Color(0xFFF0FDF4))
                            : (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.3) : const Color(0xFFFEF2F2)),
                        title: t.description.isNotEmpty ? t.description : t.category,
                        subtitle: formattedDate,
                        amount: '${isIncome ? '+' : '-'}${currencyFormatter.format(t.amount)}',
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
              onTap: () => RewardsShopModal.show(context, points: 150),
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
                            Icon(LucideIcons.gift, color: Colors.white, size: 24),
                            SizedBox(width: 12),
                            Text('¡Logro Desbloqueado!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text('Ver todos →', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Has ahorrado por 7 días consecutivos. ¡Sigue así! 🎉',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.75,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '75% para el próximo nivel',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
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
