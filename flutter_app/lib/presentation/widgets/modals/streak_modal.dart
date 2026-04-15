import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StreakModal extends StatelessWidget {
  final int currentStreak;

  const StreakModal({
    super.key,
    required this.currentStreak,
  });

  static Future<void> show(BuildContext context, {required int streak}) {
    return showDialog(
      context: context,
      builder: (context) => StreakModal(currentStreak: streak),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Configuración de los días de la semana (L, M, M, J, V, S, D)
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    // Mock de los días donde el usuario cumplió (ej. L, M, M listos, J hoy, resto no)
    // Asumimos para el estilo demo que los primeros 4 están completados:
    final completedDays = [true, true, true, true, false, false, false];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono de la Racha
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF7C2D12) : const Color(0xFFFFF7ED),
                border: Border.all(
                  color: isDark ? const Color(0xFFC2410C) : const Color(0xFFFDBA74),
                  width: 3,
                )
              ),
              child: Icon(
                LucideIcons.flame,
                size: 48,
                color: isDark ? const Color(0xFFF97316) : const Color(0xFFEA580C),
              ),
            ),
            const SizedBox(height: 16),
            
            // Número de la Racha
            Text(
              '$currentStreak',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C),
                height: 1.0,
              ),
            ),
            Text(
              currentStreak == 1 ? 'días de racha' : 'días de racha',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¡Estás en fuego! Ingresa tus gastos e ingresos cada día para mantenerla viva.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Calendario de semana (L-D)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isCompleted = completedDays[index];
                return Column(
                  children: [
                    Text(
                      days[index],
                      style: TextStyle(
                        color: isCompleted 
                            ? (isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C))
                            : (isDark ? Colors.grey[600] : Colors.grey[400]),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted 
                            ? (isDark ? const Color(0xFFEA580C) : const Color(0xFFF97316))
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                      ),
                      child: isCompleted
                          ? const Icon(LucideIcons.check, color: Colors.white, size: 16)
                          : null,
                    )
                  ],
                );
              }),
            ),
            const SizedBox(height: 32),
            
            // Botón Continuar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFFEA580C) : const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '¡CONTINUAR!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
