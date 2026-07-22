import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saving_goals_provider.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/saving_goal.dart';

class AddFundsModal extends ConsumerStatefulWidget {
  final SavingGoal goal;
  const AddFundsModal({super.key, required this.goal});

  static Future<void> show(BuildContext context, {required SavingGoal goal}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFundsModal(goal: goal),
    );
  }

  @override
  ConsumerState<AddFundsModal> createState() => _AddFundsModalState();
}

class _AddFundsModalState extends ConsumerState<AddFundsModal> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = ref.watch(authProvider).user?.currency ?? 'USD';
    final sym = CurrencyFormatter.getSymbol(currency);
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Aportar a "${widget.goal.name}"',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Progreso actual: $sym${widget.goal.currentAmount.toStringAsFixed(2)} / $sym${widget.goal.targetAmount.toStringAsFixed(2)}',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixText: '$sym ',
                prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                hintText: '0.00',
                hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                filled: true,
                fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading || amount <= 0
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      try {
                        final updatedGoal = widget.goal.copyWith(
                          currentAmount: widget.goal.currentAmount + amount,
                        );
                        await ref.read(savingGoalsProvider.notifier).updateGoal(updatedGoal);
                        if (mounted) {
                          final isPremium = ref.read(authProvider).user?.isPremium ?? false;
                          await AdService().registerActionAndShowInterstitial(
                            context,
                            isPremium,
                            onAdClosed: () {
                              if (mounted) Navigator.of(context).pop();
                            },
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Confirmar Ahorro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
