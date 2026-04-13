import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final data = [
      {'month': 'Ene', 'income': 3500.0, 'expenses': 2300.0},
      {'month': 'Feb', 'income': 3500.0, 'expenses': 2550.0},
      {'month': 'Mar', 'income': 4200.0, 'expenses': 2800.0},
      {'month': 'Abr', 'income': 3500.0, 'expenses': 2200.0},
      {'month': 'May', 'income': 3800.0, 'expenses': 2900.0},
      {'month': 'Jun', 'income': 3500.0, 'expenses': 2400.0},
    ];

    double maxValue = 0;
    for (var d in data) {
      if ((d['income'] as double) > maxValue) maxValue = d['income'] as double;
      if ((d['expenses'] as double) > maxValue) maxValue = d['expenses'] as double;
    }

    final categoryData = [
      {'name': 'Comida', 'amount': 450.0, 'color': const Color(0xFFEF4444), 'percentage': 35}, // red-500
      {'name': 'Transporte', 'amount': 280.0, 'color': const Color(0xFF3B82F6), 'percentage': 22}, // blue-500
      {'name': 'Hogar', 'amount': 520.0, 'color': const Color(0xFFA855F7), 'percentage': 40}, // purple-500
      {'name': 'Entretenimiento', 'amount': 150.0, 'color': const Color(0xFFEC4899), 'percentage': 12}, // pink-500
      {'name': 'Salud', 'amount': 95.0, 'color': const Color(0xFF22C55E), 'percentage': 7}, // green-500
      {'name': 'Otros', 'amount': 55.0, 'color': const Color(0xFF6B7280), 'percentage': 4}, // gray-500
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by AppShell
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text('Reportes 📊', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 4),
            Text('Análisis de tus finanzas', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(height: 24),

            // Period Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.chevron_left, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  Row(
                    children: [
                      Icon(LucideIcons.calendar, color: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), size: 20),
                      const SizedBox(width: 8),
                      Text('Últimos 6 meses', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                    ],
                  ),
                  Icon(Icons.chevron_right, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isDark 
                          ? const LinearGradient(colors: [Color(0xFF166534), Color(0xFF064E3B)]) // green-800 to emerald-900
                          : const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF059669)]), // green-500 to emerald-600
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.trendingUp, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text('Ingresos', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('\$22,000', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Este mes', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isDark 
                          ? const LinearGradient(colors: [Color(0xFF991B1B), Color(0xFF831843)]) // red-800 to pink-900
                          : const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDB2777)]), // red-500 to pink-600
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.trendingDown, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text('Gastos', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('\$15,150', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Este mes', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bar Chart
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ingresos vs Gastos', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 192,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: data.map((item) {
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      height: ((item['income'] as double) / maxValue) * 150,
                                      constraints: const BoxConstraints(minHeight: 20),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF16A34A) : const Color(0xFF22C55E),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      height: ((item['expenses'] as double) / maxValue) * 150,
                                      constraints: const BoxConstraints(minHeight: 20),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFFDC2626) : const Color(0xFFEF4444),
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(item['month'] as String, style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: isDark ? const Color(0xFF16A34A) : const Color(0xFF22C55E), borderRadius: BorderRadius.circular(4))),
                          const SizedBox(width: 8),
                          Text('Ingresos', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          Container(width: 12, height: 12, decoration: BoxDecoration(color: isDark ? const Color(0xFFDC2626) : const Color(0xFFEF4444), borderRadius: BorderRadius.circular(4))),
                          const SizedBox(width: 8),
                          Text('Gastos', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Donut Chart Equivalent
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : Colors.white,
                border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Distribución de Gastos', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: 160, height: 160,
                      child: CustomPaint(
                        painter: _DonutChartPainter(
                          data: categoryData.map((d) => _ChartItem(value: (d['percentage'] as int).toDouble(), color: d['color'] as Color)).toList()
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$1,550', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                              Text('Total', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: categoryData.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(width: 12, height: 12, decoration: BoxDecoration(color: cat['color'] as Color, borderRadius: BorderRadius.circular(4))),
                                const SizedBox(width: 8),
                                Text(cat['name'] as String, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                            Row(
                              children: [
                                Text('${cat['percentage']}%', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                                const SizedBox(width: 8),
                                SizedBox(width: 60, child: Text('\$${(cat['amount'] as double).toStringAsFixed(0)}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 12), textAlign: TextAlign.right)),
                              ],
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Export Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF7E22CE) : const Color(0xFF9333EA), // purple-700 : purple-600
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Descargar Reporte PDF'),
            ),
            const SizedBox(height: 48), // Padding bottom
          ],
        ),
      ),
    );
  }
}

class _ChartItem {
  final double value;
  final Color color;
  _ChartItem({required this.value, required this.color});
}

class _DonutChartPainter extends CustomPainter {
  final List<_ChartItem> data;
  _DonutChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    double total = data.fold(0, (sum, item) => sum + item.value);
    double currentAngle = -3.14159 / 2; // Start at top

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round; // Doesn't perfectly replicate svg dash but looks good

    for (var item in data) {
      final sweepAngle = (item.value / total) * 2 * 3.14159;
      paint.color = item.color;
      
      // Draw arc slightly smaller than full sweep to have gaps
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
        currentAngle,
        sweepAngle - 0.05, // small gap
        false,
        paint,
      );
      
      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
