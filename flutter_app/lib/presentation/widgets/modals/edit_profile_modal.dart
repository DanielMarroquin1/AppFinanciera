import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import '../../providers/debts_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../../domain/entities/debt.dart';
import '../../../domain/entities/transaction.dart';
import 'avatar_selector_modal.dart';

class EditProfileModal extends ConsumerStatefulWidget {
  const EditProfileModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditProfileModal(),
    );
  }

  @override
  ConsumerState<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends ConsumerState<EditProfileModal> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String selectedAvatar = '👤';
  String activeSection = 'expenses'; // 'expenses' | 'income' | 'debts'

  @override
  void initState() {
    super.initState();
    // Microtask to read provider
    Future.microtask(() {
      final user = ref.read(authProvider).user;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (user != null && uid != null && mounted) {
        nameController.text = user.name.isNotEmpty ? user.name : '';
        emailController.text = user.email;

        // Load fixed expenses
        ref.read(transactionRepositoryProvider).watchTransactions(uid).first.then((transactions) {
          if (mounted) {
            setState(() {
              fixedExpenses = transactions.where((t) => t.isFixed && t.type == 'expense').toList();
              fixedIncomes = transactions.where((t) => t.isFixed && t.type == 'income').toList();
            });
          }
        });

        // Load debts
        ref.read(debtRepositoryProvider).watchDebts(uid).first.then((loadedDebts) {
          if (mounted) setState(() => debts = loadedDebts);
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // Fixed Expenses
  List<TransactionModel> fixedExpenses = [];
  String newExpenseName = '';
  String newExpenseAmount = '';
  String newExpenseCategory = '🏠';

  // Fixed Incomes
  List<TransactionModel> fixedIncomes = [];
  String newIncomeName = '';
  String newIncomeAmount = '';
  String newIncomeCategory = '💼';
  String? newIncomeRecurrenceType = 'monthly';
  int newIncomeRecurrenceDay = 15;
  int newIncomeRecurrenceDay2 = 30;

  // Fixed expense recurrence
  String? newExpenseRecurrenceType = 'monthly';
  int newExpenseRecurrenceDay = 1;

  // Debts
  List<DebtModel> debts = [];
  String newDebtName = '';
  String newDebtInstallment = '';
  String newDebtTotal = '';
  String newDebtPaid = '';
  String newDebtCategory = '🏦';
  String? editingDebtId;

  final categories = [
    {'emoji': '🏠', 'label': 'Vivienda'},
    {'emoji': '📱', 'label': 'Servicios'},
    {'emoji': '🚗', 'label': 'Transporte'},
    {'emoji': '🍔', 'label': 'Comida'},
    {'emoji': '💊', 'label': 'Salud'},
    {'emoji': '📚', 'label': 'Educación'},
    {'emoji': '🎮', 'label': 'Suscripciones'},
    {'emoji': '💸', 'label': 'Otro'},
  ];

  final incomeCategories = [
    {'emoji': '💼', 'label': 'Salario'},
    {'emoji': '💻', 'label': 'Freelance'},
    {'emoji': '🏢', 'label': 'Empresa'},
    {'emoji': '📈', 'label': 'Inversiones'},
    {'emoji': '🏠', 'label': 'Renta'},
    {'emoji': '🎁', 'label': 'Bono'},
    {'emoji': '📚', 'label': 'Educación'},
    {'emoji': '💰', 'label': 'Otro'},
  ];

  final debtCategories = [
    {'emoji': '🏦', 'label': 'Banco'},
    {'emoji': '💳', 'label': 'Tarjeta'},
    {'emoji': '🏠', 'label': 'Hipoteca'},
    {'emoji': '🚗', 'label': 'Vehículo'},
    {'emoji': '💻', 'label': 'Electrónica'},
    {'emoji': '📱', 'label': 'Dispositivo'},
    {'emoji': '📚', 'label': 'Educación'},
    {'emoji': '💸', 'label': 'Otro'},
  ];

  void _handleAddExpense() {
    final amount = double.tryParse(newExpenseAmount);
    if (newExpenseName.isEmpty || amount == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      fixedExpenses.add(TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: uid,
        amount: amount,
        type: 'expense',
        category: newExpenseCategory,
        description: newExpenseName,
        date: DateTime.now(),
        isFixed: true,
        recurrenceType: newExpenseRecurrenceType,
        recurrenceDay: newExpenseRecurrenceDay,
      ));
      newExpenseName = '';
      newExpenseAmount = '';
      newExpenseCategory = '🏠';
      newExpenseRecurrenceType = 'monthly';
      newExpenseRecurrenceDay = 1;
    });
  }

  void _handleAddIncome() {
    final amount = double.tryParse(newIncomeAmount);
    if (newIncomeName.isEmpty || amount == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      fixedIncomes.add(TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: uid,
        amount: amount,
        type: 'income',
        category: newIncomeCategory,
        description: newIncomeName,
        date: DateTime.now(),
        isFixed: true,
        recurrenceType: newIncomeRecurrenceType,
        recurrenceDay: newIncomeRecurrenceDay,
        recurrenceDay2: newIncomeRecurrenceType == 'bimonthly' ? newIncomeRecurrenceDay2 : null,
      ));
      newIncomeName = '';
      newIncomeAmount = '';
      newIncomeCategory = '💼';
      newIncomeRecurrenceType = 'monthly';
      newIncomeRecurrenceDay = 15;
      newIncomeRecurrenceDay2 = 30;
    });
  }

  void _handleAddDebt() {
    final amount = double.tryParse(newDebtInstallment);
    final total = int.tryParse(newDebtTotal);
    final paid = int.tryParse(newDebtPaid) ?? 0;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (newDebtName.isEmpty || amount == null || total == null || uid == null) return;

    setState(() {
      debts.add(DebtModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: uid,
        name: newDebtName,
        installmentAmount: amount,
        totalInstallments: total,
        paidInstallments: paid,
        category: newDebtCategory,
        createdAt: DateTime.now(),
      ));
      newDebtName = '';
      newDebtInstallment = '';
      newDebtTotal = '';
      newDebtPaid = '';
      newDebtCategory = '🏦';
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deuda agregada correctamente')));
  }

  void _handleAdvancePayment(String debtId) {
    setState(() {
      final idx = debts.indexWhere((d) => d.id == debtId);
      if (idx != -1) {
        final debt = debts[idx];
        final paid = debt.paidInstallments;
        final total = debt.totalInstallments;
        if (paid < total) {
          debts[idx] = debt.copyWith(paidInstallments: paid + 1);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('¡Cuota #${paid + 1} registrada! 🎉')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Esta deuda ya está completamente pagada! 🎊')));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double totalFixed = fixedExpenses.fold(0, (sum, exp) => sum + exp.amount);
    double totalDebtPending = debts.fold(0, (sum, d) {
      final total = d.totalInstallments;
      final paid = d.paidInstallments;
      final amount = d.installmentAmount;
      return sum + ((total - paid) * amount);
    });

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(colors: [Color(0xFF3730A3), Color(0xFF047857)]) // indigo-800 to emerald-700
                  : const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF10B981)]), // indigo-600 to emerald-500
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(LucideIcons.user, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Editar Perfil', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Actualiza tu información personal', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar section
                  Text('Avatar 🎭', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final val = await showDialog<String>(
                        context: context,
                        builder: (context) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(16),
                          child: AvatarSelectorModal(currentAvatar: selectedAvatar, isPremiumUser: false),
                        ),
                      );
                      if (val != null) setState(() => selectedAvatar = val);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151) : Colors.white,
                        border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              gradient: isDark 
                                  ? const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF064E3B)]) 
                                  : const LinearGradient(colors: [Color(0xFFE0E7FF), Color(0xFFD1FAE5)]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(selectedAvatar, style: const TextStyle(fontSize: 32)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cambiar Avatar', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                                Text('Toca para ver todos los avatares disponibles', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          Icon(LucideIcons.chevronRight, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Info
                  Text('Información Personal', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 12),
                  Text('Nombre', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)), // indigo-500
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Correo Electrónico', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    readOnly: true, // Correo is usually non-editable directly from here unless auth changes
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(LucideIcons.mail, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tabs section
                  Text('Gastos Fijos, Ingresos y Deudas 💰', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => activeSection = 'expenses'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: activeSection == 'expenses' ? (isDark ? const Color(0xFF4338CA) : Colors.white) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: activeSection == 'expenses' 
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text('📋 Gastos', style: TextStyle(color: activeSection == 'expenses' ? (isDark ? Colors.white : const Color(0xFF4338CA)) : (isDark ? Colors.grey[400] : Colors.grey[500]), fontSize: 13)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => activeSection = 'income'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: activeSection == 'income' ? (isDark ? const Color(0xFF047857) : Colors.white) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: activeSection == 'income' 
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text('💰 Ingresos', style: TextStyle(color: activeSection == 'income' ? (isDark ? Colors.white : const Color(0xFF047857)) : (isDark ? Colors.grey[400] : Colors.grey[500]), fontSize: 13)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => activeSection = 'debts'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: activeSection == 'debts' ? (isDark ? const Color(0xFF4338CA) : Colors.white) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: activeSection == 'debts' 
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text('🏦 Deudas', style: TextStyle(color: activeSection == 'debts' ? (isDark ? Colors.white : const Color(0xFF4338CA)) : (isDark ? Colors.grey[400] : Colors.grey[500]), fontSize: 13)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Content Details depending on tab
                  if (activeSection == 'expenses') ...[
                    // Expenses Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF312E81).withValues(alpha: 0.3) : const Color(0xFFEEF2FF),
                        border: Border.all(color: isDark ? const Color(0xFF3730A3) : const Color(0xFFC7D2FE), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total de Gastos Fijos', style: TextStyle(color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA), fontSize: 12)),
                          Text('\$${totalFixed.toStringAsFixed(2)}', style: TextStyle(color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5), fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ...fixedExpenses.map((expense) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151) : Colors.white,
                        border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(expense.category, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(expense.description, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                                Text('\$${expense.amount.toStringAsFixed(2)}', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 16),
                            color: isDark ? Colors.red[400] : Colors.red[600],
                            onPressed: () => setState(() => fixedExpenses.removeWhere((e) => e.id == expense.id)),
                          )
                        ],
                      ),
                    )),
                    const SizedBox(height: 8),

                    // Add Exp form
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151).withValues(alpha: 0.5) : const Color(0xFFF9FAFB),
                        border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Agregar Gasto Fijo', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: categories.map((cat) => GestureDetector(
                              onTap: () => setState(() => newExpenseCategory = cat['emoji']!),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: newExpenseCategory == cat['emoji']! 
                                      ? (isDark ? const Color(0xFF312E81).withValues(alpha: 0.5) : const Color(0xFFE0E7FF))
                                      : (isDark ? const Color(0xFF4B5563) : Colors.white),
                                  border: Border.all(
                                    color: newExpenseCategory == cat['emoji']!
                                        ? (isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1))
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(cat['emoji']!, style: const TextStyle(fontSize: 20)),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            onChanged: (v) => newExpenseName = v, // Note: minimal state handling to save time as UI clone
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Nombre del gasto',
                              hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[400]),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF4B5563) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (v) => newExpenseAmount = v,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[400]),
                              prefixIcon: Icon(LucideIcons.dollarSign, color: isDark ? Colors.grey[400] : Colors.grey[500], size: 16),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF4B5563) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Ink(
                            decoration: BoxDecoration(
                              gradient: isDark 
                                  ? const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)]) 
                                  : const LinearGradient(colors: [Color(0xFF6EE7B7), Color(0xFF10B981)]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              onTap: _handleAddExpense,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.plus, size: 16, color: Colors.black),
                                    SizedBox(width: 8),
                                    Text('Agregar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],

                  if (activeSection == 'income') ...[
                    // Income Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5),
                        border: Border.all(color: isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total de Ingresos Fijos', style: TextStyle(color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857), fontSize: 12)),
                          Text('\$${fixedIncomes.fold(0.0, (sum, inc) => sum + inc.amount).toStringAsFixed(2)}', style: TextStyle(color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669), fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ...fixedIncomes.map((income) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151) : Colors.white,
                        border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(income.category, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(income.description, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                                Text('\$${income.amount.toStringAsFixed(2)}', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                                if (income.recurrenceType != null)
                                  Text(income.recurrenceLabel, style: TextStyle(color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669), fontSize: 11)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 16),
                            color: isDark ? Colors.red[400] : Colors.red[600],
                            onPressed: () => setState(() => fixedIncomes.removeWhere((e) => e.id == income.id)),
                          )
                        ],
                      ),
                    )),
                    const SizedBox(height: 8),

                    // Add Income form
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151).withValues(alpha: 0.5) : const Color(0xFFF9FAFB),
                        border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Agregar Ingreso Fijo', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: incomeCategories.map((cat) => GestureDetector(
                              onTap: () => setState(() => newIncomeCategory = cat['emoji']!),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: newIncomeCategory == cat['emoji']! 
                                      ? (isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFD1FAE5))
                                      : (isDark ? const Color(0xFF4B5563) : Colors.white),
                                  border: Border.all(
                                    color: newIncomeCategory == cat['emoji']!
                                        ? (isDark ? const Color(0xFF059669) : const Color(0xFF10B981))
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(cat['emoji']!, style: const TextStyle(fontSize: 20)),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            onChanged: (v) => newIncomeName = v,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Nombre del ingreso (ej: Salario)',
                              hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[400]),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF4B5563) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (v) => newIncomeAmount = v,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[400]),
                              prefixIcon: Icon(LucideIcons.dollarSign, color: isDark ? Colors.grey[400] : Colors.grey[500], size: 16),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF4B5563) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Recurrence selector
                          Text('Recurrencia', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildRecurrenceChip(isDark, 'monthly', '📅 Mensual'),
                              const SizedBox(width: 6),
                              _buildRecurrenceChip(isDark, 'bimonthly', '📆 Quincenal'),
                              const SizedBox(width: 6),
                              _buildRecurrenceChip(isDark, 'weekly', '🗓️ Semanal'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Day selector
                          if (newIncomeRecurrenceType == 'monthly')
                            Row(
                              children: [
                                Icon(LucideIcons.calendar, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                                const SizedBox(width: 8),
                                Text('Día de pago: ', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                                SizedBox(
                                  width: 60,
                                  child: DropdownButton<int>(
                                    value: newIncomeRecurrenceDay.clamp(1, 31),
                                    isExpanded: true,
                                    dropdownColor: isDark ? const Color(0xFF374151) : Colors.white,
                                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                                    underline: Container(height: 1, color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
                                    items: List.generate(31, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                                    onChanged: (val) => setState(() => newIncomeRecurrenceDay = val ?? 1),
                                  ),
                                ),
                              ],
                            ),
                          if (newIncomeRecurrenceType == 'bimonthly')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Se divide el monto total en 2 pagos:', style: TextStyle(color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669), fontSize: 11)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(LucideIcons.calendar, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                                    const SizedBox(width: 8),
                                    Text('1er pago día: ', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                                    SizedBox(
                                      width: 60,
                                      child: DropdownButton<int>(
                                        value: newIncomeRecurrenceDay.clamp(1, 31),
                                        isExpanded: true,
                                        dropdownColor: isDark ? const Color(0xFF374151) : Colors.white,
                                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                                        underline: Container(height: 1, color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
                                        items: List.generate(31, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                                        onChanged: (val) => setState(() => newIncomeRecurrenceDay = val ?? 1),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(LucideIcons.calendar, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                                    const SizedBox(width: 8),
                                    Text('2do pago día: ', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                                    SizedBox(
                                      width: 60,
                                      child: DropdownButton<int>(
                                        value: newIncomeRecurrenceDay2.clamp(1, 31),
                                        isExpanded: true,
                                        dropdownColor: isDark ? const Color(0xFF374151) : Colors.white,
                                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                                        underline: Container(height: 1, color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
                                        items: List.generate(31, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                                        onChanged: (val) => setState(() => newIncomeRecurrenceDay2 = val ?? 30),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          if (newIncomeRecurrenceType == 'weekly')
                            Row(
                              children: [
                                Icon(LucideIcons.calendar, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                                const SizedBox(width: 8),
                                Text('Día: ', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13)),
                                ...['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'].asMap().entries.map((e) {
                                  final dayNum = e.key + 1;
                                  final isSelected = newIncomeRecurrenceDay == dayNum;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: GestureDetector(
                                      onTap: () => setState(() => newIncomeRecurrenceDay = dayNum),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSelected ? (isDark ? const Color(0xFF047857) : const Color(0xFFD1FAE5)) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: isSelected ? (isDark ? const Color(0xFF059669) : const Color(0xFF10B981)) : (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB))),
                                        ),
                                        child: Text(e.value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 11)),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Ink(
                            decoration: BoxDecoration(
                              gradient: isDark 
                                  ? const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)]) 
                                  : const LinearGradient(colors: [Color(0xFF6EE7B7), Color(0xFF10B981)]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              onTap: _handleAddIncome,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.plus, size: 16, color: Colors.black),
                                    SizedBox(width: 8),
                                    Text('Agregar Ingreso', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],

                  if (activeSection == 'debts') ...[
                    // Debts Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF881337).withValues(alpha: 0.3) : const Color(0xFFFFF1F2),
                        border: Border.all(color: isDark ? const Color(0xFF9F1239) : const Color(0xFFFECDD3), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Deuda Total Pendiente', style: TextStyle(color: isDark ? const Color(0xFFFDA4AF) : const Color(0xFFBE123C), fontSize: 12)),
                          Text('\$${totalDebtPending.toStringAsFixed(2)}', style: TextStyle(color: isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48), fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('${debts.length} deudas registradas', style: TextStyle(color: isDark ? const Color(0xFFFB7185).withValues(alpha: 0.7) : const Color(0xFFE11D48).withValues(alpha: 0.7), fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...debts.map((debt) {
                      final total = debt.totalInstallments;
                      final paid = debt.paidInstallments;
                      final progress = total > 0 ? (paid / total) : 0.0;
                      final remaining = (total - paid) * debt.installmentAmount;
                      final isFullyPaid = paid >= total;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF374151) : Colors.white,
                          border: Border.all(color: isFullyPaid ? (isDark ? const Color(0xFF047857) : const Color(0xFF6EE7B7)) : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(debt.category, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${debt.name} ${isFullyPaid ? '✅' : ''}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                                      Text('\$${debt.installmentAmount.toStringAsFixed(0)}/cuota · $paid/$total pagadas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.pencil, size: 14),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  iconSize: 14,
                                  color: isDark ? Colors.grey[400] : Colors.grey[400],
                                  onPressed: () {}, // Simulating edit
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 14),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  iconSize: 14,
                                  color: isDark ? Colors.red[400] : Colors.red[500],
                                  onPressed: () => setState(() => debts.removeWhere((d) => d.id == debt.id)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress.clamp(0.0, 1.0),
                                backgroundColor: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress >= 1.0 ? Colors.green : (progress >= 0.5 ? Colors.indigo : Colors.amber)
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(isFullyPaid ? '¡Deuda pagada! 🎉' : 'Faltan \$${remaining.toStringAsFixed(0)}', style: TextStyle(color: isFullyPaid ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDark ? const Color(0xFFFB7185) : const Color(0xFFE11D48)), fontSize: 12)),
                                if (!isFullyPaid)
                                  GestureDetector(
                                    onTap: () => _handleAdvancePayment(debt.id),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(LucideIcons.chevronUp, size: 12, color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857)),
                                          const SizedBox(width: 4),
                                          Text('+1 Cuota', style: TextStyle(color: isDark ? const Color(0xFF34D399) : const Color(0xFF047857), fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            )
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),

                    // Add Debt Form
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151).withValues(alpha: 0.5) : const Color(0xFFF9FAFB),
                        border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Agregar Deuda', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: debtCategories.map((cat) => GestureDetector(
                              onTap: () => setState(() => newDebtCategory = cat['emoji']!),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: newDebtCategory == cat['emoji']! 
                                      ? (isDark ? const Color(0xFF312E81).withValues(alpha: 0.5) : const Color(0xFFE0E7FF))
                                      : (isDark ? const Color(0xFF4B5563) : Colors.white),
                                  border: Border.all(
                                    color: newDebtCategory == cat['emoji']!
                                        ? (isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1))
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(cat['emoji']!, style: const TextStyle(fontSize: 20)),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            onChanged: (v) => newDebtName = v, 
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Nombre de la deuda',
                              hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[400]),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF4B5563) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (v) => newDebtInstallment = v,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Monto por cuota',
                              prefixIcon: Icon(LucideIcons.dollarSign, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                              hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[400]),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF4B5563) : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (v) => newDebtTotal = v,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Cuotas totales',
                                    prefixIcon: Icon(LucideIcons.hash, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                                    hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[400]),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF4B5563) : Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  onChanged: (v) => newDebtPaid = v,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Ya pagadas',
                                    prefixIcon: Icon(LucideIcons.check, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                                    hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[400]),
                                    filled: true,
                                    fillColor: isDark ? const Color(0xFF4B5563) : Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB), width: 2)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Ink(
                            decoration: BoxDecoration(
                              gradient: isDark 
                                  ? const LinearGradient(colors: [Color(0xFF4338CA), Color(0xFF4F46E5)]) 
                                  : const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              onTap: _handleAddDebt,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                alignment: Alignment.center,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.plus, size: 16, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Agregar Deuda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Save Button
                  Builder(
                    builder: (context) {
                      final isLoading = ref.watch(authProvider).isLoading;
                      return Ink(
                        decoration: BoxDecoration(
                          gradient: isDark 
                              ? const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)]) 
                              : const LinearGradient(colors: [Color(0xFF6EE7B7), Color(0xFF10B981)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? const Color(0xFF059669) : const Color(0xFF10B981)).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: isLoading ? null : () async {
                            final user = ref.read(authProvider).user;
                            if (user != null) {
                              final currentName = nameController.text.trim();
                              final updatedUser = user.copyWith(
                                name: currentName.isEmpty ? 'Usuario' : currentName,
                                profileComplete: true,
                              );
                              await ref.read(authProvider.notifier).updateProfile(updatedUser);

                              // Save Fixed Expenses
                              final transactionNotifier = ref.read(transactionNotifierProvider.notifier);
                              for (var expense in fixedExpenses) {
                                final isLocal = int.tryParse(expense.id) != null;
                                if (isLocal) {
                                  await transactionNotifier.addTransaction(expense);
                                }
                              }

                              // Save Fixed Incomes
                              for (var income in fixedIncomes) {
                                final isLocal = int.tryParse(income.id) != null;
                                if (isLocal) {
                                  await transactionNotifier.addTransaction(income);
                                }
                              }

                              // Save Debts
                              final debtNotifier = ref.read(debtNotifierProvider.notifier);
                              for (var debt in debts) {
                                final isLocal = int.tryParse(debt.id) != null;
                                if (isLocal) {
                                  await debtNotifier.addDebt(debt);
                                }
                              }

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado correctamente')));
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                : const Text('Guardar Cambios', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurrenceChip(bool isDark, String type, String label) {
    final isSelected = newIncomeRecurrenceType == type;
    return GestureDetector(
      onTap: () => setState(() {
        newIncomeRecurrenceType = type;
        if (type == 'weekly') newIncomeRecurrenceDay = 1;
        if (type == 'monthly' || type == 'bimonthly') newIncomeRecurrenceDay = newIncomeRecurrenceDay.clamp(1, 31);
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF047857) : const Color(0xFFD1FAE5))
              : (isDark ? const Color(0xFF4B5563) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFF059669) : const Color(0xFF10B981))
                : (isDark ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB)),
            width: 2,
          ),
        ),
        child: Text(label, style: TextStyle(
          color: isSelected
              ? (isDark ? Colors.white : const Color(0xFF047857))
              : (isDark ? Colors.grey[400] : Colors.grey[600]),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        )),
      ),
    );
  }
}
