import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RecurrenceSelectorWidget extends StatelessWidget {
  final bool isDark;
  final String? recurrenceType; // 'monthly', 'bimonthly', 'weekly', null if unselected
  final int recurrenceDay;
  final int? recurrenceDay2;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<int> onDayChanged;
  final ValueChanged<int>? onDay2Changed;
  final Color activeColor;

  const RecurrenceSelectorWidget({
    super.key,
    required this.isDark,
    required this.recurrenceType,
    required this.recurrenceDay,
    this.recurrenceDay2,
    required this.onTypeChanged,
    required this.onDayChanged,
    this.onDay2Changed,
    this.activeColor = const Color(0xFF6366F1),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frequency Segmented Cards
        Text(
          'Frecuencia de cobro 🔄',
          style: TextStyle(
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildFrequencyCard(
                type: 'monthly',
                label: 'Mensual',
                sublabel: '1 vez al mes',
                icon: LucideIcons.calendar,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFrequencyCard(
                type: 'bimonthly',
                label: 'Quincenal',
                sublabel: '2 al mes',
                icon: LucideIcons.calendarDays,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildFrequencyCard(
                type: 'weekly',
                label: 'Semanal',
                sublabel: 'Cada semana',
                icon: LucideIcons.calendarClock,
              ),
            ),
          ],
        ),
        if (recurrenceType != null) ...[
          const SizedBox(height: 20),

          // Day Selector Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF374151).withValues(alpha: 0.6) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recurrenceType == 'monthly') _buildMonthlySelector(),
                if (recurrenceType == 'bimonthly') _buildBimonthlySelector(),
                if (recurrenceType == 'weekly') _buildWeeklySelector(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFrequencyCard({
    required String type,
    required String label,
    required String sublabel,
    required IconData icon,
  }) {
    final isSelected = recurrenceType == type;
    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [activeColor, activeColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : (isDark ? const Color(0xFF1F2937) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? const Color(0xFF4B5563) : const Color(0xFFE2E8F0)),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                color: isSelected ? Colors.white.withValues(alpha: 0.8) : (isDark ? Colors.grey[400] : Colors.grey[600]),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Día exacto del mes 📅',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Día $recurrenceDay',
                style: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Toca un número para seleccionar el día de cobro automático:',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.0,
          ),
          itemCount: 31,
          itemBuilder: (context, index) {
            final day = index + 1;
            final isSelected = day == recurrenceDay;
            return GestureDetector(
              onTap: () => onDayChanged(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [activeColor, activeColor.withValues(alpha: 0.8)],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : (isDark ? const Color(0xFF1F2937) : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1)),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey[200] : Colors.grey[800]),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBimonthlySelector() {
    final day1 = recurrenceDay;
    final day2 = recurrenceDay2 ?? 16;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Días de cobro quincenal 🌓',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Elige los dos días del mes en que se realizarán los cobros:',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildBimonthlyDayPicker(
                title: '1er Cobro (1-15)',
                selectedDay: day1,
                minDay: 1,
                maxDay: 15,
                onChanged: onDayChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBimonthlyDayPicker(
                title: '2do Cobro (16-31)',
                selectedDay: day2,
                minDay: 16,
                maxDay: 31,
                onChanged: (val) {
                  if (onDay2Changed != null) onDay2Changed!(val);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBimonthlyDayPicker({
    required String title,
    required int selectedDay,
    required int minDay,
    required int maxDay,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Día $selectedDay',
                  style: TextStyle(
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(maxDay - minDay + 1, (index) {
              final day = minDay + index;
              final isSelected = day == selectedDay;
              return GestureDetector(
                onTap: () => onChanged(day),
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor
                        : (isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[300] : Colors.grey[700]),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySelector() {
    final weekDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Día de la semana 🔄',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                weekDays[(recurrenceDay.clamp(1, 7)) - 1],
                style: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Selecciona qué día se realizará el cobro cada semana:',
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final day = index + 1;
            final isSelected = day == recurrenceDay;
            return GestureDetector(
              onTap: () => onDayChanged(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [activeColor, activeColor.withValues(alpha: 0.8)],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : (isDark ? const Color(0xFF1F2937) : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1)),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  weekDays[index],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.grey[200] : Colors.grey[800]),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
