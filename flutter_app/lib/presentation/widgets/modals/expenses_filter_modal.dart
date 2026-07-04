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
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 40, offset: const Offset(0, -10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 14, bottom: 8),
              height: 5,
              width: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Icon(LucideIcons.barChart2, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Configurar Reporte', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                        const SizedBox(height: 2),
                        Text('Filtra tus gastos para un análisis preciso', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(LucideIcons.x, color: isDark ? Colors.grey[300] : Colors.grey[700], size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              ],
            ),
          ),
          Divider(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), height: 1),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Year Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Año del Reporte 📅', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w800)),
                      Text(selectedYear.toString(), style: const TextStyle(color: Color(0xFF6366F1), fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableYears.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, idx) {
                        final yr = availableYears[idx];
                        final isSel = yr == selectedYear;
                        return InkWell(
                          onTap: () => setState(() => selectedYear = yr),
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: isSel ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]) : null,
                              color: isSel ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSel ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                              boxShadow: isSel ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
                            ),
                            child: Text(
                              yr.toString(),
                              style: TextStyle(
                                color: isSel ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                                fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Month Selector
                  Text('Mes del Reporte 📆', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.1,
                    ),
                    itemCount: availableMonths.length,
                    itemBuilder: (context, idx) {
                      final m = availableMonths[idx];
                      final isSel = m == selectedMonth;
                      final shortNames = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
                      return InkWell(
                        onTap: () => setState(() => selectedMonth = m),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: isSel ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]) : null,
                            color: isSel ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSel ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                            boxShadow: isSel ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))] : [],
                          ),
                          child: Text(
                            shortNames[m - 1],
                            style: TextStyle(
                              color: isSel ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                              fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Expense Types
                  Text('Tipos de Gastos a Incluir 🎯', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  _buildTypeCard(isDark, 'Gastos Normales', 'Compras cotidianas del mes', LucideIcons.wallet, includeNormal, (val) => setState(() => includeNormal = val)),
                  const SizedBox(height: 10),
                  _buildTypeCard(isDark, 'Gastos Fijos', 'Suscripciones y servicios recurrentes', LucideIcons.receipt, includeFixed, (val) => setState(() => includeFixed = val)),
                  const SizedBox(height: 10),
                  _buildTypeCard(isDark, 'Cuotas de Deudas', 'Pagos a créditos y préstamos', LucideIcons.creditCard, includeDebts, (val) => setState(() => includeDebts = val)),
                  const SizedBox(height: 28),

                  // Categories
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Categorías a Filtrar 🏷️', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w800)),
                      if (selectedCategories.length > 1 || !selectedCategories.contains('Todas'))
                        GestureDetector(
                          onTap: () => setState(() => selectedCategories = ['Todas']),
                          child: Text('Restablecer', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10, runSpacing: 10,
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: isSelected ? LinearGradient(colors: [(cat['color'] as Color).withValues(alpha: 0.25), (cat['color'] as Color).withValues(alpha: 0.1)]) : null,
                                color: isSelected ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? (cat['color'] as Color) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)), 
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected ? [BoxShadow(color: (cat['color'] as Color).withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))] : [],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(cat['emoji'], style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    cat['main'], 
                                    style: TextStyle(
                                      color: isSelected ? (isDark ? Colors.white : (cat['color'] as Color)) : (isDark ? Colors.grey[300] : Colors.grey[700]), 
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      fontSize: 14,
                                    )
                                  ),
                                  if ((cat['subs'] as List).isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Icon(isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16, color: isSelected ? (cat['color'] as Color) : (isDark ? Colors.grey[400] : Colors.grey[600])),
                                  ]
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded && (cat['subs'] as List).isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 10, left: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Wrap(
                                spacing: 8, runSpacing: 8,
                                children: (cat['subs'] as List<dynamic>).map((sub) {
                                  final isSubSelected = selectedCategories.contains(sub['value']);
                                  return InkWell(
                                    onTap: () => _toggleCategory(sub['value']),
                                    borderRadius: BorderRadius.circular(14),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSubSelected ? (cat['color'] as Color) : (isDark ? const Color(0xFF334155) : Colors.white),
                                        borderRadius: BorderRadius.circular(14),
                                        border: isSubSelected ? null : Border.all(color: isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1)),
                                        boxShadow: isSubSelected ? [BoxShadow(color: (cat['color'] as Color).withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))] : [],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(sub['emoji'], style: const TextStyle(fontSize: 14)),
                                          const SizedBox(width: 6),
                                          Text(
                                            sub['label'],
                                            style: TextStyle(
                                              color: isSubSelected ? Colors.white : (isDark ? Colors.grey[200] : Colors.grey[800]),
                                              fontSize: 12.5,
                                              fontWeight: isSubSelected ? FontWeight.w800 : FontWeight.w500,
                                            ),
                                          ),
                                          if (isSubSelected) ...[
                                            const SizedBox(width: 4),
                                            const Icon(LucideIcons.checkCircle2, color: Colors.white, size: 12),
                                          ]
                                        ],
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
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Footer Actions
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : Colors.white,
              border: Border(top: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
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
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('Limpiar', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
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
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Generar Reporte Detallado', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTypeCard(bool isDark, String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: value 
              ? (isDark ? LinearGradient(colors: [const Color(0xFF6366F1).withValues(alpha: 0.25), const Color(0xFF4F46E5).withValues(alpha: 0.15)]) : const LinearGradient(colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)]))
              : null,
          color: value ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: value ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: value ? 2 : 1.5,
          ),
          boxShadow: value ? [BoxShadow(color: const Color(0xFF6366F1).withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: value ? const Color(0xFF6366F1) : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: value ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                gradient: value ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]) : null,
                color: value ? null : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                shape: BoxShape.circle,
              ),
              child: value ? const Icon(LucideIcons.check, color: Colors.white, size: 16) : null,
            ),
          ],
        ),
      ),
    );
  }

}
