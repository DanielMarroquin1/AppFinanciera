import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedPeriod = 'Últimos 6 meses';
  bool isExporting = false;

  void _exportReport() {
    setState(() => isExporting = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => isExporting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(LucideIcons.checkCircle, color: Colors.white),
                SizedBox(width: 12),
                Text('Reporte PDF generado con éxito'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });
  }

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
      {'name': 'Comida', 'amount': 450.0, 'color': const Color(0xFFEF4444), 'percentage': 35},
      {'name': 'Transporte', 'amount': 280.0, 'color': const Color(0xFF3B82F6), 'percentage': 22},
      {'name': 'Hogar', 'amount': 520.0, 'color': const Color(0xFFA855F7), 'percentage': 40},
      {'name': 'Entretenimiento', 'amount': 150.0, 'color': const Color(0xFFEC4899), 'percentage': 12},
      {'name': 'Salud', 'amount': 95.0, 'color': const Color(0xFF22C55E), 'percentage': 7},
      {'name': 'Otros', 'amount': 55.0, 'color': const Color(0xFF6B7280), 'percentage': 4},
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
            InkWell(
              onTap: () {
                // Show simple selection
                showModalBottomSheet(
                  context: context,
                  backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('Seleccionar Período', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black)),
                      ),
                      ListTile(title: const Text('Último mes'), onTap: () { setState(() => selectedPeriod = 'Último mes'); Navigator.pop(context); }),
                      ListTile(title: const Text('Últimos 3 meses'), onTap: () { setState(() => selectedPeriod = 'Últimos 3 meses'); Navigator.pop(context); }),
                      ListTile(title: const Text('Últimos 6 meses'), onTap: () { setState(() => selectedPeriod = 'Últimos 6 meses'); Navigator.pop(context); }),
                      ListTile(title: const Text('Este año'), onTap: () { setState(() => selectedPeriod = 'Este año'); Navigator.pop(context); }),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
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
                        Text(selectedPeriod, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Icon(Icons.chevron_right, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  ],
                ),
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
                          ? const LinearGradient(colors: [Color(0xFF166534), Color(0xFF064E3B)]) 
                          : const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF059669)]), 
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
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
                        Text('Este período', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
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
                          ? const LinearGradient(colors: [Color(0xFF991B1B), Color(0xFF831843)]) 
                          : const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDB2777)]), 
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
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
                        Text('Este período', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
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
                  Text('Ingresos vs Gastos', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
                      _buildLegend(isDark, const Color(0xFF22C55E), 'Ingresos'),
                      const SizedBox(width: 16),
                      _buildLegend(isDark, const Color(0xFFEF4444), 'Gastos'),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Distribution Chart
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
                  Text('Distribución de Gastos', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
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
                  ...categoryData.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: (cat['color'] as Color), borderRadius: BorderRadius.circular(4))),
                              const SizedBox(width: 8),
                              Text(cat['name'] as String, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                            ],
                          ),
                          Row(
                            children: [
                              Text('${cat['percentage']}%', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                              const SizedBox(width: 12),
                              SizedBox(width: 70, child: Text('\$${(cat['amount'] as double).toStringAsFixed(0)}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
                            ],
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Export Button
            ElevatedButton(
              onPressed: isExporting ? null : _exportReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF7E22CE) : const Color(0xFF9333EA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: isExporting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.download, size: 20),
                        SizedBox(width: 12),
                        Text('Descargar Reporte PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
            ),
            const SizedBox(height: 80), 
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(bool isDark, Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
      ],
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
    double currentAngle = -3.14159 / 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    for (var item in data) {
      final sweepAngle = (item.value / total) * 2 * 3.14159;
      paint.color = item.color;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2),
        currentAngle,
        sweepAngle - 0.05,
        false,
        paint,
      );
      
      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
