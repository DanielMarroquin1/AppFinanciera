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
          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
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
    ref.watch(colorPaletteProvider);
    final paletteGradient = ref.read(colorPaletteProvider.notifier).getGradient(isDark);
    final loc = ref.watch(localizationProvider);
    final sym = CurrencyFormatter.getSymbol(ref.watch(authProvider).user?.currency);
    
    final debtsAsync = ref.watch(debtsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
        data: (debts) {
          final activeDebts = debts.where((d) => !_isDebtCompleted(d)).toList();
          final completedDebts = debts.where((d) => _isDebtCompleted(d)).toList();
          final totalRemaining = debts.fold(0.0, (sum, d) => sum + _getDebtRemainingAmount(d));
          final totalPaidInstallments = debts.fold(0, (sum, d) => sum + d.paidInstallments);
          final totalAllInstallments = debts.fold(0, (sum, d) => sum + d.totalInstallments);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    InkWell(
                      onTap: () => context.go('/dashboard'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(LucideIcons.arrowLeft, color: isDark ? Colors.white : Colors.black),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.get('my_debts'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                          const SizedBox(height: 4),
                          Text('Control de pagos a cuotas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Summary Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: paletteGradient,
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Deuda Total Pendiente', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                              const SizedBox(height: 8),
                              Text('$sym${totalRemaining.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Text('$totalPaidInstallments/$totalAllInstallments', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('cuotas', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Overall progress bar
                      Container(
                        height: 8, width: double.infinity,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: totalAllInstallments > 0 ? (totalPaidInstallments / totalAllInstallments).clamp(0.0, 1.0) : 0,
                          child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${activeDebts.length} deuda${activeDebts.length != 1 ? 's' : ''} activa${activeDebts.length != 1 ? 's' : ''} · ${completedDebts.length} completada${completedDebts.length != 1 ? 's' : ''}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Add Debt Button
                InkWell(
                  onTap: () => AddDebtModal.show(context, currencyCode: ref.read(authProvider).user?.currency),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.plus, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                        const SizedBox(width: 8),
                        Text('Agregar Nueva Deuda', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Active Debts
                if (activeDebts.isNotEmpty) ...[
                  Text('Deudas Activas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
                  const SizedBox(height: 12),
                  ...activeDebts.map((debt) => _buildDebtCard(debt, isDark, paletteGradient)),
                ],

                // Completed toggle
                if (completedDebts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () => setState(() => _showCompleted = !_showCompleted),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2937) : Colors.white,
                        border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.history, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
                              const SizedBox(width: 8),
                              Text('Historial de Pagadas (${completedDebts.length})', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Icon(_showCompleted ? LucideIcons.chevronUp : LucideIcons.chevronDown, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                  if (_showCompleted) ...[
                    const SizedBox(height: 16),
                    ...completedDebts.map((debt) => _buildDebtCard(debt, isDark, paletteGradient)),
                  ],
                ],

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDebtCard(DebtModel debt, bool isDark, List<Color> paletteGradient) {
    final sym = CurrencyFormatter.getSymbol(ref.watch(authProvider).user?.currency);
    final progress = _getDebtProgress(debt);
    final isCompleted = _isDebtCompleted(debt);
    final percentage = (progress * 100).toStringAsFixed(0);
    final debtColors = [paletteGradient[0], paletteGradient.length > 1 ? paletteGradient[1] : paletteGradient[0]];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        border: Border.all(
          color: isCompleted
              ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFA7F3D0))
              : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
          width: isCompleted ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: debtColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(debt.category, style: const TextStyle(fontSize: 24))),
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
                            debt.name,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('Pagado', style: TextStyle(color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$sym${debt.installmentAmount.toStringAsFixed(0)}/cuota · ${debt.paidInstallments}/${debt.totalInstallments} pagadas',
                      style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 10, width: double.infinity,
            decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: isCompleted ? [const Color(0xFF10B981), const Color(0xFF059669)] : debtColors),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bottom row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$percentage% completado', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    isCompleted
                        ? '¡Deuda pagada! 🎉'
                        : 'Faltan $sym${_getDebtRemainingAmount(debt).toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isCompleted
                          ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                          : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626)),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (!isCompleted)
                ElevatedButton.icon(
                  onPressed: () => _registerPayment(debt),
                  icon: const Icon(LucideIcons.chevronUp, size: 16),
                  label: const Text('+1 Cuota', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                    foregroundColor: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
            ],
          ),

          // Detail summary (expandable info)
          if (!isCompleted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildDetailChip(isDark, 'Total', '$sym${_getDebtTotalAmount(debt).toStringAsFixed(0)}'),
                  const SizedBox(width: 8),
                  _buildDetailChip(isDark, 'Pagado', '$sym${_getDebtPaidAmount(debt).toStringAsFixed(0)}'),
                  const SizedBox(width: 8),
                  _buildDetailChip(isDark, 'Restante', '$sym${_getDebtRemainingAmount(debt).toStringAsFixed(0)}'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip(bool isDark, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
