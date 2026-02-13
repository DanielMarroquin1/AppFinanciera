import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Mis Ahorros 🎯',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Alcanza tus metas financieras',
            style: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // Total Savings
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.green800, const Color(0xFF064E3B)] // green-800 to emerald-900 (approx)
                    : [AppColors.green600, const Color(0xFF059669)], // green-600 to emerald-600
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                 BoxShadow(
                  color: (isDark ? AppColors.green800 : AppColors.green600).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Ahorrado',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '\$27,200.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(Icons.trending_up, color: Colors.white, size: 20),
                    SizedBox(width: 4),
                    Text(
                      '+12% este mes',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
           const SizedBox(height: 24),

          // Guide Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                 colors: isDark
                  ? [AppColors.purple900.withOpacity(0.4), AppColors.blue900.withOpacity(0.4)]
                  : [const Color(0xFFF3E8FF), const Color(0xFFE0E7FF)], // purple-100 to blue-100
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.purple900 : const Color(0xFFE9D5FF), // purple-800 / purple-200
                width: 2,
              ),
            ),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📚', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      'Plan de Ahorro con Guía',
                       style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                 Text(
                   'Descubre cómo ahorrar más y alcanzar tus metas más rápido',
                   style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12),
                 ),
                 const SizedBox(height: 12),
                 Container(
                   decoration: BoxDecoration(
                     color: isDark ? AppColors.purple600 : AppColors.purple600, // purple-700 / purple-600
                     borderRadius: BorderRadius.circular(12),
                   ),
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   child: const Text('Ver Guía', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                 ),
              ],
             ),
          ),
           const SizedBox(height: 24),

           // Add Goal Button
           Container(
             width: double.infinity,
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: isDark ? AppColors.gray800 : Colors.white,
               borderRadius: BorderRadius.circular(16),
               border: Border.all(
                 color: isDark ? AppColors.gray600 : Colors.grey.shade300,
                 width: 2,
                 style: BorderStyle.solid, // Dashed not directly supported in Border.all without custom painter, using solid for now or could implement DashPainter
               ),  
               // Note: Standard Flutter Border doesn't support dashed easily. 
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.add, color: isDark ? AppColors.gray400 : AppColors.gray500),
                 const SizedBox(width: 8),
                 Text('Agregar Nueva Meta', style: TextStyle(color: isDark ? AppColors.gray400 : AppColors.gray500, fontSize: 14)),
               ],
             ),
           ),
           const SizedBox(height: 24),

           // Goals List
            Text(
            'Mis Metas de Ahorro',
             style: TextStyle(
              color: isDark ? AppColors.gray400 : AppColors.gray500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
           Column(
             children: [
               _buildGoalItem(context, 'Vacaciones en Cancún', '✈️', 2500, 5000, [Colors.blue, Colors.cyan]),
               _buildGoalItem(context, 'Fondo de Emergencia', '🏥', 8500, 10000, [Colors.green, Colors.teal]),
               _buildGoalItem(context, 'Nueva Laptop', '💻', 1200, 2500, [Colors.purple, Colors.pink]),
               _buildGoalItem(context, 'Auto Nuevo', '🚗', 15000, 50000, [Colors.orange, Colors.red]),
             ],
           ),

          const SizedBox(height: 24),
           // Tip
           Container(
             padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(
               color: isDark ? AppColors.amber900.withOpacity(0.3) : AppColors.amber50,
               borderRadius: BorderRadius.circular(16),
               border: Border.all(
                 color: isDark ? AppColors.amber800 : AppColors.amber200,
                 width: 2,
               ),
             ),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   children: [
                     const Text('💡', style: TextStyle(fontSize: 20)),
                     const SizedBox(width: 8),
                     Text('Consejo del día', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                   ],
                 ),
                 const SizedBox(height: 8),
                 Text('Ahorra el 20% de tus ingresos cada mes. Pequeños cambios hacen grandes diferencias.', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12)),
               ],
             ),
           ),
           const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildGoalItem(BuildContext context, String name, String icon, int current, int goal, List<Color> colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (current / goal).clamp(0.0, 1.0);
    final isComplete = percentage >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.gray800 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.gray600.withOpacity(0.5) : AppColors.gray100,
        ),
         boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('\$${current.toString()}', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 4),
                        Text('de \$${goal.toString()}', style: TextStyle(color: AppColors.gray500, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              if (isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.green900 : AppColors.green100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('¡Logrado!', style: TextStyle(color: isDark ? AppColors.green200 : AppColors.green800, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
           Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray600 : AppColors.gray100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(percentage * 100).toStringAsFixed(0)}% completado', style: TextStyle(color: AppColors.gray500, fontSize: 12)),
              Text('Agregar fondos', style: TextStyle(color: isDark ? AppColors.purple400 : AppColors.purple600, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
