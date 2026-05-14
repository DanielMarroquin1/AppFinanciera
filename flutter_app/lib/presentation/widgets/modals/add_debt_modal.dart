import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/debt.dart';
import '../../providers/debts_provider.dart';

class AddDebtModal extends ConsumerStatefulWidget {
  final String? currencyCode;
  const AddDebtModal({super.key, this.currencyCode});

  static Future<void> show(BuildContext context, {String? currencyCode}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddDebtModal(currencyCode: currencyCode),
    );
  }

  @override
  ConsumerState<AddDebtModal> createState() => _AddDebtModalState();
}

class _AddDebtModalState extends ConsumerState<AddDebtModal> {
  String name = "";
  double amountPerInstallment = 0.0;
  int totalInstallments = 1;
  int currentInstallment = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark 
                  ? const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]) // purple-500 to purple-700
                  : const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFF7E22CE)]), // purple-400 to purple-600
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(LucideIcons.creditCard, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(loc.get('new_debt'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text('Lleva un control de tus pagos a plazos o tarjetas de crédito', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Concept
                  Text('Concepto 📝', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (val) => name = val,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Ej: iPhone 15 Pro, Laptop...',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA855F7), width: 2)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Amount per Installment
                  Text('${loc.get('amount')} 💵', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) => amountPerInstallment = double.tryParse(val) ?? 0.0,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(12),
                        child: Text(CurrencyFormatter.getSymbol(widget.currencyCode), style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA855F7), width: 2)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Installments Selector
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.get('total_installments'), style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                            const SizedBox(height: 8),
                            TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (val) => totalInstallments = int.tryParse(val) ?? 1,
                              decoration: InputDecoration(
                                hintText: '12',
                                filled: true,
                                fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA855F7), width: 2)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.get('paid_installments'), style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                            const SizedBox(height: 8),
                            TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (val) => currentInstallment = int.tryParse(val) ?? 0,
                              decoration: InputDecoration(
                                hintText: '0',
                                filled: true,
                                fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA855F7), width: 2)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Submit
                  ElevatedButton(
                    onPressed: name.isEmpty || amountPerInstallment <= 0 ? null : () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) return;

                      final debt = DebtModel(
                        id: '',
                        userId: uid,
                        name: name,
                        installmentAmount: amountPerInstallment,
                        totalInstallments: totalInstallments,
                        paidInstallments: currentInstallment,
                        category: '🏦',
                        createdAt: DateTime.now(),
                      );

                      await ref.read(debtNotifierProvider.notifier).addDebt(debt);

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Deuda guardada exitosamente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            backgroundColor: isDark ? const Color(0xFF6D28D9) : const Color(0xFF9333EA),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith((states) => null), 
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: isDark 
                            ? const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]) 
                            : const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFF7E22CE)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(minHeight: 50),
                        child: Text(loc.get('add_debt'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
