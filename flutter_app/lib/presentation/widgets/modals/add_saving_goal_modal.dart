import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/widgets/common/custom_snackbar.dart';
import 'package:flutter_app/presentation/widgets/common/shake_widget.dart';
import 'package:flutter/services.dart';
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
  final SavingGoal? goalToEdit;

  const AddSavingGoalModal({
    super.key,
    this.initialName,
    this.initialTargetAmount,
    this.initialIcon,
    this.goalToEdit,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialName,
    double? initialTargetAmount,
    String? initialIcon,
    SavingGoal? goalToEdit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSavingGoalModal(
        initialName: initialName ?? goalToEdit?.name,
        initialTargetAmount: initialTargetAmount ?? goalToEdit?.targetAmount,
        initialIcon: initialIcon ?? goalToEdit?.icon,
        goalToEdit: goalToEdit,
      ),
    );
  }

  @override
  ConsumerState<AddSavingGoalModal> createState() => _AddSavingGoalModalState();
}

class _AddSavingGoalModalState extends ConsumerState<AddSavingGoalModal> {
  final _nameShakeKey = GlobalKey<ShakeWidgetState>();
  final _amountShakeKey = GlobalKey<ShakeWidgetState>();

  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _autoDeductAmountController;
  late String selectedIcon;
  bool _isAutoDeduct = false;
  String _autoDeductFrequency = 'monthly'; // 'weekly', 'biweekly', 'monthly'
  int _autoDeductDay = 1;
  int _autoDeductDay2 = 16;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? "");
    _amountController = TextEditingController(
      text:
          widget.initialTargetAmount != null && widget.initialTargetAmount! > 0
          ? widget.initialTargetAmount.toString()
          : "",
    );
    selectedIcon = widget.initialIcon ?? "🎯";
    _isAutoDeduct = widget.goalToEdit?.isAutoDeduct ?? false;
    _autoDeductAmountController = TextEditingController(
      text: widget.goalToEdit?.autoDeductAmount != null
          ? widget.goalToEdit!.autoDeductAmount.toString()
          : "",
    );
    _autoDeductFrequency = widget.goalToEdit?.autoDeductFrequency ?? 'monthly';
    _autoDeductDay = widget.goalToEdit?.autoDeductDay ?? 1;
    _autoDeductDay2 = widget.goalToEdit?.autoDeductDay2 ?? 16;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _autoDeductAmountController.dispose();
    super.dispose();
  }

  final icons = ["🎯", "✈️", "🏠", "🚗", "💻", "🏥", "💍", "🎓", "🎮", "🚲"];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sym = CurrencyFormatter.getSymbol(
      ref.watch(authProvider).user?.currency,
    );

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0F172A).withOpacity(0.85)
              : Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
          ),
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
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.target,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.goalToEdit != null
                              ? 'Editar Meta'
                              : 'Nueva Meta',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          widget.goalToEdit != null
                              ? 'Modifica los detalles de tu meta'
                              : 'Define tu próximo objetivo',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
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
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nombre de la meta',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ej: Viaje a Japón 🗼',
                          hintStyle: TextStyle(
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Monto Objetivo',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  sym,
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Icono representativo',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF3B82F6).withOpacity(0.2)
                                    : (isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF3B82F6)
                                      : (isDark
                                            ? const Color(0xFF334155)
                                            : const Color(0xFFE2E8F0)),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  icon,
                                  style: TextStyle(
                                    fontSize: isSelected ? 32 : 24,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION: Ahorro Automático
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B).withOpacity(0.7)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _isAutoDeduct
                              ? const Color(0xFF10B981).withOpacity(0.5)
                              : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0)),
                          width: _isAutoDeduct ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _isAutoDeduct
                                        ? const [
                                            Color(0xFF10B981),
                                            Color(0xFF059669),
                                          ]
                                        : [
                                            isDark
                                                ? const Color(0xFF334155)
                                                : const Color(0xFFCBD5E1),
                                            isDark
                                                ? const Color(0xFF1E293B)
                                                : const Color(0xFF94A3B8),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  LucideIcons.repeat,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ahorro Automático',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Descontar periódicamente para esta meta',
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isAutoDeduct,
                                activeColor: const Color(0xFF10B981),
                                onChanged: (val) {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _isAutoDeduct = val;
                                    if (val &&
                                        _autoDeductAmountController
                                            .text
                                            .isEmpty) {
                                      final target =
                                          double.tryParse(
                                            _amountController.text,
                                          ) ??
                                          0.0;
                                      if (target > 0) {
                                        _autoDeductAmountController.text =
                                            (target * 0.1).toStringAsFixed(0);
                                      }
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_isAutoDeduct) ...[
                            const SizedBox(height: 18),
                            Divider(
                              color: isDark
                                  ? const Color(0xFF334155).withOpacity(0.5)
                                  : const Color(0xFFE2E8F0),
                              height: 1,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Monto a descontar por ciclo',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: TextField(
                                controller: _autoDeductAmountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          sym,
                                          style: const TextStyle(
                                            color: Color(0xFF10B981),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  hintText: '0.00',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF475569)
                                        : const Color(0xFF94A3B8),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Frecuencia del descuento',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildFrequencyChip(
                                  'weekly',
                                  'Semanal',
                                  LucideIcons.calendar,
                                  isDark,
                                ),
                                const SizedBox(width: 8),
                                _buildFrequencyChip(
                                  'biweekly',
                                  'Quincenal',
                                  LucideIcons.calendarDays,
                                  isDark,
                                ),
                                const SizedBox(width: 8),
                                _buildFrequencyChip(
                                  'monthly',
                                  'Mensual',
                                  LucideIcons.calendarRange,
                                  isDark,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_autoDeductFrequency == 'weekly') ...[
                              Text(
                                'Día de la semana',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildWeeklySelector(isDark),
                            ] else if (_autoDeductFrequency == 'biweekly') ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Primer Descuento (Día 1 al 15)',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Día $_autoDeductDay',
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildDayRangeStrip(
                                startDay: 1,
                                endDay: 15,
                                selectedDay: _autoDeductDay,
                                onSelected: (d) =>
                                    setState(() => _autoDeductDay = d),
                                isDark: isDark,
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Segundo Descuento (Día 16 al 31)',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Día $_autoDeductDay2',
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildDayRangeStrip(
                                startDay: 16,
                                endDay: 31,
                                selectedDay: _autoDeductDay2,
                                onSelected: (d) =>
                                    setState(() => _autoDeductDay2 = d),
                                isDark: isDark,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _buildQuincenaPresetChip(
                                    'Días 1 y 16',
                                    1,
                                    16,
                                    isDark,
                                  ),
                                  const SizedBox(width: 6),
                                  _buildQuincenaPresetChip(
                                    'Días 15 y 30',
                                    15,
                                    30,
                                    isDark,
                                  ),
                                  const SizedBox(width: 6),
                                  _buildQuincenaPresetChip(
                                    'Días 15 y 31',
                                    15,
                                    31,
                                    isDark,
                                  ),
                                ],
                              ),
                            ] else ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Día del mes (1 - 31)',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Día $_autoDeductDay',
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildDayRangeStrip(
                                startDay: 1,
                                endDay: 31,
                                selectedDay: _autoDeductDay,
                                onSelected: (d) =>
                                    setState(() => _autoDeductDay = d),
                                isDark: isDark,
                              ),
                            ],
                            const SizedBox(height: 14),
                            // SAMI tip banner
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '🌱',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _buildSummaryText(sym),
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF6EE7B7)
                                            : const Color(0xFF065F46),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          HapticFeedback.mediumImpact();
                          final name = _nameController.text.trim();
                          final amount =
                              double.tryParse(_amountController.text) ?? 0.0;

                          bool hasShakeError = false;
                          if (name.isEmpty) {
                            _nameShakeKey.currentState?.shake();
                            hasShakeError = true;
                          }
                          if (amount <= 0) {
                            _amountShakeKey.currentState?.shake();
                            hasShakeError = true;
                          }

                          if (hasShakeError) {
                            CustomSnackBar.showError(
                              context,
                              'Por favor, ingresa un nombre y un monto válido.',
                            );
                            return;
                          }

                          final isAuto = _isAutoDeduct;
                          final autoAmount = isAuto
                              ? (double.tryParse(
                                      _autoDeductAmountController.text,
                                    ) ??
                                    0.0)
                              : null;

                          if (isAuto &&
                              (autoAmount == null || autoAmount <= 0)) {
                            CustomSnackBar.showError(
                              context,
                              'Por favor, ingresa un monto válido para el descuento automático.',
                            );
                            return;
                          }

                          final user = ref.read(authProvider).user;
                          if (user != null) {
                            if (widget.goalToEdit != null) {
                              final updatedGoal = widget.goalToEdit!.copyWith(
                                name: name,
                                targetAmount: amount,
                                icon: selectedIcon,
                                isAutoDeduct: isAuto,
                                autoDeductAmount: autoAmount,
                                autoDeductFrequency: isAuto
                                    ? _autoDeductFrequency
                                    : null,
                                autoDeductDay: isAuto ? _autoDeductDay : null,
                                autoDeductDay2:
                                    (isAuto && _autoDeductFrequency == 'biweekly')
                                        ? _autoDeductDay2
                                        : null,
                              );
                              await ref
                                  .read(savingGoalsProvider.notifier)
                                  .updateGoal(updatedGoal);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                CustomSnackBar.showSuccess(
                                  context,
                                  'Meta actualizada con éxito 🎉',
                                );
                              }
                            } else {
                              final goal = SavingGoal(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                name: name,
                                targetAmount: amount,
                                currentAmount: 0.0,
                                icon: selectedIcon,
                                userId: user.email,
                                isAutoDeduct: isAuto,
                                autoDeductAmount: autoAmount,
                                autoDeductFrequency: isAuto
                                    ? _autoDeductFrequency
                                    : null,
                                autoDeductDay: isAuto ? _autoDeductDay : null,
                                autoDeductDay2:
                                    (isAuto && _autoDeductFrequency == 'biweekly')
                                        ? _autoDeductDay2
                                        : null,
                              );

                              await ref
                                  .read(savingGoalsProvider.notifier)
                                  .addGoal(goal);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    dismissDirection:
                                        DismissDirection.horizontal,
                                    content: Text(
                                      'Meta de ahorro creada con éxito 🎉',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          widget.goalToEdit != null
                              ? 'Guardar Cambios'
                              : 'Comenzar a Ahorrar',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyChip(
    String key,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _autoDeductFrequency == key;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _autoDeductFrequency = key;
            if (key == 'weekly' && _autoDeductDay > 7) {
              _autoDeductDay = 1;
            } else if (key == 'biweekly' && _autoDeductDay > 15) {
              _autoDeductDay = 1;
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF10B981).withOpacity(0.2)
                : (isDark ? const Color(0xFF0F172A) : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF10B981)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? const Color(0xFF10B981)
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF065F46))
                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySelector(bool isDark) {
    final days = [
      {'val': 1, 'name': 'Lun'},
      {'val': 2, 'name': 'Mar'},
      {'val': 3, 'name': 'Mié'},
      {'val': 4, 'name': 'Jue'},
      {'val': 5, 'name': 'Vie'},
      {'val': 6, 'name': 'Sáb'},
      {'val': 7, 'name': 'Dom'},
    ];
    return Row(
      children: days.map((d) {
        final val = d['val'] as int;
        final name = d['name'] as String;
        final isSelected = _autoDeductDay == val;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _autoDeductDay = val);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF10B981)
                    : (isDark ? const Color(0xFF0F172A) : Colors.white),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Center(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B)),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayRangeStrip({
    required int startDay,
    required int endDay,
    required int selectedDay,
    required ValueChanged<int> onSelected,
    required bool isDark,
  }) {
    final count = endDay - startDay + 1;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final day = startDay + idx;
          final isSelected = selectedDay == day;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(day);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF10B981)
                    : (isDark ? const Color(0xFF0F172A) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF10B981)
                      : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF334155)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuincenaPresetChip(
    String label,
    int day1,
    int day2,
    bool isDark,
  ) {
    final isSelected = _autoDeductDay == day1 && _autoDeductDay2 == day2;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _autoDeductDay = day1;
            _autoDeductDay2 = day2;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF10B981).withOpacity(0.2)
                : (isDark ? const Color(0xFF0F172A) : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF10B981)
                  : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1)),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF10B981)
                    : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _buildSummaryText(String sym) {
    final amt = _autoDeductAmountController.text.trim().isNotEmpty
        ? '$sym${_autoDeductAmountController.text}'
        : '${sym}0.00';
    if (_autoDeductFrequency == 'weekly') {
      final names = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      final dayName = (_autoDeductDay >= 1 && _autoDeductDay <= 7) ? names[_autoDeductDay] : 'Lunes';
      return 'SAMI descontará $amt cada semana los $dayName y lo sumará a esta meta.';
    } else if (_autoDeductFrequency == 'biweekly') {
      return 'SAMI descontará $amt cada quincena (días $_autoDeductDay y $_autoDeductDay2) y lo sumará a esta meta.';
    } else {
      return 'SAMI descontará $amt cada mes el día $_autoDeductDay y lo sumará a esta meta.';
    }
  }
}
