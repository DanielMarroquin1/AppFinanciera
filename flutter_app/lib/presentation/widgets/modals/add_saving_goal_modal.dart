import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddSavingGoalModal extends StatefulWidget {
  const AddSavingGoalModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddSavingGoalModal(),
    );
  }

  @override
  State<AddSavingGoalModal> createState() => _AddSavingGoalModalState();
}

class _AddSavingGoalModalState extends State<AddSavingGoalModal> {
  String name = "";
  double targetAmount = 0.0;
  String selectedIcon = "🎯";

  final icons = ["🎯", "✈️", "🏠", "🚗", "💻", "🏥", "💍", "🎓", "🎮", "🚲"];

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
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark 
                  ? const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)]) 
                  : const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(LucideIcons.target, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Text('Nueva Meta de Ahorro', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('¿Qué quieres lograr? 📝', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (val) => name = val,
                    decoration: InputDecoration(
                      hintText: 'Ej: Viaje a Japón, Fondo de paz...',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Monto Objetivo 💵', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (val) => targetAmount = double.tryParse(val) ?? 0.0,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(LucideIcons.dollarSign),
                      hintText: '0.00',
                      filled: true,
                      fillColor: isDark ? const Color(0xFF374151) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Selecciona un Icono', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 14)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: icons.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final icon = icons[index];
                        final isSelected = selectedIcon == icon;
                        return GestureDetector(
                          onTap: () => setState(() => selectedIcon = icon),
                          child: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF3B82F6) : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                            ),
                            child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Crear Meta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
