import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/color_palette_provider.dart';
import '../providers/debts_provider.dart';
import '../../domain/entities/debt.dart';
import '../../domain/entities/transaction.dart';
import '../providers/transaction_provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/localization.dart';
import '../widgets/modals/add_debt_modal.dart';
import '../widgets/modals/monthly_report_modal.dart';
import '../providers/auth_provider.dart';
import '../../core/utils/currency_formatter.dart';

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});

  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> {
  bool _showCompleted = false;

  double _getDebtTotalAmount(DebtModel d) => d.installmentAmount * d.totalInstallments;
  double _getDebtPaidAmount(DebtModel d) => d.installmentAmount * d.paidInstallments;
  double _getDebtRemainingAmount(DebtModel d) => d.installmentAmount * (d.totalInstallments - d.paidInstallments);
  double _getDebtProgress(DebtModel d) => d.totalInstallments > 0 ? d.paidInstallments / d.totalInstallments : 0;
  bool _isDebtCompleted(DebtModel d) => d.paidInstallments >= d.totalInstallments;

  void _registerPayment(DebtModel debt) {
    if (_isDebtCompleted(debt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Esta deuda ya está completamente pagada! 🎊'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sym = CurrencyFormatter.getSymbol(ref.read(authProvider).user?.currency);
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Icon(LucideIcons.checkCircle, color: Color(0xFF10B981), size: 32)),
                ),
                const SizedBox(height: 16),
                Text('¿Registrar pago?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 8),
                Text(
                  'Cuota #${debt.paidInstallments + 1} de ${debt.name}',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('$sym${debt.installmentAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669))),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        ),
                        child: Text('Cancelar', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final newDebt = debt.copyWith(paidInstallments: debt.paidInstallments + 1);
                          await ref.read(debtNotifierProvider.notifier).updateDebt(newDebt);
                          
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            final transaction = TransactionModel(
                              id: '',
                              userId: uid,
                              amount: debt.installmentAmount,
                              type: 'expense',
                              category: debt.category,
                              description: 'Cuota de ${debt.name}',
                              date: DateTime.now(),
                              isFixed: false,
                            );
                            await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
                          }
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('¡Cuota #${newDebt.paidInstallments} de ${newDebt.name} registrada como gasto! 🎉'),
                                backgroundColor: const Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('✓ Confirmar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paletteGradient = ref.watch(colorPaletteProvider.notifier).getGradient(isDark);
    final loc = ref.watch(localizationProvider);
    final currencyCode = ref.watch(authProvider).user?.currency;
    final sym = CurrencyFormatter.getSymbol(currencyCode);
    
    final debtsAsync = ref.watch(debtsProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
        data: (debts) {
          final activeDebts = debts.where((d) => !_isDebtCompleted(d)).toList();
          final completedDebts = debts.where((d) => _isDebtCompleted(d)).toList();
          
          final displayDebts = _showCompleted ? completedDebts : activeDebts;
          
          final totalRemaining = activeDebts.fold(0.0, (sum, d) => sum + _getDebtRemainingAmount(d));
          final totalAllInstallments = activeDebts.fold(0, (sum, d) => sum + d.totalInstallments);
          final totalPaidInstallments = activeDebts.fold(0, (sum, d) => sum + d.paidInstallments);

          return CustomScrollView(
            slivers: [
              // Custom Header
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(LucideIcons.arrowLeft, color: isDark ? Colors.white : Colors.black),
                  onPressed: () => context.go('/dashboard'),
                ),
                actions: [
                  IconButton(
                    icon: Icon(LucideIcons.history, color: _showCompleted ? const Color(0xFF3B82F6) : (isDark ? Colors.grey[400] : Colors.grey[600])),
                    onPressed: () => setState(() => _showCompleted = !_showCompleted),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  title: Text(loc.get('my_debts'), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Overview Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: paletteGradient,
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: paletteGradient.last.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Balance Restante', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                                Icon(LucideIcons.wallet, color: Colors.white.withOpacity(0.8), size: 24),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(totalRemaining, currencyCode),
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Deudas Activas', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                                    Text('${activeDebts.length}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Cuotas Pagadas', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                                    Text('$totalPaidInstallments / $totalAllInstallments', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),

                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_showCompleted ? 'Deudas Pagadas' : 'Tus Deudas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                          if (!_showCompleted)
                            TextButton.icon(
                              onPressed: () => AddDebtModal.show(context, currencyCode: currencyCode),
                              icon: const Icon(LucideIcons.plusCircle, size: 18),
                              label: const Text('Nueva'),
                            )
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Debts List
              if (displayDebts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.checkSquare, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(_showCompleted ? 'No hay deudas pagadas' : 'No tienes deudas activas 🎉', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final debt = displayDebts[index];
                      final progress = _getDebtProgress(debt);
                      
                      Color progressColor;
                      if (progress < 0.3) {
                        progressColor = const Color(0xFFEF4444);
                      } else if (progress < 0.8) {
                        progressColor = const Color(0xFFF59E0B);
                      } else {
                        progressColor = const Color(0xFF10B981);
                      }

                      return Container(
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: progressColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(debt.category, style: const TextStyle(fontSize: 24)), // assuming category stores emoji here for legacy reasons
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(debt.name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('${CurrencyFormatter.format(debt.installmentAmount, currencyCode)} / cuota', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(LucideIcons.moreHorizontal, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                                      builder: (ctx) => SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(LucideIcons.pencil, color: Color(0xFF3B82F6)),
                                              title: const Text('Editar Deuda'),
                                              onTap: () {
                                                Navigator.pop(ctx);
                                                AddDebtModal.show(context, currencyCode: currencyCode, existingDebt: debt);
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(LucideIcons.trash2, color: Color(0xFFEF4444)),
                                              title: const Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444))),
                                              onTap: () {
                                                ref.read(debtNotifierProvider.notifier).deleteDebt(debt.id);
                                                Navigator.pop(ctx);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Progreso', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                                Text('${(progress * 100).toStringAsFixed(0)}% (${debt.paidInstallments}/${debt.totalInstallments})', style: TextStyle(color: progressColor, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                color: progressColor,
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (!_isDebtCompleted(debt))
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => _registerPayment(debt),
                                  icon: const Icon(LucideIcons.checkCircle2, size: 18),
                                  label: const Text('Pagar Cuota', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: progressColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    childCount: displayDebts.length,
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }
}
