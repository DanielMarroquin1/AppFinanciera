import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/localization.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import 'premium_paywall_dialog.dart';

class BudgetLimitModal extends ConsumerStatefulWidget {
  final double initialValue;

  const BudgetLimitModal({
    super.key,
    required this.initialValue,
  });

  static Future<double?> show(BuildContext context, {required double initialValue}) {
    final container = ProviderScope.containerOf(context, listen: false);
    final isPremium = container.read(authProvider).user?.isPremium ?? false;
    if (!isPremium) {
      PremiumPaywallDialog.show(context, customMessage: 'Establece un límite de presupuesto mensual personalizado con el Plan Premium.');
      return Future.value(null);
    }
    return showDialog<double>(
      context: context,
      builder: (context) => BudgetLimitModal(initialValue: initialValue),
    );
  }

  @override
  ConsumerState<BudgetLimitModal> createState() => _BudgetLimitModalState();
}

class _BudgetLimitModalState extends ConsumerState<BudgetLimitModal> {
  double _currentValue = 80;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    if (_currentValue < 50) _currentValue = 50;
    if (_currentValue > 100) _currentValue = 100;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = ref.read(localizationProvider);

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
                        loc.get('budget_alert_title'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        loc.get('adjust_limit'),
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
              loc.get('set_max_budget'),
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            
            // Circular Dial / Velocimeter
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 20,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: _currentValue / 100,
                      strokeWidth: 20,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _currentValue >= 90
                            ? const Color(0xFFEF4444)
                            : (_currentValue >= 80 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_currentValue.toInt()}%',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        loc.get('of_income'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Sleek Slider
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 8,
                  activeTrackColor: _currentValue >= 90
                      ? const Color(0xFFEF4444)
                      : (_currentValue >= 80 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                  inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  thumbColor: Colors.white,
                  overlayColor: (_currentValue >= 90
                          ? const Color(0xFFEF4444)
                          : (_currentValue >= 80 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)))
                      .withValues(alpha: 0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14, elevation: 4),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                ),
                child: Slider(
                  value: _currentValue,
                  min: 50,
                  max: 100,
                  divisions: 50,
                  onChanged: (value) {
                    setState(() {
                      _currentValue = value;
                    });
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('50%', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontWeight: FontWeight.bold)),
                  Text('100%', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
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
                      loc.get('cancel'),
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
                    onPressed: () {
                      Navigator.of(context).pop(_currentValue);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFFD97706) : const Color(0xFFF59E0B), // amber
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      loc.get('save'),
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
