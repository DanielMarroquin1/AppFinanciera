import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BudgetLimitModal extends StatefulWidget {
  final int initialValue;

  const BudgetLimitModal({
    super.key,
    required this.initialValue,
  });

  static Future<int?> show(BuildContext context, {required int initialValue}) {
    return showDialog<int>(
      context: context,
      builder: (context) => BudgetLimitModal(initialValue: initialValue),
    );
  }

  @override
  State<BudgetLimitModal> createState() => _BudgetLimitModalState();
}

class _BudgetLimitModalState extends State<BudgetLimitModal> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabecera
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF78350F).withValues(alpha: 0.3) : const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.bellRing,
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alerta de Presupuesto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        'Ajustar límite',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              'Te avisaremos cuando tus gastos alcancen este porcentaje de tu presupuesto mensual.',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Slider y Porcentaje
            Column(
              children: [
                Text(
                  '$_currentValue%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B),
                    inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    thumbColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B),
                    overlayColor: (isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B)).withValues(alpha: 0.2),
                    trackHeight: 8,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                  ),
                  child: Slider(
                    value: _currentValue.toDouble(),
                    min: 50,
                    max: 100,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        _currentValue = value.toInt();
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('50%', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                      Text('100%', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),
            
            // Botones
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_currentValue),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFFD97706) : const Color(0xFFF59E0B), // amber
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
