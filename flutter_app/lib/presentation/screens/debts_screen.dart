import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Debt {
  final String id;
  final String name;
  final String emoji;
  final double installmentAmount;
  final int totalInstallments;
  int paidInstallments;
  final List<Color> colors;

  Debt({
    required this.id,
    required this.name,
    required this.emoji,
    required this.installmentAmount,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.colors,
  });

  double get totalAmount => installmentAmount * totalInstallments;
  double get paidAmount => installmentAmount * paidInstallments;
  double get remainingAmount => installmentAmount * (totalInstallments - paidInstallments);
  double get progress => totalInstallments > 0 ? paidInstallments / totalInstallments : 0;
  bool get isCompleted => paidInstallments >= totalInstallments;
}

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  final List<Debt> _debts = [
    Debt(
      id: '1', name: 'Laptop HP', emoji: '💻',
      installmentAmount: 1500, totalInstallments: 12, paidInstallments: 5,
      colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
    ),
    Debt(
      id: '2', name: 'Préstamo Personal', emoji: '🏦',
      installmentAmount: 3000, totalInstallments: 24, paidInstallments: 8,
      colors: [const Color(0xFF0EA5E9), const Color(0xFF06B6D4)],
    ),
    Debt(
      id: '3', name: 'Celular iPhone', emoji: '📱',
      installmentAmount: 800, totalInstallments: 6, paidInstallments: 4,
      colors: [const Color(0xFF10B981), const Color(0xFF059669)],
    ),
    Debt(
      id: '4', name: 'Televisor 55"', emoji: '📺',
      installmentAmount: 650, totalInstallments: 18, paidInstallments: 18,
      colors: [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
    ),
  ];

  void _registerPayment(Debt debt) {
    if (debt.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Esta deuda ya está completamente pagada! 🎊'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Icon(LucideIcons.checkCircle, color: Color(0xFF10B981), size: 32)),
                ),
                const SizedBox(height: 16),
                Text('¿Registrar pago?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 8),
                Text(
                  'Cuota #${debt.paidInstallments + 1} de ${debt.name}',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text('\$${debt.installmentAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669))),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        ),
                        child: Text('Cancelar', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          setState(() {
                            debt.paidInstallments++;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('¡Cuota #${debt.paidInstallments} de ${debt.name} registrada! 🎉'),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('✓ Confirmar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddDebtModal() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final paidCtrl = TextEditingController(text: '0');
    String selectedEmoji = '🏦';

    final emojis = ['🏦', '💳', '🏠', '🚗', '💻', '📱', '📺', '🎓', '💊', '✈️'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Nueva Deuda', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    const SizedBox(height: 4),
                    Text('Registra una compra a cuotas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                    const SizedBox(height: 24),

                    // Emoji selector
                    Text('Categoría', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: emojis.map((e) {
                        final isSelected = selectedEmoji == e;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedEmoji = e),
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF))
                                  : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                              border: isSelected ? Border.all(color: const Color(0xFF6366F1), width: 2) : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Name
                    _buildInputField(isDark, nameCtrl, 'Nombre de la deuda', LucideIcons.creditCard, TextInputType.text),
                    const SizedBox(height: 12),

                    // Amount per installment
                    _buildInputField(isDark, amountCtrl, 'Monto por cuota', LucideIcons.dollarSign, TextInputType.number),
                    const SizedBox(height: 12),

                    // Total installments
                    Row(
                      children: [
                        Expanded(child: _buildInputField(isDark, totalCtrl, 'Cuotas totales', LucideIcons.hash, TextInputType.number)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInputField(isDark, paidCtrl, 'Ya pagadas', LucideIcons.check, TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameCtrl.text.isEmpty || amountCtrl.text.isEmpty || totalCtrl.text.isEmpty) return;
                          final newDebt = Debt(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: nameCtrl.text,
                            emoji: selectedEmoji,
                            installmentAmount: double.tryParse(amountCtrl.text) ?? 0,
                            totalInstallments: int.tryParse(totalCtrl.text) ?? 0,
                            paidInstallments: int.tryParse(paidCtrl.text) ?? 0,
                            colors: [const Color(0xFF6366F1), const Color(0xFF10B981)],
                          );
                          setState(() => _debts.add(newDebt));
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${newDebt.name} agregada ✅'),
                              backgroundColor: const Color(0xFF6366F1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('+ Agregar Deuda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField(bool isDark, TextEditingController ctrl, String hint, IconData icon, TextInputType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: type,
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeDebts = _debts.where((d) => !d.isCompleted).toList();
    final completedDebts = _debts.where((d) => d.isCompleted).toList();
    final totalRemaining = _debts.fold(0.0, (sum, d) => sum + d.remainingAmount);
    final totalPaidInstallments = _debts.fold(0, (sum, d) => sum + d.paidInstallments);
    final totalAllInstallments = _debts.fold(0, (sum, d) => sum + d.totalInstallments);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text('Mis Deudas 💳', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 4),
            Text('Control de pagos a cuotas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(height: 24),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF7F1D1D), const Color(0xFF831843)]
                      : [const Color(0xFFF43F5E), const Color(0xFFDB2777)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Deuda Total Pendiente', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('\$${totalRemaining.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text('$totalPaidInstallments/$totalAllInstallments', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('cuotas', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Overall progress bar
                  Container(
                    height: 8, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: totalAllInstallments > 0 ? (totalPaidInstallments / totalAllInstallments).clamp(0.0, 1.0) : 0,
                      child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${activeDebts.length} deuda${activeDebts.length != 1 ? 's' : ''} activa${activeDebts.length != 1 ? 's' : ''} · ${completedDebts.length} completada${completedDebts.length != 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Add Debt Button
            InkWell(
              onTap: _showAddDebtModal,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.plus, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text('Agregar Nueva Deuda', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Active Debts
            if (activeDebts.isNotEmpty) ...[
              Text('Deudas Activas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
              const SizedBox(height: 12),
              ...activeDebts.map((debt) => _buildDebtCard(debt, isDark)),
            ],

            // Completed
            if (completedDebts.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Deudas Completadas ✅', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
              const SizedBox(height: 12),
              ...completedDebts.map((debt) => _buildDebtCard(debt, isDark)),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDebtCard(Debt debt, bool isDark) {
    final percentage = (debt.progress * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        border: Border.all(
          color: debt.isCompleted
              ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFA7F3D0))
              : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
          width: debt.isCompleted ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: debt.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(debt.emoji, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            debt.name,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (debt.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('Pagado', style: TextStyle(color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${debt.installmentAmount.toStringAsFixed(0)}/cuota · ${debt.paidInstallments}/${debt.totalInstallments} pagadas',
                      style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 10, width: double.infinity,
            decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: debt.progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: debt.isCompleted ? [const Color(0xFF10B981), const Color(0xFF059669)] : debt.colors),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bottom row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$percentage% completado', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    debt.isCompleted
                        ? '¡Deuda pagada! 🎉'
                        : 'Faltan \$${debt.remainingAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: debt.isCompleted
                          ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                          : (isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626)),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (!debt.isCompleted)
                ElevatedButton.icon(
                  onPressed: () => _registerPayment(debt),
                  icon: const Icon(LucideIcons.chevronUp, size: 16),
                  label: const Text('+1 Cuota', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                    foregroundColor: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
            ],
          ),

          // Detail summary (expandable info)
          if (!debt.isCompleted) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildDetailChip(isDark, 'Total', '\$${debt.totalAmount.toStringAsFixed(0)}'),
                  const SizedBox(width: 8),
                  _buildDetailChip(isDark, 'Pagado', '\$${debt.paidAmount.toStringAsFixed(0)}'),
                  const SizedBox(width: 8),
                  _buildDetailChip(isDark, 'Restante', '\$${debt.remainingAmount.toStringAsFixed(0)}'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip(bool isDark, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
