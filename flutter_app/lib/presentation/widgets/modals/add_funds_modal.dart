import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saving_goals_provider.dart';
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
  double amount = 0.0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sym = CurrencyFormatter.getSymbol(ref.watch(authProvider).user?.currency);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                    'Agregar fondos a ${widget.goal.name}',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
            const SizedBox(height: 8),
            // Progreso actual
            Text(
              'Progreso actual: $sym${widget.goal.currentAmount.toStringAsFixed(2)} / $sym${widget.goal.targetAmount.toStringAsFixed(2)}',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 24),
            Text('¿Cuánto quieres ahorrar hoy? 💰', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700])),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) {
                setState(() {
                  amount = double.tryParse(val) ?? 0.0;
                });
              },
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Text(sym, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
                hintText: '0.00',
                hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
                filled: true,
                fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
                        if (mounted) Navigator.of(context).pop();
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
