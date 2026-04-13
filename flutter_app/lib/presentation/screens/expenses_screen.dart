import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final expenses = [
      {'category': '🍔 Comida', 'amount': 450.50, 'percentage': 35, 'color': const Color(0xFFF43F5E)}, // rose-500
      {'category': '🚗 Transporte', 'amount': 280.00, 'percentage': 22, 'color': const Color(0xFF0EA5E9)}, // sky-500
      {'category': '🏠 Hogar', 'amount': 520.00, 'percentage': 40, 'color': const Color(0xFF6366F1)}, // indigo-500
      {'category': '🎮 Entretenimiento', 'amount': 150.00, 'percentage': 12, 'color': const Color(0xFFD946EF)}, // fuchsia-500
      {'category': '💊 Salud', 'amount': 95.00, 'percentage': 7, 'color': const Color(0xFF10B981)}, // emerald-500
    ];

    final recentExpenses = [
      {'icon': '🛒', 'name': 'Walmart', 'date': 'Hoy', 'amount': 45.50},
      {'icon': '🚕', 'name': 'Uber', 'date': 'Ayer', 'amount': 12.00},
      {'icon': '☕', 'name': 'Starbucks', 'date': 'Ayer', 'amount': 8.50},
      {'icon': '🍕', 'name': 'Pizza Hut', 'date': '2 Ene', 'amount': 32.00},
      {'icon': '⚡', 'name': 'Luz (CFE)', 'date': '1 Ene', 'amount': 245.00},
      {'icon': '🎬', 'name': 'Netflix', 'date': '1 Ene', 'amount': 139.00},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by AppShell
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Mis Gastos 💸',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Febrero 2026',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Search and Filter
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.search, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar gastos...',
                              hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF4338CA) : const Color(0xFF4F46E5), // indigo-700 : indigo-600
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Icon(LucideIcons.filter, color: Colors.white, size: 20)),
                )
              ],
            ),
            const SizedBox(height: 24),

            // AI Help Banner (Premium)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isDark 
                    ? const LinearGradient(colors: [Color(0x33312E81), Color(0x33064E3B)]) // indigo-900/40 to emerald-900/40
                    : const LinearGradient(colors: [Color(0xFFE0E7FF), Color(0xFFD1FAE5)]), // indigo-100 to emerald-100
                border: Border.all(
                  color: isDark ? const Color(0xFF3730A3) : const Color(0xFFC7D2FE), // indigo-800 to indigo-200
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.sparkles, color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5)),
                      const SizedBox(width: 12),
                      Text(
                        'Ayuda con IA para Gastos',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.crown, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Obtén consejos personalizados para reducir gastos y optimizar tu presupuesto',
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Total Expenses Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [const Color(0xFF881337), const Color(0xFF831843)] // rose-900 to pink-900
                      : [const Color(0xFFF43F5E), const Color(0xFFDB2777)], // rose-500 to pink-600
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total de Gastos', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('\$2,550.00', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.67, // 67%
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('67% de tu presupuesto mensual (\$3800.00)', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Expenses by Category
            Text('Gastos por Categoría', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
            const SizedBox(height: 12),
            ...expenses.map((expense) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(expense['category'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                        Text('\$${(expense['amount'] as double).toStringAsFixed(2)}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: ((expense['percentage'] as int) / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: expense['color'] as Color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('${expense['percentage']}% del total', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    )
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),

            // Recent Transactions
            Text('Historial de Gastos', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
            const SizedBox(height: 12),
            ...recentExpenses.map((expense) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(expense['icon'] as String, style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(expense['name'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(expense['date'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text('-\$${(expense['amount'] as double).toStringAsFixed(2)}', style: TextStyle(color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 80), // For FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 10,
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isDark 
                ? const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF10B981)])
                : const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF10B981)]),
          ),
          child: const Icon(LucideIcons.mic, color: Colors.white),
        ),
      ),
    );
  }
}
