import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';

class AddExpenseModal extends ConsumerStatefulWidget {
  final bool isFixed;
  final String? currencyCode;
  final TransactionModel? existingTransaction;
  
  const AddExpenseModal({super.key, this.isFixed = false, this.currencyCode, this.existingTransaction});

  static Future<void> show(BuildContext context, {bool isFixed = false, String? currencyCode, TransactionModel? existingTransaction}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseModal(isFixed: isFixed, currencyCode: currencyCode, existingTransaction: existingTransaction),
    );
  }

  @override
  ConsumerState<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends ConsumerState<AddExpenseModal> {
  String amount = "";
  String category = "";
  String description = "";
  DateTime date = DateTime.now();
  late TextEditingController _amountController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      amount = widget.existingTransaction!.amount.toString();
      category = widget.existingTransaction!.category;
      description = widget.existingTransaction!.description;
      date = widget.existingTransaction!.date;
    }
    _amountController = TextEditingController(text: amount);
    _descController = TextEditingController(text: description);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  final expenseCategories = [
    {'value': 'food', 'label': 'Comida', 'emoji': '🍔'},
    {'value': 'transport', 'label': 'Transporte', 'emoji': '🚗'},
    {'value': 'shopping', 'label': 'Compras', 'emoji': '🛍️'},
    {'value': 'bills', 'label': 'Servicios', 'emoji': '📱'},
    {'value': 'entertainment', 'label': 'Ocio', 'emoji': '🎮'},
    {'value': 'health', 'label': 'Salud', 'emoji': '💊'},
    {'value': 'education', 'label': 'Educación', 'emoji': '📚'},
    {'value': 'home', 'label': 'Hogar', 'emoji': '🏠'},
    {'value': 'other', 'label': 'Otro', 'emoji': '💸'},
  ];

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
                  ? const LinearGradient(colors: [Color(0xFFB91C1C), Color(0xFFBE185D)]) // red-700 to pink-700
                  : const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFDB2777)]), // red-600 to pink-600
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
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                          child: Icon(widget.isFixed ? LucideIcons.receipt : LucideIcons.trendingDown, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(widget.existingTransaction != null ? 'Editar Gasto' : (widget.isFixed ? loc.get('fixed_expense') : loc.get('new_expense')), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(widget.isFixed ? 'Registra gastos recurrentes como renta, servicios, etc.' : 'Registra tus gastos para tener mejor control', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
              ],
            ),
          ),

          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Amount
                  Text('${loc.get('amount')} 💵', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) => amount = val,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(12),
                        child: Text(CurrencyFormatter.getSymbol(widget.currencyCode), style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)), // red-500
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category
                  Text('${loc.get('category')} 🏷️', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: expenseCategories.map((cat) {
                      final isSelected = category == cat['value'];
                      return InkWell(
                        onTap: () => setState(() => category = cat['value']!),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 56) / 2, // 2 cols minus padding
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.5) : const Color(0xFFFEE2E2)) 
                                : (isDark ? const Color(0xFF374151) : Colors.white),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFDC2626) : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(cat['emoji']!, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(cat['label']!, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14))),
                              if (isSelected) 
                                Container(
                                  width: 20, height: 20,
                                  decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                                )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text('${loc.get('description_optional')} 📝', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    onChanged: (val) => description = val,
                    maxLines: 3,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Ej: Compras en supermercado...',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      prefixIcon: Padding(padding: const EdgeInsets.only(bottom: 40), child: Icon(LucideIcons.tag, color: isDark ? Colors.grey[500] : Colors.grey[400])),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date (Simplified for UI copy)
                  Text('${loc.get('date')} 📅', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : Colors.white,
                      border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.calendar, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                        const SizedBox(width: 12),
                        Text('${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: amount.isEmpty || category.isEmpty ? null : () async {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid == null) return;
                        
                        final parsedAmount = double.tryParse(amount) ?? 0.0;
                        if (parsedAmount <= 0) return;

                        final isEditing = widget.existingTransaction != null;
                        
                        final transaction = TransactionModel(
                          id: isEditing ? widget.existingTransaction!.id : '', // Firestore will auto-generate if empty
                          userId: uid,
                          amount: parsedAmount,
                          type: 'expense',
                          category: category,
                          description: description,
                          date: date,
                          isFixed: widget.isFixed,
                        );

                        if (isEditing) {
                          await ref.read(transactionNotifierProvider.notifier).updateTransaction(transaction);
                        } else {
                          await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
                        }

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEditing ? 'Gasto actualizado' : loc.get('expense_added'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              backgroundColor: isDark ? const Color(0xFF991B1B) : const Color(0xFFDC2626),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFFE11D48) : const Color(0xFFF43F5E), // rose
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        disabledForegroundColor: isDark ? Colors.grey[500] : Colors.grey[400],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: Text(widget.existingTransaction != null ? 'Guardar Cambios' : (widget.isFixed ? loc.get('add_fixed_expense') : loc.get('add_expense')), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
