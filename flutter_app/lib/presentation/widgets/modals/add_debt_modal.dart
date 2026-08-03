import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/debt.dart';
import '../../providers/debts_provider.dart';
import '../common/recurrence_selector_widget.dart';
import '../../providers/color_palette_provider.dart';
import '../../providers/auth_provider.dart';

class AddDebtModal extends ConsumerStatefulWidget {
  final String? currencyCode;
  final DebtModel? existingDebt;
  const AddDebtModal({super.key, this.currencyCode, this.existingDebt});

  static Future<void> show(BuildContext context, {String? currencyCode, DebtModel? existingDebt}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddDebtModal(currencyCode: currencyCode, existingDebt: existingDebt),
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
  bool isAutoPay = true;
  String? recurrenceType; // default null so day selector only shows when selected
  int recurrenceDay = 1;
  int? recurrenceDay2 = 16;
  String selectedEmoji = '🏦';
  final emojis = ['🏦', '💳', '🏠', '🚗', '💻', '📱', '📺', '🎓', '💊', '✈️'];

  @override
  void initState() {
    super.initState();
    if (widget.existingDebt != null) {
      name = widget.existingDebt!.name;
      amountPerInstallment = widget.existingDebt!.installmentAmount;
      totalInstallments = widget.existingDebt!.totalInstallments;
      currentInstallment = widget.existingDebt!.paidInstallments;
      isAutoPay = widget.existingDebt!.isAutoPay;
      recurrenceType = widget.existingDebt!.recurrenceType;
      recurrenceDay = widget.existingDebt!.recurrenceDay ?? 1;
      recurrenceDay2 = widget.existingDebt!.recurrenceDay2;
      selectedEmoji = widget.existingDebt!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);
    final paletteGradient = ref.read(colorPaletteProvider.notifier).getGradient(isDark);
    final userCurrency = widget.currencyCode ?? ref.watch(authProvider).user?.currency;

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
                        Text(widget.existingDebt != null ? 'Editar Deuda' : loc.get('new_debt'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
                  // Emoji selector
                  // Premium Emoji Category Selector
                  Text('CATEGORÍA', style: TextStyle(color: isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: emojis.map((e) {
                        final isSelected = selectedEmoji == e;
                        return GestureDetector(
                          onTap: () => setState(() => selectedEmoji = e),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 52, height: 52,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF3B82F6).withValues(alpha: 0.2) : const Color(0xFFDBEAFE))
                                  : (isDark ? const Color(0xFF334155) : Colors.white),
                              border: Border.all(
                                color: isSelected 
                                    ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6))
                                    : Colors.transparent, 
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]
                                  : [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Center(
                              child: Text(e, style: TextStyle(fontSize: isSelected ? 26 : 22)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Premium Concept/Description Field
                  Text('CONCEPTO', style: TextStyle(color: isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: TextEditingController(text: name)..selection = TextSelection.collapsed(offset: name.length),
                      onChanged: (val) => name = val,
                      maxLines: null,
                      minLines: 1,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Ej: iPhone 15 Pro...',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                        prefixIcon: Icon(LucideIcons.penTool, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 18),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Massive Amount Input
                  Center(
                    child: Column(
                      children: [
                        Text(loc.get('amount').toUpperCase(), style: TextStyle(color: isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        IntrinsicWidth(
                          child: TextField(
                            controller: TextEditingController(text: amountPerInstallment > 0 ? amountPerInstallment.toString() : '')..selection = TextSelection.collapsed(offset: amountPerInstallment > 0 ? amountPerInstallment.toString().length : 0),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (val) => amountPerInstallment = double.tryParse(val) ?? 0.0,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                              prefixText: CurrencyFormatter.getSymbol(userCurrency),
                              prefixStyle: TextStyle(color: isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB), fontSize: 32, fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

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
                              controller: TextEditingController(text: totalInstallments.toString())..selection = TextSelection.collapsed(offset: totalInstallments.toString().length),
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
                              controller: TextEditingController(text: currentInstallment.toString())..selection = TextSelection.collapsed(offset: currentInstallment.toString().length),
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
                  const SizedBox(height: 24),

                  // Auto Pay toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(LucideIcons.refreshCw, color: isDark ? const Color(0xFFA855F7) : const Color(0xFF9333EA), size: 20),
                                const SizedBox(width: 8),
                                Text('Pago Automático', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            Switch(
                              value: isAutoPay,
                              activeColor: const Color(0xFFA855F7),
                              onChanged: (val) {
                                setState(() {
                                  isAutoPay = val;
                                  if (isAutoPay && recurrenceType == null) {
                                    recurrenceType = 'monthly';
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        if (isAutoPay) ...[
                          const SizedBox(height: 16),
                          RecurrenceSelectorWidget(
                            isDark: isDark,
                            recurrenceType: recurrenceType,
                            recurrenceDay: recurrenceDay,
                            recurrenceDay2: recurrenceDay2,
                            activeColor: const Color(0xFFA855F7),
                            onTypeChanged: (val) {
                              setState(() {
                                recurrenceType = val;
                                recurrenceDay = 1;
                                recurrenceDay2 = (val == 'bimonthly') ? 16 : null;
                              });
                            },
                            onDayChanged: (val) => setState(() => recurrenceDay = val),
                            onDay2Changed: (val) => setState(() => recurrenceDay2 = val),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit
                  ElevatedButton(
                    onPressed: name.isEmpty || amountPerInstallment <= 0 ? null : () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) return;

                      final isEditing = widget.existingDebt != null;

                      final debt = DebtModel(
                        id: isEditing ? widget.existingDebt!.id : '',
                        userId: uid,
                        name: name,
                        installmentAmount: amountPerInstallment,
                        totalInstallments: totalInstallments,
                        paidInstallments: currentInstallment,
                        category: selectedEmoji,
                        isAutoPay: isAutoPay,
                        recurrenceType: isAutoPay ? recurrenceType : null,
                        recurrenceDay: isAutoPay ? recurrenceDay : null,
                        recurrenceDay2: (isAutoPay && recurrenceType == 'bimonthly') ? recurrenceDay2 : null,
                        createdAt: isEditing ? widget.existingDebt!.createdAt : DateTime.now(),
                        lastProcessedDate: isEditing ? widget.existingDebt!.lastProcessedDate : null,
                      );

                      if (isEditing) {
                        await ref.read(debtNotifierProvider.notifier).updateDebt(debt);
                      } else {
                        await ref.read(debtNotifierProvider.notifier).addDebt(debt);
                      }

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEditing ? 'Deuda actualizada exitosamente' : 'Deuda guardada exitosamente', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                        child: Text(widget.existingDebt != null ? 'Guardar Cambios' : loc.get('add_debt'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
