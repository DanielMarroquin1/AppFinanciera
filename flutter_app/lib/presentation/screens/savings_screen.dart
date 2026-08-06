import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/modals/add_saving_goal_modal.dart';
import '../widgets/modals/add_funds_modal.dart';
import '../widgets/modals/saving_guide_modal.dart';
import '../widgets/modals/ai_chat_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/color_palette_provider.dart';
import '../providers/saving_goals_provider.dart';
import '../../core/utils/localization.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/auth_provider.dart';

class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ref.watch(colorPaletteProvider);
    final paletteGradient = ref.read(colorPaletteProvider.notifier).getGradient(isDark);
    final loc = ref.watch(localizationProvider);
    final sym = CurrencyFormatter.getSymbol(ref.watch(authProvider).user?.currency);
    final goalsAsync = ref.watch(savingGoalsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by AppShell
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    loc.get('my_savings'),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.get('savings_subtitle'),
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: goalsAsync.when(
                data: (goalsList) {
                  final totalSaved = goalsList.fold(0.0, (sum, item) => sum + item.currentAmount);
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        colors: paletteGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: paletteGradient[0].withOpacity(0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        )
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(loc.get('total_saved'), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w500)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(LucideIcons.piggyBank, color: Colors.white, size: 14),
                                        const SizedBox(width: 6),
                                        Text('${goalsList.length} Metas', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('$sym${totalSaved.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1)),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(LucideIcons.trendingUp, color: Colors.white, size: 16),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(loc.get('savings_month_progress'), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text(loc.get('error_loading_savings')),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abriendo Asistente de IA...')));
                  AIChatModal.show(
                    context, 
                    initialMessage: 'Analiza mis ingresos y gastos y generame un plan de ahorro funcional paso a paso.'
                  );
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFFEC4899)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(LucideIcons.sparkles, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Plan de Ahorro con IA',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Genera un plan basado en tus datos reales',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(LucideIcons.chevronRight, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loc.get('my_saving_goals'), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () => AddSavingGoalModal.show(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(LucideIcons.plus, color: isDark ? Colors.white : Colors.black, size: 20),
                    ),
                  )
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: goalsAsync.when(
              data: (goalsList) {
                if (goalsList.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(LucideIcons.target, size: 48, color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                            const SizedBox(height: 16),
                            Text(loc.get('no_goals_yet'), style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final goal = goalsList[index];
                      final percentage = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount) * 100 : 0.0;
                      final isComplete = percentage >= 100;
                      
                      final List<Color> goalColors = goal.colorInts != null 
                          ? goal.colorInts!.map((c) => Color(c)).toList()
                          : (isDark ? [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)] : [const Color(0xFF60A5FA), const Color(0xFF2563EB)]);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: isComplete ? const Color(0xFF10B981).withOpacity(0.5) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            width: isComplete ? 2 : 1,
                          ),
                          boxShadow: [
                            if (isComplete) BoxShadow(color: const Color(0xFF10B981).withOpacity(0.1), blurRadius: 24, offset: const Offset(0, 12))
                            else BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48, height: 48,
                                      decoration: BoxDecoration(
                                        color: goalColors[0].withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Center(child: Text(goal.icon, style: const TextStyle(fontSize: 24))),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(goal.name, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text('${percentage.toStringAsFixed(1)}% ${loc.get('completed')}', style: TextStyle(color: goalColors[0], fontSize: 13, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(LucideIcons.moreVertical, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      AddSavingGoalModal.show(
                                        context,
                                        initialName: goal.name,
                                        initialTargetAmount: goal.targetAmount,
                                        initialIcon: goal.icon,
                                        goalToEdit: goal,
                                      );
                                    } else if (value == 'delete') {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (c) => AlertDialog(
                                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                          title: const Text('Eliminar Meta'),
                                          content: Text('¿Estás seguro de que quieres eliminar la meta "${goal.name}"? Esta acción no se puede deshacer.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(c, false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(c, true),
                                              child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await ref.read(savingGoalsProvider.notifier).deleteGoal(goal.id);
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(LucideIcons.edit2, size: 18, color: Colors.blue),
                                          SizedBox(width: 12),
                                          Text('Editar Meta'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                                          SizedBox(width: 12),
                                          Text('Eliminar Meta', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Ahorrado', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text('$sym${goal.currentAmount.toStringAsFixed(0)}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text('de $sym${goal.targetAmount.toStringAsFixed(0)}', style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 12,
                              width: double.infinity,
                              decoration: BoxDecoration(color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (percentage / 100).clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: goalColors),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [BoxShadow(color: goalColors[0].withOpacity(0.4), blurRadius: 8)],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (isComplete)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981)),
                                    SizedBox(width: 8),
                                    Text('¡Meta Alcanzada!', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              )
                            else
                              InkWell(
                                onTap: () => AddFundsModal.show(context, goal: goal),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: goalColors.map((c) => c.withOpacity(0.15)).toList()),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(LucideIcons.plusCircle, color: goalColors[0], size: 20),
                                      const SizedBox(width: 8),
                                      Text(loc.get('add_funds'), style: TextStyle(color: goalColors[0], fontSize: 15, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              )
                          ],
                        ),
                      );
                    },
                    childCount: goalsList.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
              error: (err, stack) => SliverToBoxAdapter(child: Text(loc.get('error_loading_goals'))),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Space for FAB
        ],
      ),
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom > 0
          ? null
          : FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abriendo Chat...')));
                AIChatModal.show(context);
              },
              backgroundColor: Colors.transparent,
              elevation: 10,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFFEC4899)]), 
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA855F7).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: const Icon(LucideIcons.sparkles, color: Colors.white),
            ),
            if (!(ref.watch(authProvider).user?.isPremium ?? false))
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFFD97706), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.crown, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
