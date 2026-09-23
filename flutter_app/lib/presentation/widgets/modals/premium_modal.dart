import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:confetti/confetti.dart';
import '../../providers/auth_provider.dart';

class PremiumModal extends ConsumerStatefulWidget {
  const PremiumModal({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PremiumModal',
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const PremiumModal(),
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
  ConsumerState<PremiumModal> createState() => _PremiumModalState();
}

class _PremiumModalState extends ConsumerState<PremiumModal> with TickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late AnimationController _bounceCtrl;
  late ConfettiController _confettiController;
  
  double _unlockProgress = 0.0;
  bool _isSuccess = false;

  final features = [
    {'icon': LucideIcons.bot, 'title': 'Amigo Financiero SAMI', 'desc': 'Asistente IA personalizado'},
    {'icon': LucideIcons.sparkles, 'title': 'Personalización Total', 'desc': 'Temas y colores exclusivos'},
    {'icon': LucideIcons.pieChart, 'title': 'Reportes Detallados', 'desc': 'Análisis profundo de gastos'},
    {'icon': LucideIcons.lineChart, 'title': 'Proyecciones Mensuales', 'desc': 'Predicciones inteligentes a fin de mes'},
  ];

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _bounceCtrl.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  double _getModalWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.9;
    return w > 420 ? 420 : w;
  }

  void _onUnlockComplete() async {
    await ref.read(authProvider.notifier).upgradeToPremium();
    if (mounted) {
      setState(() => _isSuccess = true);
      _confettiController.play();
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
    final isPremium = ref.watch(authProvider).user?.isPremium ?? false;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: _getModalWidth(context),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.2), blurRadius: 50, spreadRadius: -10),
                ],
                border: Border.all(color: const Color(0xFF1E293B), width: 1),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    top: -80,
                    left: -80,
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(_glowCtrl),
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [const Color(0xFFF59E0B).withOpacity(0.15), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _isSuccess ? _buildSuccessView(isDark) : _buildMainView(context, isDark, isPremium),
                  ),
                ],
              ),
            ),
            
            // Confetti Layer
            Positioned(
              top: -50,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 3.14159 / 2, // Straight down
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.2,
                colors: const [Colors.amber, Colors.orange, Colors.yellow, Colors.redAccent],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView(BuildContext context, bool isDark, bool isPremium) {
    return Padding(
      key: const ValueKey('MainView'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Price
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3), width: 2),
                ),
                child: Column(
                  children: [
                    Text('QUIVO Premium', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text('\$0.99', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1)),
                        Text('/mes', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Antes \$1.99', style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w600, decoration: TextDecoration.lineThrough)),
                  ],
                ),
              ),
              
              Positioned(
                top: -15,
                right: -10,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut)),
                  child: RotationTransition(
                    turns: const AlwaysStoppedAnimation(8 / 360),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Text('-50% DTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                for (int i = 0; i < features.length; i++) ...[
                  _buildFeatureRow(features[i]['icon'] as IconData, features[i]['title'] as String, features[i]['desc'] as String, isDark),
                  if (i < features.length - 1) const Divider(height: 20, color: Colors.transparent),
                ]
              ],
            ),
          ),
          const SizedBox(height: 32),

          if (!isPremium) ...[
            // Fake Button (Does nothing when tapped, just visual)
            AnimatedBuilder(
              animation: _glowCtrl,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.3 + (_glowCtrl.value * 0.2)), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Center(
                    child: Text('SUSCRIBIRSE AHORA', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildSwipeToUnlock(isDark),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.checkCircle2, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Suscripción Activa', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(isPremium ? 'Cerrar' : 'Quizás más tarde', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Padding(
      key: const ValueKey('SuccessView'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF59E0B), width: 4),
              ),
              child: const Icon(LucideIcons.crown, color: Color(0xFFF59E0B), size: 60),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '¡Felicidades!',
            style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Text(
            'Ahora eres Premium. Disfruta de todos tus nuevos beneficios financieros.',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String desc, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: const Color(0xFFF59E0B)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeToUnlock(bool isDark) {
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
              opacity: 1.0 - (_unlockProgress * 2).clamp(0.0, 1.0),
              child: Text('Desliza para ser Premium', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ),
          Positioned(
            left: 4 + (_unlockProgress * (_getModalWidth(context) - 48 - 48 - 8)),
            top: 4,
            bottom: 4,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _unlockProgress += details.delta.dx / (_getModalWidth(context) - 48 - 48 - 8);
                  _unlockProgress = _unlockProgress.clamp(0.0, 1.0);
                });
              },
              onPanEnd: (details) {
                if (_unlockProgress > 0.8) {
                  setState(() => _unlockProgress = 1.0);
                  _onUnlockComplete();
                } else {
                  setState(() => _unlockProgress = 0.0);
                }
              },
              child: Container(
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.3), blurRadius: 8)],
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
