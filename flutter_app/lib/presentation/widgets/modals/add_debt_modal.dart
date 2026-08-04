import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import '../../../domain/entities/debt.dart';
import '../../providers/debts_provider.dart';
import '../common/recurrence_selector_widget.dart';
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
  String? recurrenceType;
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

  Widget _buildGlassField({required Widget child, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.watch(localizationProvider);
    final userCurrency = widget.currencyCode ?? ref.watch(authProvider).user?.currency;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        image: DecorationImage(
          image: const AssetImage('assets/images/noise.png'),
          opacity: isDark ? 0.03 : 0.01,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 48, height: 5,
            decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey[300], borderRadius: BorderRadius.circular(3)),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: const Icon(LucideIcons.calendarClock, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(widget.existingDebt != null ? 'Editar Deuda' : loc.get('new_debt'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Emoji Selector
                  Text('Icono Representativo', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 55,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: emojis.length,
                      itemBuilder: (context, index) {
                        final emoji = emojis[index];
                        final isSelected = selectedEmoji == emoji;
                        return GestureDetector(
                          onTap: () => setState(() => selectedEmoji = emoji),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? (isDark ? const Color(0xFF3B82F6).withOpacity(0.2) : const Color(0xFFDBEAFE)) : (isDark ? const Color(0xFF1E293B) : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)), width: isSelected ? 2 : 1),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 22)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name
                  Text('Nombre de la Deuda', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildGlassField(
                    isDark: isDark,
                    child: TextFormField(
                      initialValue: name,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ej. Préstamo Auto, iPhone...',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) => setState(() => name = val),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amount
                  Text('Monto por Cuota', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildGlassField(
                    isDark: isDark,
                    child: TextFormField(
                      initialValue: amountPerInstallment > 0 ? amountPerInstallment.toStringAsFixed(0) : '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6), fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixText: CurrencyFormatter.getSymbol(userCurrency),
                        prefixStyle: TextStyle(color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6), fontSize: 24, fontWeight: FontWeight.bold),
                        hintText: '0',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                      ),
                      onChanged: (val) => setState(() => amountPerInstallment = double.tryParse(val) ?? 0.0),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Installments Info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cuotas Totales', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            _buildGlassField(
                              isDark: isDark,
                              child: TextFormField(
                                initialValue: totalInstallments.toString(),
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(border: InputBorder.none),
                                onChanged: (val) => setState(() => totalInstallments = int.tryParse(val) ?? 1),
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
                            Text('Cuotas Pagadas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            _buildGlassField(
                              isDark: isDark,
                              child: TextFormField(
                                initialValue: currentInstallment.toString(),
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(border: InputBorder.none),
                                onChanged: (val) => setState(() => currentInstallment = int.tryParse(val) ?? 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Automation
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isAutoPay ? (isDark ? const Color(0xFF3B82F6).withOpacity(0.1) : const Color(0xFFEFF6FF)) : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isAutoPay ? const Color(0xFF3B82F6) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)), width: isAutoPay ? 2 : 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, shape: BoxShape.circle),
                              child: Icon(LucideIcons.repeat, color: isAutoPay ? const Color(0xFF3B82F6) : Colors.grey, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Recordatorio Automático', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text('Te recordaremos pagar tu cuota', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            ),
                            Switch(
                              value: isAutoPay,
                              activeColor: const Color(0xFF3B82F6),
                              onChanged: (val) {
                                setState(() {
                                  isAutoPay = val;
                                  if (isAutoPay && recurrenceType == null) recurrenceType = 'monthly';
                                });
                              },
                            ),
                          ],
                        ),
                        if (isAutoPay) ...[
                          const SizedBox(height: 20),
                          RecurrenceSelectorWidget(
                            isDark: isDark,
                            recurrenceType: recurrenceType,
                            recurrenceDay: recurrenceDay,
                            recurrenceDay2: recurrenceDay2,
                            activeColor: const Color(0xFF3B82F6),
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
                  const SizedBox(height: 40),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
                              content: Text(isEditing ? 'Deuda actualizada' : 'Deuda creada', style: const TextStyle(fontWeight: FontWeight.bold)),
                              backgroundColor: const Color(0xFF3B82F6),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        elevation: 10,
                        shadowColor: const Color(0xFF3B82F6).withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(widget.existingDebt != null ? 'Guardar Cambios' : loc.get('add_debt'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
