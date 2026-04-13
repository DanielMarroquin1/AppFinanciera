import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddIncomeModal extends StatefulWidget {
  const AddIncomeModal({super.key});

  @override
  State<AddIncomeModal> createState() => _AddIncomeModalState();
}

class _AddIncomeModalState extends State<AddIncomeModal> {
  String amount = "";
  String category = "";
  String description = "";
  DateTime date = DateTime.now();

  final incomeCategories = [
    {'value': 'salary', 'label': 'Salario', 'emoji': '💼'},
    {'value': 'freelance', 'label': 'Freelance', 'emoji': '💻'},
    {'value': 'bonus', 'label': 'Bonificación', 'emoji': '🎁'},
    {'value': 'investment', 'label': 'Inversión', 'emoji': '📈'},
    {'value': 'sale', 'label': 'Venta', 'emoji': '🏷️'},
    {'value': 'gift', 'label': 'Regalo', 'emoji': '🎉'},
    {'value': 'other', 'label': 'Otro', 'emoji': '💰'},
  ];

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
                          child: const Icon(LucideIcons.trendingUp, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Text('Nuevo Ingreso', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text('Registra tus ingresos para llevar un mejor control', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) => amount = val,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      prefixIcon: Icon(LucideIcons.dollarSign, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB), width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF22C55E), width: 2)), // green-500
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category
                  Text('Categoría 🏷️', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: incomeCategories.map((cat) {
                      final isSelected = category == cat['value'];
                      return InkWell(
                        onTap: () => setState(() => category = cat['value']!),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 56) / 2, // 2 cols minus padding
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (isDark ? const Color(0xFF14532D).withValues(alpha: 0.5) : const Color(0xFFDCFCE7)) 
                                : (isDark ? const Color(0xFF374151) : Colors.white),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF16A34A) : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
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
                                  decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
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
                  Text('Descripción (Opcional) 📝', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
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

                  // Date
                  Text('Fecha 📅', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
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
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith((states) => null), // for gradient
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: isDark 
                            ? const LinearGradient(colors: [Color(0xFF15803D), Color(0xFF047857)]) 
                            : const LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF059669)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: const BoxConstraints(minHeight: 50),
                        child: const Text('Agregar Ingreso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
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
