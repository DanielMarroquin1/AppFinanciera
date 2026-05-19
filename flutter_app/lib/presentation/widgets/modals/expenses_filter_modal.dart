import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class ExpensesFilterModal extends StatefulWidget {
  final int? initialMonth;
  final int? initialYear;
  final List<String>? initialCategories;

  const ExpensesFilterModal({super.key, this.initialMonth, this.initialYear, this.initialCategories});

  static Future<Map<String, dynamic>?> show(BuildContext context, {int? initialMonth, int? initialYear, List<String>? initialCategories}) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpensesFilterModal(initialMonth: initialMonth, initialYear: initialYear, initialCategories: initialCategories),
    );
  }

  @override
  State<ExpensesFilterModal> createState() => _ExpensesFilterModalState();
}

class _ExpensesFilterModalState extends State<ExpensesFilterModal> {
  late int selectedYear;
  late int selectedMonth;
  late List<String> selectedCategories;
  
  bool includeNormal = true;
  bool includeFixed = false;
  bool includeDebts = false;

  String? expandedCategory;

  final List<Map<String, dynamic>> detailedCategories = [
    {
      'main': 'Todas', 'value': 'Todas', 'emoji': '🌍', 'color': const Color(0xFF6366F1),
      'subs': []
    },
    {
      'main': 'Comida', 'value': 'food', 'emoji': '🍔', 'color': const Color(0xFFF43F5E),
      'subs': [
        {'value': 'food', 'label': 'General', 'emoji': '🍔'},
        {'value': 'food_grocery', 'label': 'Supermercado', 'emoji': '🛒'},
        {'value': 'food_restaurant', 'label': 'Restaurante', 'emoji': '🍽️'},
        {'value': 'food_coffee', 'label': 'Cafetería', 'emoji': '☕'},
        {'value': 'food_delivery', 'label': 'Delivery', 'emoji': '🛵'},
      ]
    },
    {
      'main': 'Transporte', 'value': 'transport', 'emoji': '🚗', 'color': const Color(0xFF0EA5E9),
      'subs': [
        {'value': 'transport', 'label': 'General', 'emoji': '🚗'},
        {'value': 'transport_gas', 'label': 'Gasolina', 'emoji': '⛽'},
        {'value': 'transport_public', 'label': 'Transporte Público', 'emoji': '🚌'},
        {'value': 'transport_taxi', 'label': 'Taxi / App', 'emoji': '🚕'},
        {'value': 'transport_flight', 'label': 'Vuelos', 'emoji': '✈️'},
      ]
    },
    {
      'main': 'Servicios', 'value': 'bills', 'emoji': '📱', 'color': const Color(0xFFF59E0B),
      'subs': [
        {'value': 'bills', 'label': 'General', 'emoji': '📱'},
        {'value': 'bills_water', 'label': 'Agua', 'emoji': '💧'},
        {'value': 'bills_electricity', 'label': 'Luz', 'emoji': '⚡'},
        {'value': 'bills_internet', 'label': 'Internet / TV', 'emoji': '🌐'},
        {'value': 'bills_gas', 'label': 'Gas', 'emoji': '🔥'},
      ]
    },
    {
      'main': 'Compras', 'value': 'shopping', 'emoji': '🛍️', 'color': const Color(0xFFEC4899),
      'subs': [
        {'value': 'shopping', 'label': 'General', 'emoji': '🛍️'},
        {'value': 'shopping_clothes', 'label': 'Ropa y Calzado', 'emoji': '👕'},
        {'value': 'shopping_electronics', 'label': 'Electrónica', 'emoji': '💻'},
        {'value': 'shopping_gifts', 'label': 'Regalos', 'emoji': '🎁'},
      ]
    },
    {
      'main': 'Ocio', 'value': 'entertainment', 'emoji': '🎮', 'color': const Color(0xFFD946EF),
      'subs': [
        {'value': 'entertainment', 'label': 'General', 'emoji': '🎮'},
        {'value': 'entertainment_movies', 'label': 'Cine', 'emoji': '🍿'},
        {'value': 'entertainment_music', 'label': 'Música', 'emoji': '🎵'},
        {'value': 'entertainment_sports', 'label': 'Deportes', 'emoji': '⚽'},
        {'value': 'entertainment_subscriptions', 'label': 'Suscripciones', 'emoji': '📺'},
      ]
    },
    {
      'main': 'Salud', 'value': 'health', 'emoji': '💊', 'color': const Color(0xFF10B981),
      'subs': [
        {'value': 'health', 'label': 'General', 'emoji': '💊'},
        {'value': 'health_doctor', 'label': 'Médico', 'emoji': '👨‍⚕️'},
        {'value': 'health_pharmacy', 'label': 'Farmacia', 'emoji': '🏥'},
        {'value': 'health_gym', 'label': 'Gimnasio', 'emoji': '🏋️'},
      ]
    },
    {
      'main': 'Hogar', 'value': 'home', 'emoji': '🏠', 'color': const Color(0xFF6366F1),
      'subs': [
        {'value': 'home', 'label': 'General', 'emoji': '🏠'},
        {'value': 'home_rent', 'label': 'Alquiler / Hipoteca', 'emoji': '🏢'},
        {'value': 'home_maintenance', 'label': 'Mantenimiento', 'emoji': '🔧'},
        {'value': 'home_furniture', 'label': 'Muebles', 'emoji': '🛋️'},
      ]
    },
    {
      'main': 'Educación', 'value': 'education', 'emoji': '📚', 'color': const Color(0xFF8B5CF6),
      'subs': [
        {'value': 'education', 'label': 'General', 'emoji': '📚'},
        {'value': 'education_tuition', 'label': 'Colegiatura', 'emoji': '🏫'},
        {'value': 'education_books', 'label': 'Libros / Material', 'emoji': '🎒'},
        {'value': 'education_courses', 'label': 'Cursos', 'emoji': '🎓'},
      ]
    },
    {
      'main': 'Otro', 'value': 'other', 'emoji': '💸', 'color': const Color(0xFF64748B),
      'subs': [
        {'value': 'other', 'label': 'General', 'emoji': '💸'},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = widget.initialYear ?? now.year;
    selectedMonth = widget.initialMonth ?? now.month;
    selectedCategories = widget.initialCategories ?? ['Todas'];
    
    // Auto-expand if a single subcategory is selected
    if (selectedCategories.length == 1 && selectedCategories.first != 'Todas') {
      for (var cat in detailedCategories) {
        if (selectedCategories.first.startsWith(cat['value'])) {
          expandedCategory = cat['value'];
          break;
        }
      }
    }
  }

  String _getMonthName(int m) {
    final date = DateTime(2000, m);
    String name = DateFormat('MMMM', 'es').format(date);
    return name[0].toUpperCase() + name.substring(1);
  }

  void _toggleCategory(String value) {
    setState(() {
      if (value == 'Todas') {
        selectedCategories = ['Todas'];
      } else {
        selectedCategories.remove('Todas');
        if (selectedCategories.contains(value)) {
          selectedCategories.remove(value);
          if (selectedCategories.isEmpty) selectedCategories.add('Todas');
        } else {
          selectedCategories.add(value);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final currentYear = DateTime.now().year;
    
    // Allow up to currentYear + 5 or something, but typically filters are for past/present
    List<int> availableYears = List.generate(10, (i) => currentYear - 5 + i).where((y) => y <= currentYear).toList();
    if (!availableYears.contains(selectedYear)) selectedYear = availableYears.last;
    
    // Always show 12 months
    List<int> availableMonths = List.generate(12, (i) => i + 1);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
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
                Text('Generar Reporte', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
          const Divider(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mes y Año', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedMonth,
                              isExpanded: true,
                              dropdownColor: isDark ? const Color(0xFF374151) : Colors.white,
                              icon: Icon(LucideIcons.chevronDown, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              items: availableMonths.map((m) {
                                return DropdownMenuItem<int>(
                                  value: m,
                                  child: Text(_getMonthName(m), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => selectedMonth = val);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedYear,
                              isExpanded: true,
                              dropdownColor: isDark ? const Color(0xFF374151) : Colors.white,
                              icon: Icon(LucideIcons.chevronDown, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              items: availableYears.map((y) {
                                return DropdownMenuItem<int>(
                                  value: y,
                                  child: Text(y.toString(), style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => selectedYear = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Text('Tipos de Gastos a Incluir', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildCheckbox(isDark, 'Gastos Normales', LucideIcons.wallet, includeNormal, (val) => setState(() => includeNormal = val ?? true)),
                  const SizedBox(height: 8),
                  _buildCheckbox(isDark, 'Gastos Fijos', LucideIcons.receipt, includeFixed, (val) => setState(() => includeFixed = val ?? false)),
                  const SizedBox(height: 8),
                  _buildCheckbox(isDark, 'Cuotas de Deudas', LucideIcons.creditCard, includeDebts, (val) => setState(() => includeDebts = val ?? false)),
                  const SizedBox(height: 32),

                  Text('Categorías (Selección Múltiple)', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    children: detailedCategories.map((cat) {
                      final isSelected = selectedCategories.contains(cat['value']) || 
                                         (cat['value'] != 'Todas' && selectedCategories.any((c) => c.startsWith(cat['value'])));
                      final isExpanded = expandedCategory == cat['value'];
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              if (cat['value'] == 'Todas') {
                                _toggleCategory('Todas');
                                setState(() => expandedCategory = null);
                              } else {
                                // Toggle category logic and expand logic
                                _toggleCategory(cat['value']);
                                setState(() {
                                  if (expandedCategory == cat['value'] && !isSelected) {
                                    expandedCategory = null;
                                  } else {
                                    expandedCategory = cat['value'];
                                  }
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? (cat['color'] as Color).withValues(alpha: 0.2) 
                                    : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? (cat['color'] as Color) : Colors.transparent, 
                                  width: 2
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(cat['emoji'], style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    cat['main'], 
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black, 
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500
                                    )
                                  ),
                                  if ((cat['subs'] as List).isNotEmpty) ...[
                                    const SizedBox(width: 4),
                                    Icon(isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                  ]
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded && (cat['subs'] as List).isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 12, left: 16),
                              child: Wrap(
                                spacing: 8, runSpacing: 8,
                                children: (cat['subs'] as List<dynamic>).map((sub) {
                                  final isSubSelected = selectedCategories.contains(sub['value']);
                                  return InkWell(
                                    onTap: () => _toggleCategory(sub['value']),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSubSelected ? (cat['color'] as Color) : (isDark ? const Color(0xFF4B5563) : Colors.white),
                                        borderRadius: BorderRadius.circular(20),
                                        border: isSubSelected ? null : Border.all(color: isDark ? const Color(0xFF6b7280) : const Color(0xFFD1D5DB)),
                                      ),
                                      child: Text(
                                        '${sub['emoji']} ${sub['label']}',
                                        style: TextStyle(
                                          color: isSubSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                                          fontSize: 13,
                                          fontWeight: isSubSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        final now = DateTime.now();
                        selectedYear = now.year;
                        selectedMonth = now.month;
                        selectedCategories = ['Todas'];
                        expandedCategory = null;
                        includeNormal = true;
                        includeFixed = false;
                        includeDebts = false;
                      });
                    },
                    child: Text('Limpiar', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop({
                      'month': selectedMonth,
                      'year': selectedYear,
                      'categories': selectedCategories,
                      'includeNormal': includeNormal,
                      'includeFixed': includeFixed,
                      'includeDebts': includeDebts,
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF4F46E5) : const Color(0xFF4338CA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Generar Reporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool isDark, String title, IconData icon, bool value, Function(bool?) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151).withValues(alpha: 0.5) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: value ? const Color(0xFF6366F1) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16))),
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF6366F1),
            ),
          ],
        ),
      ),
    );
  }
}
