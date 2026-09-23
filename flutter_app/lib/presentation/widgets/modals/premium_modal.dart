import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';

class PremiumModal extends ConsumerStatefulWidget {
  const PremiumModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumModal(),
    );
  }

  @override
  ConsumerState<PremiumModal> createState() => _PremiumModalState();
}

class _PremiumModalState extends ConsumerState<PremiumModal> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPremium = ref.watch(authProvider).user?.isPremium ?? false;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    final features = [
      {'icon': LucideIcons.infinity, 'title': 'Presupuestos\nIlimitados', 'desc': 'Sin restricciones'},
      {'icon': LucideIcons.bellRing, 'title': 'Recordatorios\nAvanzados', 'desc': 'No olvides nada'},
      {'icon': LucideIcons.lineChart, 'title': 'Estadísticas\nDetalladas', 'desc': 'Análisis profundo'},
      {'icon': LucideIcons.bot, 'title': 'Asistente IA\nPro', 'desc': 'Consejos 24/7'},
      {'icon': LucideIcons.palette, 'title': 'Personalización\nTotal', 'desc': 'Temas exclusivos'},
      {'icon': LucideIcons.sparkles, 'title': 'Proyección\ncon IA', 'desc': 'Predicciones a fin de mes'},
    ];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border(top: BorderSide(color: const Color(0xFFF59E0B).withValues(alpha: 0.3), width: 1)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Header Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.crown, color: Color(0xFFF59E0B), size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'QUIVO Premium',
                      style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lleva tus finanzas al siguiente nivel',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Pricing Card
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: isDark 
                                ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E293B), Color(0xFF0F172A)])
                                : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFFBEB), Color(0xFFFFFFFF)]),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5), width: 2),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 12)),
                            ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                                child: const Text('ACCESO TOTAL', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('\$0.99', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 48, fontWeight: FontWeight.w900, height: 1)),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6, left: 8),
                                    child: Text('/ mes', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Antes \$1.99', style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w600, decoration: TextDecoration.lineThrough)),
                            ],
                          ),
                        ),
                        // Bouncing Tag
                        Positioned(
                          top: -15,
                          right: -10,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: RotationTransition(
                              turns: const AlwaysStoppedAnimation(10 / 360),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFB91C1C)]),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: const Text('-50% DTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Features Grid
                    GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: features.length,
                      itemBuilder: (context, index) {
                        final f = features[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(f['icon'] as IconData, color: const Color(0xFFF59E0B), size: 24),
                              ),
                              const Spacer(),
                              Text(f['title'] as String, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w800, height: 1.2)),
                              const SizedBox(height: 4),
                              Text(f['desc'] as String, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // CTA
                    if (!isPremium)
                      _PremiumCTAButton(
                        onTap: () async {
                          await ref.read(authProvider.notifier).upgradeToPremium();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(dismissDirection: DismissDirection.horizontal, content: Text('¡Felicidades! Eres Premium 👑'), backgroundColor: Color(0xFFD97706)));
                          }
                        },
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.5), width: 2),
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
                    
                    if (isPremium) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () async {
                          await ref.read(authProvider.notifier).cancelSubscription();
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                        child: const Text('Cancelar Suscripción', style: TextStyle(fontWeight: FontWeight.w600)),
                      )
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumCTAButton extends StatefulWidget {
  final VoidCallback onTap;
  const _PremiumCTAButton({required this.onTap});

  @override
  State<_PremiumCTAButton> createState() => _PremiumCTAButtonState();
}

class _PremiumCTAButtonState extends State<_PremiumCTAButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEA580C)]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: const Center(
            child: Text('Obtener Premium', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ),
        ),
      ),
    );
  }
}
