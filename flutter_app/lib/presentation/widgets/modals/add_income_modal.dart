import 'package:flutter/material.dart';
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
  String category = "";
  String description = "";
  DateTime date = DateTime.now();
  late TextEditingController _amountController;
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
      category = widget.existingTransaction!.category;
      description = widget.existingTransaction!.description;
      date = widget.existingTransaction!.date;
      recurrenceType = widget.existingTransaction!.recurrenceType;
      recurrenceDay = widget.existingTransaction!.recurrenceDay ?? 1;
      recurrenceDay2 = widget.existingTransaction!.recurrenceDay2;
    }
    _amountController = TextEditingController(text: amount);
    _descController = TextEditingController(text: description.replaceAll('(Extra)', '').trim());
    isExtraIncome = widget.existingTransaction?.description.contains('(Extra)') ?? false;
  }

  @override
  void dispose() {
    _amountController.dispose();
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
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(LucideIcons.xCircle, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 28),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0), height: 1),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: detailedCategories.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                itemBuilder: (ctx, i) {
                  final mainCat = detailedCategories[i];
                  final subs = mainCat['subs'] as List;
                  
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(mainCat['emoji'], style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Text(
                              mainCat['main'],
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: subs.map<Widget>((subMap) {
                            final sub = subMap as Map<String, String>;
                            final isSelected = category == sub['value'];
                            return InkWell(
                              onTap: () {
                                setState(() => category = sub['value']!);
                                Navigator.pop(ctx);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF15803D)])
                                      : (isDark ? const LinearGradient(colors: [Color(0xFF374151), Color(0xFF1F2937)]) : const LinearGradient(colors: [Colors.white, Color(0xFFF8FAFC)])),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF22C55E) : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE2E8F0)),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: const Color(0xFF22C55E).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                                      : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1))],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(sub['emoji']!, style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text(
                                      sub['label']!,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : (isDark ? Colors.grey[200] : Colors.grey[800]),
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 6),
                                      const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 14),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  ? const LinearGradient(colors: [Color(0xFF15803D), Color(0xFF047857)]) // green-700 to emerald-700
                  : const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF059669)]), // green-600 to emerald-600
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
                          child: Icon(widget.isFixed ? LucideIcons.repeat : LucideIcons.trendingUp, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text(widget.existingTransaction != null ? 'Editar Ingreso' : (widget.isFixed ? 'Ingreso Fijo' : 'Nuevo Ingreso'), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isFixed 
                      ? 'Registra ingresos recurrentes como salario, renta, pensión, etc.'
                      : 'Registra tus ingresos para llevar un mejor control',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                ),
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
                  Text('Monto 💵', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
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
                        child: Text(CurrencyFormatter.getSymbol(ref.watch(authProvider).user?.currency), style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2)), // green-500
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Categoría 🏷️', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14, fontWeight: FontWeight.bold)),
                      if (category.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => category = ''),
                          child: Text('Limpiar', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () => _showCategoryPicker(isDark),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: category.isNotEmpty
                            ? (isDark
                                ? LinearGradient(colors: [const Color(0xFF16A34A).withValues(alpha: 0.25), const Color(0xFF14532D).withValues(alpha: 0.15)])
                                : const LinearGradient(colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)]))
                            : (isDark
                                ? LinearGradient(colors: [const Color(0xFF1F2937), const Color(0xFF111827).withValues(alpha: 0.8)])
                                : const LinearGradient(colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)])),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: category.isNotEmpty
                              ? (isDark ? const Color(0xFF22C55E) : const Color(0xFF16A34A))
                              : (isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                          width: category.isNotEmpty ? 2 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: category.isNotEmpty
                                ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: category.isNotEmpty
                                  ? const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF15803D)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                                  : (isDark ? const LinearGradient(colors: [Color(0xFF374151), Color(0xFF1F2937)]) : const LinearGradient(colors: [Colors.white, Color(0xFFE2E8F0)])),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _getCategoryDetails(category)['emoji']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.isEmpty ? 'Seleccionar Categoría' : _getCategoryDetails(category)['label']!,
                                  style: TextStyle(
                                    color: category.isEmpty ? (isDark ? Colors.grey[400] : Colors.grey[600]) : (isDark ? Colors.white : Colors.black87),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  category.isEmpty ? 'Toca para elegir una opción' : 'Categoría seleccionada',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  category.isEmpty ? 'Elegir' : 'Cambiar',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(LucideIcons.chevronDown, size: 14, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text('Descripción (Opcional) 📝', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    onChanged: (val) => description = val,
                    maxLines: 3,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Ej: Pago de proyecto freelance...',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      prefixIcon: Padding(padding: const EdgeInsets.only(bottom: 40), child: Icon(LucideIcons.tag, color: isDark ? Colors.grey[500] : Colors.grey[400])),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Extra Income Toggle
                  if (!widget.isFixed) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151).withValues(alpha: 0.5) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ingreso Extra', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text('No sumar al total de ingresos (solo al balance)', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          Switch(
                            value: isExtraIncome,
                            onChanged: (val) => setState(() => isExtraIncome = val),
                            activeColor: const Color(0xFF22C55E),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Date
                  Text('Fecha 📅', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: isDark 
                                ? const ColorScheme.dark(primary: Color(0xFF16A34A), onPrimary: Colors.white, onSurface: Colors.white)
                                : const ColorScheme.light(primary: Color(0xFF16A34A), onPrimary: Colors.white, onSurface: Colors.black),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => date = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151) : Colors.white,
                        border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.calendar, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                              const SizedBox(width: 12),
                              Text('${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16)),
                            ],
                          ),
                          Icon(LucideIcons.edit2, size: 16, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),

                  if (widget.isFixed) ...[
                    const SizedBox(height: 20),
                    RecurrenceSelectorWidget(
                      isDark: isDark,
                      recurrenceType: recurrenceType,
                      recurrenceDay: recurrenceDay ?? 1,
                      recurrenceDay2: recurrenceDay2,
                      activeColor: const Color(0xFF10B981),
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
                  ],
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
                              content: Text(isEditing ? 'Ingreso actualizado exitosamente' : 'Ingreso agregado exitosamente', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
