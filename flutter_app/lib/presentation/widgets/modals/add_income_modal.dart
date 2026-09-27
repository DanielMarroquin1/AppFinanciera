import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../common/recurrence_selector_widget.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';

class AddIncomeModal extends ConsumerStatefulWidget {
  final bool isFixed;
  final TransactionModel? existingTransaction;
  
  const AddIncomeModal({super.key, this.isFixed = false, this.existingTransaction});

  static Future<void> show(BuildContext context, {bool isFixed = false, TransactionModel? existingTransaction}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddIncomeModal(isFixed: isFixed, existingTransaction: existingTransaction),
    );
  }

  @override
  ConsumerState<AddIncomeModal> createState() => _AddIncomeModalState();
}

class _AddIncomeModalState extends ConsumerState<AddIncomeModal> {
  String amount = "";
  String amount2 = "";
  String category = "";
  String description = "";
  DateTime date = DateTime.now();
  late TextEditingController _amountController;
  late TextEditingController _amount2Controller;
  late TextEditingController _descController;
  bool isExtraIncome = false;

  String? recurrenceType;
  int? recurrenceDay = 1;
  int? recurrenceDay2;

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      amount = widget.existingTransaction!.amount.toString();
      amount2 = widget.existingTransaction!.recurrenceAmount2?.toString() ?? "";
      category = widget.existingTransaction!.category;
      description = widget.existingTransaction!.description;
      date = widget.existingTransaction!.date;
      recurrenceType = widget.existingTransaction!.recurrenceType;
      recurrenceDay = widget.existingTransaction!.recurrenceDay ?? 1;
      recurrenceDay2 = widget.existingTransaction!.recurrenceDay2;
    }
        _amountController = TextEditingController(text: amount);
    _amount2Controller = TextEditingController(text: amount2);
    _descController = TextEditingController(text: description.replaceAll('(Extra)', '').trim());
    isExtraIncome = widget.existingTransaction?.description.contains('(Extra)') ?? false;
  }

  @override
  void dispose() {
        _amountController.dispose();
    _amount2Controller.dispose();
    _descController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> detailedCategories = [
    {
      'main': 'Trabajo', 'emoji': '💼',
      'subs': [
        {'value': 'salary', 'label': 'Salario Fijo', 'emoji': '💼'},
        {'value': 'freelance', 'label': 'Freelance / Proyectos', 'emoji': '💻'},
        {'value': 'bonus', 'label': 'Bonificación / Extra', 'emoji': '🎁'},
      ]
    },
    {
      'main': 'Inversiones', 'emoji': '📈',
      'subs': [
        {'value': 'investment', 'label': 'Rendimientos', 'emoji': '📈'},
        {'value': 'sale', 'label': 'Venta de Activos', 'emoji': '🏷️'},
        {'value': 'dividends', 'label': 'Dividendos', 'emoji': '💸'},
      ]
    },
    {
      'main': 'Otros', 'emoji': '🎉',
      'subs': [
        {'value': 'gift', 'label': 'Regalo', 'emoji': '🎉'},
        {'value': 'other', 'label': 'Otro Ingreso', 'emoji': '💰'},
      ]
    },
  ];

  Map<String, String> _getCategoryDetails(String val) {
    for (var mainCat in detailedCategories) {
      for (var sub in mainCat['subs']) {
        if (sub['value'] == val) {
          return {'label': sub['label']!, 'emoji': sub['emoji']!};
        }
      }
    }
    return {'label': 'Seleccionar Categoría', 'emoji': '📁'};
  }

  void _showCategoryPicker(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.82,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, -10)),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF15803D)]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: const Color(0xFF22C55E).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: const Icon(LucideIcons.tags, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Elige una Categoría',
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Organiza tus ingresos para reportes precisos',
                            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () async {
                        HapticFeedback.mediumImpact();
                        
                        // Validation
                        bool isBiweekly = widget.isFixed && category == 'salary' && recurrenceType == 'bimonthly';
                        final parsedAmount = double.tryParse(amount) ?? 0.0;
                        final parsedAmount2 = double.tryParse(amount2) ?? 0.0;
                        
                        if (parsedAmount <= 0 || category.isEmpty || (isBiweekly && parsedAmount2 <= 0)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Por favor, ingresa correctamente todos los montos y datos.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                          return;
                        }
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid == null) return;
                        
                        final isEditing = widget.existingTransaction != null;
                        
                        final transaction = TransactionModel(
                          id: isEditing ? widget.existingTransaction!.id : '',
                          userId: uid,
                          amount: parsedAmount,
                          type: 'income',
                          category: category,
                          description: isExtraIncome ? '${description.trim()} (Extra)'.trim() : description.trim(),
                          date: date,
                          isFixed: widget.isFixed,
                          recurrenceType: widget.isFixed ? (recurrenceType ?? 'monthly') : null,
                          recurrenceDay: widget.isFixed ? recurrenceDay : null,
                          recurrenceDay2: widget.isFixed && recurrenceType == 'bimonthly' ? recurrenceDay2 : null,
                          recurrenceAmount2: (widget.isFixed && category == 'salary' && recurrenceType == 'bimonthly') ? parsedAmount2 : null,
                        );

                        if (isEditing) {
                          await ref.read(transactionNotifierProvider.notifier).updateTransaction(transaction);
                        } else {
                          await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
                        }

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(dismissDirection: DismissDirection.horizontal, content: Text(isEditing ? 'Ingreso actualizado exitosamente' : 'Ingreso agregado exitosamente', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              backgroundColor: isDark ? const Color(0xFF065F46) : const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF059669) : const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        disabledForegroundColor: isDark ? Colors.grey[500] : Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: Text(widget.existingTransaction != null ? 'Guardar Cambios' : (widget.isFixed ? 'Agregar Ingreso Fijo' : 'Agregar Ingreso'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
