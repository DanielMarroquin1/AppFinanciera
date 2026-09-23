import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';

class CancelPremiumDialog extends ConsumerStatefulWidget {
  const CancelPremiumDialog({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'CancelPremium',
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const CancelPremiumDialog(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10 * anim1.value, sigmaY: 10 * anim1.value),
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: anim1, child: child),
          ),
        );
      },
    );
  }

  @override
  ConsumerState<CancelPremiumDialog> createState() => _CancelPremiumDialogState();
}

class _CancelPremiumDialogState extends ConsumerState<CancelPremiumDialog> with TickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late AnimationController _glowCtrl;
  double _cancelProgress = 0.0;
  bool _isCanceled = false;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  double _getModalWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.9;
    return w > 400 ? 400 : w;
  }

  void _onCancelComplete() async {
    await ref.read(authProvider.notifier).cancelSubscription();
    if (mounted) {
      setState(() => _isCanceled = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: _getModalWidth(context),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.2),
                blurRadius: 50,
                spreadRadius: -10,
              ),
            ],
            border: Border.all(color: const Color(0xFF1E293B), width: 1),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                top: -50,
                right: -50,
                child: RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(_glowCtrl),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFEF4444).withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _isCanceled ? _buildCanceledView(isDark) : _buildMainView(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainView(bool isDark) {
    return Padding(
      key: const ValueKey('MainView'),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Header
          AnimatedBuilder(
            animation: _shakeCtrl,
            builder: (context, child) {
              return Transform.rotate(
                angle: (_shakeCtrl.value - 0.5) * 0.1,
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3), width: 2),
                  ),
                ),
                const Icon(LucideIcons.heartCrack, color: Color(0xFFEF4444), size: 40),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            '¡No te vayas!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Perderás tus súper poderes financieros al instante. Mira lo que dejas atrás:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Feature List
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _buildLostFeature(LucideIcons.bot, 'Amigo Financiero SAMI con IA', isDark),
                const Divider(height: 16, color: Colors.transparent),
                _buildLostFeature(LucideIcons.sparkles, 'Temas y Personalización Total', isDark),
                const Divider(height: 16, color: Colors.transparent),
                _buildLostFeature(LucideIcons.pieChart, 'Reportes Detallados', isDark),
                const Divider(height: 16, color: Colors.transparent),
                _buildLostFeature(LucideIcons.lineChart, 'Proyecciones Mensuales', isDark),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Keep Premium Button (Big & Bouncy)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3 + (_glowCtrl.value * 0.2)),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'MANTENER SUSCRIPCIÓN PREMIUM',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Swipe to Cancel
          _buildSwipeToCancel(isDark),
        ],
      ),
    );
  }

  Widget _buildCanceledView(bool isDark) {
    return Padding(
      key: const ValueKey('CanceledView'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.frown, color: Colors.grey, size: 60),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Suscripción Cancelada',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Text(
            'Lamentamos verte partir. Siempre podrás volver a suscribirte cuando quieras.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLostFeature(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[700]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.lineThrough,
              decorationColor: const Color(0xFFEF4444).withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeToCancel(bool isDark) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 1.0 - (_cancelProgress * 2).clamp(0.0, 1.0),
              child: Text(
                'Desliza para cancelar',
                style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            left: 4 + (_cancelProgress * (_getModalWidth(context) - 60 - 30 - 30)),
            top: 4,
            bottom: 4,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _cancelProgress += details.delta.dx / (_getModalWidth(context) - 60 - 30 - 30);
                  _cancelProgress = _cancelProgress.clamp(0.0, 1.0);
                });
              },
              onPanEnd: (details) {
                if (_cancelProgress > 0.8) {
                  setState(() => _cancelProgress = 1.0);
                  _onCancelComplete();
                } else {
                  setState(() => _cancelProgress = 0.0);
                }
              },
              child: Container(
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.3), blurRadius: 8),
                  ],
                ),
                child: const Icon(LucideIcons.chevronRight, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
