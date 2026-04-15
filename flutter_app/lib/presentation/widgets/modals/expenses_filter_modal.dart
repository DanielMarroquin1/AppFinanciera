import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ExpensesFilterModal extends StatefulWidget {
  const ExpensesFilterModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExpensesFilterModal(),
    );
  }

  @override
  State<ExpensesFilterModal> createState() => _ExpensesFilterModalState();
}

class _ExpensesFilterModalState extends State<ExpensesFilterModal> {
  String selectedMonth = 'Febrero';
  String selectedCategory = 'Todas';

  final months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio'];
  final categories = ['Todas', 'Comida', 'Transporte', 'Hogar', 'Entretenimiento', 'Salud', 'Otro'];

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4, width: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filtros', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
          const Divider(),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mes', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: months.map((month) {
                    final isSelected = selectedMonth == month;
                    return InkWell(
                      onTap: () => setState(() => selectedMonth = month),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? (isDark ? const Color(0xFF4F46E5) : const Color(0xFF4338CA)) : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? null : Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          month,
                          style: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                Text('Categoría', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return InkWell(
                      onTap: () => setState(() => selectedCategory = cat),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? (isDark ? const Color(0xFF10B981) : const Color(0xFF059669)) : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected ? null : Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 48),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            selectedMonth = 'Febrero';
                            selectedCategory = 'Todas';
                          });
                        },
                        child: Text('Limpiar', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop({'month': selectedMonth, 'category': selectedCategory}),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF4F46E5) : const Color(0xFF4338CA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Aplicar Filtros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
              ],
            ),
          )
        ],
      ),
    );
  }
}
