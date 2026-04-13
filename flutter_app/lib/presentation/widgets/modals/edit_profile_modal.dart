import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'avatar_selector_modal.dart';

class EditProfileModal extends StatefulWidget {
  const EditProfileModal({super.key});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  String name = 'Usuario Creador';
  String email = 'creador@finanzas.com';
  String selectedAvatar = '👤';
  String activeSection = 'expenses'; // 'expenses' | 'debts'

  // Fixed Expenses
  final List<Map<String, String>> fixedExpenses = [
    {'id': '1', 'name': 'Renta', 'amount': '5000', 'category': '🏠'},
    {'id': '2', 'name': 'Internet', 'amount': '500', 'category': '📱'},
  ];
  String newExpenseName = '';
  String newExpenseAmount = '';
  String newExpenseCategory = '🏠';

  // Debts
  final List<Map<String, String>> debts = [
    {'id': '1', 'name': 'Laptop', 'installmentAmount': '1500', 'totalInstallments': '12', 'paidInstallments': '5', 'category': '💻'},
    {'id': '2', 'name': 'Préstamo Personal', 'installmentAmount': '3000', 'totalInstallments': '24', 'paidInstallments': '8', 'category': '🏦'},
  ];
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
    if (newExpenseName.isEmpty || newExpenseAmount.isEmpty) return;
    setState(() {
      fixedExpenses.add({
        'id': DateTime.now().toString(),
        'name': newExpenseName,
        'amount': newExpenseAmount,
        'category': newExpenseCategory,
      });
      newExpenseName = '';
      newExpenseAmount = '';
      newExpenseCategory = '🏠';
    });
  }

  void _handleAddDebt() {
    if (newDebtName.isEmpty || newDebtInstallment.isEmpty || newDebtTotal.isEmpty) return;
    setState(() {
      debts.add({
        'id': DateTime.now().toString(),
        'name': newDebtName,
        'installmentAmount': newDebtInstallment,
        'totalInstallments': newDebtTotal,
        'paidInstallments': newDebtPaid.isEmpty ? '0' : newDebtPaid,
        'category': newDebtCategory,
      });
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
      final idx = debts.indexWhere((d) => d['id'] == debtId);
      if (idx != -1) {
        final debt = debts[idx];
        final paid = double.tryParse(debt['paidInstallments'] ?? '0') ?? 0;
        final total = double.tryParse(debt['totalInstallments'] ?? '0') ?? 0;
        if (paid < total) {
          debts[idx] = {...debt, 'paidInstallments': (paid + 1).toString()};
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

    double totalFixed = fixedExpenses.fold(0, (sum, exp) => sum + (double.tryParse(exp['amount'] ?? '0') ?? 0));
    double totalDebtPending = debts.fold(0, (sum, d) {
      final total = double.tryParse(d['totalInstallments'] ?? '0') ?? 0;
      final paid = double.tryParse(d['paidInstallments'] ?? '0') ?? 0;
      final amount = double.tryParse(d['installmentAmount'] ?? '0') ?? 0;
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
                    initialValue: name,
                    onChanged: (v) => name = v,
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
                    initialValue: email,
                    onChanged: (v) => email = v,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(LucideIcons.mail, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tabs section
                  Text('Gastos Fijos y Deudas 💰', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
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
                              child: Text('📋 Gastos Fijos', style: TextStyle(color: activeSection == 'expenses' ? (isDark ? Colors.white : const Color(0xFF4338CA)) : (isDark ? Colors.grey[400] : Colors.grey[500]), fontSize: 14)),
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
                              child: Text('🏦 Deudas', style: TextStyle(color: activeSection == 'debts' ? (isDark ? Colors.white : const Color(0xFF4338CA)) : (isDark ? Colors.grey[400] : Colors.grey[500]), fontSize: 14)),
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
                          Text(expense['category']!, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(expense['name']!, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                                Text('\$${expense['amount']}', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 16),
                            color: isDark ? Colors.red[400] : Colors.red[600],
                            onPressed: () => setState(() => fixedExpenses.removeWhere((e) => e['id'] == expense['id'])),
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
                          ElevatedButton.icon(
                            onPressed: _handleAddExpense,
                            icon: const Icon(LucideIcons.plus, size: 16),
                            label: const Text('Agregar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFF4338CA) : const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(double.infinity, 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                      final total = double.tryParse(debt['totalInstallments'] ?? '0') ?? 0;
                      final paid = double.tryParse(debt['paidInstallments'] ?? '0') ?? 0;
                      final progress = total > 0 ? (paid / total) : 0.0;
                      final amount = double.tryParse(debt['installmentAmount'] ?? '0') ?? 0;
                      final remaining = (total - paid) * amount;
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
                                Text(debt['category']!, style: const TextStyle(fontSize: 24)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${debt['name']!} ${isFullyPaid ? '✅' : ''}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                                      Text('\$${debt['installmentAmount']}/cuota · ${paid.toInt()}/${total.toInt()} pagadas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
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
                                  onPressed: () => setState(() => debts.removeWhere((d) => d['id'] == debt['id'])),
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
                                    onTap: () => _handleAdvancePayment(debt['id']!),
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
                    }).toList(),
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
                          ElevatedButton.icon(
                            onPressed: _handleAddDebt,
                            icon: const Icon(LucideIcons.plus, size: 16),
                            label: const Text('Agregar Deuda'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFF4338CA) : const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(double.infinity, 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                      return Ink(
                        decoration: BoxDecoration(
                          gradient: isDark 
                              ? const LinearGradient(colors: [Color(0xFF4338CA), Color(0xFF047857)]) 
                              : const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF10B981)]),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado correctamente')));
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
}
