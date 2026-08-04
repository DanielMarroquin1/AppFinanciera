import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/saving_goal.dart';
import '../../providers/saving_goals_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/currency_formatter.dart';

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
    final sym = CurrencyFormatter.getSymbol(ref.watch(authProvider).user?.currency);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle for bottom sheet
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 24),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(LucideIcons.target, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nueva Meta', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.w900)),
                        Text('Define tu próximo objetivo', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24, right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Nombre de la meta', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Ej: Viaje a Japón 🗼',
                          hintStyle: TextStyle(color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('Monto Objetivo', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 24, fontWeight: FontWeight.w900),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(sym, style: TextStyle(color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8), fontSize: 24, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          hintText: '0.00',
                          hintStyle: TextStyle(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('Icono representativo', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 64,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: icons.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final icon = icons[index];
                          final isSelected = selectedIcon == icon;
                          return GestureDetector(
                            onTap: () => setState(() => selectedIcon = icon),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFF3B82F6).withOpacity(0.2) 
                                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF3B82F6) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(child: Text(icon, style: TextStyle(fontSize: isSelected ? 32 : 24))),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),

                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
                      ),
                      child: ElevatedButton(
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
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Comenzar a Ahorrar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
