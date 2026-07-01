import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/localization.dart';
import '../../providers/credit_card_provider.dart';
import '../../../domain/entities/credit_card.dart';
import '../common/recurrence_selector_widget.dart';
import '../../providers/auth_provider.dart';

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

  String? recurrenceType;
  int? recurrenceDay = 1;
  int? recurrenceDay2;
  String? creditCardId; // null = Efectivo/Cuenta

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
      creditCardId = widget.existingTransaction!.creditCardId;
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

  final List<Map<String, dynamic>> detailedCategories = [
    {
      'main': 'Comida', 'emoji': '🍔',
      'subs': [
        {'value': 'food', 'label': 'General', 'emoji': '🍔'},
        {'value': 'food_grocery', 'label': 'Supermercado', 'emoji': '🛒'},
        {'value': 'food_restaurant', 'label': 'Restaurante', 'emoji': '🍽️'},
        {'value': 'food_coffee', 'label': 'Cafetería', 'emoji': '☕'},
        {'value': 'food_delivery', 'label': 'Delivery', 'emoji': '🛵'},
      ]
    },
    {
      'main': 'Transporte', 'emoji': '🚗',
      'subs': [
        {'value': 'transport', 'label': 'General', 'emoji': '🚗'},
        {'value': 'transport_gas', 'label': 'Gasolina', 'emoji': '⛽'},
        {'value': 'transport_public', 'label': 'Transporte Público', 'emoji': '🚌'},
        {'value': 'transport_taxi', 'label': 'Taxi / App', 'emoji': '🚕'},
        {'value': 'transport_flight', 'label': 'Vuelos', 'emoji': '✈️'},
      ]
    },
    {
      'main': 'Servicios', 'emoji': '📱',
      'subs': [
        {'value': 'bills', 'label': 'General', 'emoji': '📱'},
        {'value': 'bills_water', 'label': 'Agua', 'emoji': '💧'},
        {'value': 'bills_electricity', 'label': 'Luz', 'emoji': '⚡'},
        {'value': 'bills_internet', 'label': 'Internet / TV', 'emoji': '🌐'},
        {'value': 'bills_gas', 'label': 'Gas', 'emoji': '🔥'},
      ]
    },
    {
      'main': 'Compras', 'emoji': '🛍️',
      'subs': [
        {'value': 'shopping', 'label': 'General', 'emoji': '🛍️'},
        {'value': 'shopping_clothes', 'label': 'Ropa y Calzado', 'emoji': '👕'},
        {'value': 'shopping_electronics', 'label': 'Electrónica', 'emoji': '💻'},
        {'value': 'shopping_gifts', 'label': 'Regalos', 'emoji': '🎁'},
      ]
    },
    {
      'main': 'Ocio', 'emoji': '🎮',
      'subs': [
        {'value': 'entertainment', 'label': 'General', 'emoji': '🎮'},
        {'value': 'entertainment_movies', 'label': 'Cine', 'emoji': '🍿'},
        {'value': 'entertainment_music', 'label': 'Música', 'emoji': '🎵'},
        {'value': 'entertainment_sports', 'label': 'Deportes', 'emoji': '⚽'},
        {'value': 'entertainment_subscriptions', 'label': 'Suscripciones', 'emoji': '📺'},
      ]
    },
    {
      'main': 'Salud', 'emoji': '💊',
      'subs': [
        {'value': 'health', 'label': 'General', 'emoji': '💊'},
        {'value': 'health_doctor', 'label': 'Médico', 'emoji': '👨‍⚕️'},
        {'value': 'health_pharmacy', 'label': 'Farmacia', 'emoji': '🏥'},
        {'value': 'health_gym', 'label': 'Gimnasio', 'emoji': '🏋️'},
      ]
    },
    {
      'main': 'Hogar', 'emoji': '🏠',
      'subs': [
        {'value': 'home', 'label': 'General', 'emoji': '🏠'},
        {'value': 'home_rent', 'label': 'Alquiler / Hipoteca', 'emoji': '🏢'},
        {'value': 'home_maintenance', 'label': 'Mantenimiento', 'emoji': '🔧'},
        {'value': 'home_furniture', 'label': 'Muebles', 'emoji': '🛋️'},
      ]
    },
    {
      'main': 'Educación', 'emoji': '📚',
      'subs': [
        {'value': 'education', 'label': 'General', 'emoji': '📚'},
        {'value': 'education_tuition', 'label': 'Colegiatura', 'emoji': '🏫'},
        {'value': 'education_books', 'label': 'Libros / Material', 'emoji': '🎒'},
        {'value': 'education_courses', 'label': 'Cursos', 'emoji': '🎓'},
      ]
    },
    {
      'main': 'Otro', 'emoji': '💸',
      'subs': [
        {'value': 'other', 'label': 'General', 'emoji': '💸'},
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
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Seleccionar Categoría', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: detailedCategories.length,
                itemBuilder: (ctx, i) {
                  final mainCat = detailedCategories[i];
                  return Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Text(mainCat['emoji'], style: const TextStyle(fontSize: 24)),
                      title: Text(mainCat['main'], style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                      children: (mainCat['subs'] as List).map<Widget>((sub) {
                        return ListTile(
                          contentPadding: const EdgeInsets.only(left: 72, right: 24),
                          leading: Text(sub['emoji'], style: const TextStyle(fontSize: 20)),
                          title: Text(sub['label'], style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800])),
                          onTap: () {
                            setState(() => category = sub['value']);
                            Navigator.pop(ctx);
                          },
                        );
                      }).toList(),
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
    final loc = ref.watch(localizationProvider);
    final creditCardsAsync = ref.watch(creditCardsProvider);

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
                        child: Text(CurrencyFormatter.getSymbol(widget.currencyCode ?? ref.watch(authProvider).user?.currency), style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                  InkWell(
                    onTap: () => _showCategoryPicker(isDark),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: category.isNotEmpty 
                            ? (isDark ? const Color(0xFFDC2626).withValues(alpha: 0.1) : const Color(0xFFFEE2E2).withValues(alpha: 0.5))
                            : (isDark ? const Color(0xFF374151).withValues(alpha: 0.3) : Colors.grey[100]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: Text(_getCategoryDetails(category)['emoji']!, style: const TextStyle(fontSize: 20)),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                _getCategoryDetails(category)['label']!, 
                                style: TextStyle(
                                  color: category.isEmpty ? (isDark ? Colors.grey[500] : Colors.grey[400]) : (isDark ? Colors.white : Colors.black87), 
                                  fontSize: 16, 
                                  fontWeight: category.isEmpty ? FontWeight.normal : FontWeight.w600
                                )
                              ),
                            ],
                          ),
                          Icon(LucideIcons.chevronDown, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 20),
                        ],
                      ),
                    ),
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
                                ? const ColorScheme.dark(primary: Color(0xFFDC2626), onPrimary: Colors.white, onSurface: Colors.white)
                                : const ColorScheme.light(primary: Color(0xFFDC2626), onPrimary: Colors.white, onSurface: Colors.black),
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
                  const SizedBox(height: 20),
                  
                  // Payment Method Selector
                  Text('Método de Pago 💳', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF374151) : Colors.white,
                      border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: creditCardsAsync.when(
                        data: (cards) {
                          final items = [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Efectivo / Cuenta'),
                            ),
                            ...cards.map((card) => DropdownMenuItem<String?>(
                              value: card.id,
                              child: Text('TC: ${card.name} (${card.network})'),
                            ))
                          ];
                          return DropdownButton<String?>(
                            value: creditCardId,
                            isExpanded: true,
                            dropdownColor: isDark ? const Color(0xFF374151) : Colors.white,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                            items: items,
                            onChanged: (val) {
                              setState(() => creditCardId = val);
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const Text('Error al cargar tarjetas'),
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
                      activeColor: const Color(0xFFEF4444),
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
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;
                        
                        final parsedAmount = double.tryParse(amount) ?? 0.0;
                        if (parsedAmount <= 0) return;

                        final transaction = TransactionModel(
                          id: widget.existingTransaction?.id ?? '',
                          userId: user.uid,
                          amount: parsedAmount,
                          type: 'expense',
                          category: category,
                          description: description,
                          date: date,
                          isFixed: widget.isFixed,
                          recurrenceType: widget.isFixed ? recurrenceType : null,
                          recurrenceDay: widget.isFixed ? recurrenceDay : null,
                          recurrenceDay2: widget.isFixed ? recurrenceDay2 : null,
                          creditCardId: creditCardId,
                        );

                        // CC Limit Check
                        if (creditCardId != null) {
                          final cards = ref.read(computedCreditCardsProvider).value ?? [];
                          final selectedCard = cards.where((c) => c.id == creditCardId).firstOrNull;
                          if (selectedCard != null) {
                            final newBalance = selectedCard.currentBalance + parsedAmount;
                            if (newBalance > selectedCard.limit) {
                              final proceed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                                  title: Row(
                                    children: [
                                      const Icon(LucideIcons.alertTriangle, color: Colors.amber, size: 28),
                                      const SizedBox(width: 12),
                                      const Text('Límite Excedido'),
                                    ],
                                  ),
                                  content: Text(
                                    'Esta compra sobrepasará el límite de tu tarjeta ${selectedCard.name}.\n\n'
                                    'Límite: ${CurrencyFormatter.getSymbol(ref.read(authProvider).user?.currency)}${selectedCard.limit.toStringAsFixed(2)}\n'
                                    'Nuevo balance: ${CurrencyFormatter.getSymbol(ref.read(authProvider).user?.currency)}${newBalance.toStringAsFixed(2)}\n\n'
                                    '¿Deseas continuar y sobregirar la tarjeta?',
                                    style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800]),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
                                      child: const Text('Sí, Continuar'),
                                    ),
                                  ],
                                ),
                              );
                              if (proceed != true) return;
                            }
                          }
                        }

                        if (widget.existingTransaction != null) {
                          await ref.read(transactionNotifierProvider.notifier).updateTransaction(transaction);
                        } else {
                          await ref.read(transactionNotifierProvider.notifier).addTransaction(transaction);
                        }

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(widget.existingTransaction != null ? 'Gasto actualizado' : loc.get('expense_added'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
