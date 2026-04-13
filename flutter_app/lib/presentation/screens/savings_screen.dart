import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final goals = [
      {
        'name': 'Vacaciones en Cancún',
        'icon': '✈️',
        'current': 2500.0,
        'goal': 5000.0,
        'colors': isDark 
            ? [const Color(0xFF1E3A8A), const Color(0xFF164E63)] // blue-900 to cyan-900
            : [const Color(0xFF3B82F6), const Color(0xFF06B6D4)], // blue-500 to cyan-500
      },
      {
        'name': 'Fondo de Emergencia',
        'icon': '🏥',
        'current': 8500.0,
        'goal': 10000.0,
        'colors': isDark 
            ? [const Color(0xFF14532D), const Color(0xFF064E3B)] // green-900 to emerald-900
            : [const Color(0xFF22C55E), const Color(0xFF10B981)], // green-500 to emerald-500
      },
      {
        'name': 'Nueva Laptop',
        'icon': '💻',
        'current': 1200.0,
        'goal': 2500.0,
        'colors': isDark 
            ? [const Color(0xFF581C87), const Color(0xFF831843)] // purple-900 to pink-900
            : [const Color(0xFFA855F7), const Color(0xFFEC4899)], // purple-500 to pink-500
      },
      {
        'name': 'Auto Nuevo',
        'icon': '🚗',
        'current': 15000.0,
        'goal': 50000.0,
        'colors': isDark 
            ? [const Color(0xFF7C2D12), const Color(0xFF7F1D1D)] // orange-900 to red-900
            : [const Color(0xFFF97316), const Color(0xFFEF4444)], // orange-500 to red-500
      },
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
              'Mis Ahorros 🎯',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Alcanza tus metas financieras',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Total Savings
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [const Color(0xFF166534), const Color(0xFF064E3B)] // green-800 to emerald-900
                      : [const Color(0xFF16A34A), const Color(0xFF059669)], // green-600 to emerald-600
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
                  Text('Total Ahorrado', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('\$27,200.00', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(LucideIcons.trendingUp, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text('+12% este mes', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Savings Guide Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF581C87).withValues(alpha: 0.4) : const Color(0xFFF3E8FF),
                border: Border.all(
                  color: isDark ? const Color(0xFF6B21A8) : const Color(0xFFE9D5FF),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📚', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(
                        'Plan de Ahorro con Guía',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                    'Descubre cómo ahorrar más y alcanzar tus metas más rápido',
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF7E22CE) : const Color(0xFF9333EA),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Ver Guía', style: TextStyle(fontSize: 12)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Add New Goal Button
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  border: Border.all(
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.plus, color: isDark ? Colors.grey[400] : Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text('Agregar Nueva Meta', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Goals
            Text('Mis Metas de Ahorro', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 14)),
            const SizedBox(height: 12),
            ...goals.map((goal) {
              final percentage = ((goal['current'] as double) / (goal['goal'] as double)) * 100;
              final isComplete = percentage >= 100;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: goal['colors'] as List<Color>,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(child: Text(goal['icon'] as String, style: const TextStyle(fontSize: 24))),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(goal['name'] as String, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('\$${(goal['current'] as double).toStringAsFixed(0)}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18)),
                                  const SizedBox(width: 4),
                                  Text('de \$${(goal['goal'] as double).toStringAsFixed(0)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              )
                            ],
                          ),
                        ),
                        if (isComplete)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('¡Logrado!', style: TextStyle(color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D), fontSize: 12)),
                          )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (percentage / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: goal['colors'] as List<Color>,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${percentage.toStringAsFixed(0)}% completado', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Agregar fondos', style: TextStyle(color: isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA), fontSize: 12)),
                        )
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 80), // Fab space
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
            gradient: const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFFEC4899)]), // purple to pink
          ),
          child: const Icon(LucideIcons.sparkles, color: Colors.white),
        ),
      ),
    );
  }
}
