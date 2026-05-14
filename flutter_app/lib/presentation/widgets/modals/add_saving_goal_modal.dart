import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/saving_goal.dart';
import '../../providers/saving_goals_provider.dart';
import '../../providers/auth_provider.dart';

class AddSavingGoalModal extends ConsumerStatefulWidget {
  final String? initialName;
  final double? initialTargetAmount;
  final String? initialIcon;

  const AddSavingGoalModal({
    super.key,
    this.initialName,
    this.initialTargetAmount,
    this.initialIcon,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialName,
    double? initialTargetAmount,
    String? initialIcon,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSavingGoalModal(
        initialName: initialName,
        initialTargetAmount: initialTargetAmount,
        initialIcon: initialIcon,
      ),
    );
  }

  @override
  ConsumerState<AddSavingGoalModal> createState() => _AddSavingGoalModalState();
}

class _AddSavingGoalModalState extends ConsumerState<AddSavingGoalModal> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late String selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? "");
    _amountController = TextEditingController(
      text: widget.initialTargetAmount != null && widget.initialTargetAmount! > 0 
          ? widget.initialTargetAmount.toString() 
          : "",
    );
    selectedIcon = widget.initialIcon ?? "🎯";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

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
                    controller: _nameController,
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
                    controller: _amountController,
                    keyboardType: TextInputType.number,
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
                    onPressed: () async {
                      final name = _nameController.text.trim();
                      final amount = double.tryParse(_amountController.text) ?? 0.0;
                      if (name.isEmpty || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, ingresa un nombre y un monto válido.')),
                        );
                        return;
                      }

                      final user = ref.read(authProvider).user;
                      if (user != null) {
                        final goal = SavingGoal(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          targetAmount: amount,
                          currentAmount: 0.0,
                          icon: selectedIcon,
                          userId: user.email,
                        );

                        await ref.read(savingGoalsProvider.notifier).addGoal(goal);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Meta de ahorro creada con éxito 🎉'), backgroundColor: Colors.green),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Guardar Meta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
