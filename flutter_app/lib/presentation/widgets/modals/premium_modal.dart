import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';

class PremiumModal extends ConsumerStatefulWidget {
  const PremiumModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
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
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  final features = [
    {'icon': LucideIcons.bellRing, 'text': 'Notificaciones inteligentes y Atajos Siri'},
    {'icon': LucideIcons.sliders, 'text': 'Límites de presupuesto avanzados'},
    {'icon': LucideIcons.palette, 'text': 'Personalización total y colores VIP'},
    {'icon': LucideIcons.bot, 'text': 'Asistente IA completo e interactivo'},
    {'icon': LucideIcons.mic, 'text': 'Registro ultra-rápido por VOZ'},
    {'icon': LucideIcons.fileSpreadsheet, 'text': 'Reportes exportables detallados'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.98, end: 1.02).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPremium = ref.watch(authProvider).user?.isPremium ?? false;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 300) Navigator.pop(context);
      },
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.2), blurRadius: 40, spreadRadius: -10)
          ]
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Column(
            children: [
              // Header
              Container(
                height: 220,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFF59E0B).withValues(alpha: 0.8),
                            (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)).withValues(alpha: 0.95),
                            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          ],
                        )
                      ),
                    ),
                    Positioned(
                      top: 16, left: 0, right: 0,
                      child: Center(
                        child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2))),
                      ),
                    ),
                    Positioned(
                      top: 16, right: 16,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
                          child: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: _scaleAnim,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5), width: 2),
                                ),
                                child: const Icon(LucideIcons.crown, color: Color(0xFFF59E0B), size: 40),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('QUIVO Premium', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                            Text('Eleva tu experiencia financiera', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    children: [
                      // Plan Unique Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: isDark 
                              ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E293B), Color(0xFF0F172A)])
                              : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)]),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                          ]
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('PLAN ÚNICO', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('\$1.99', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 36, fontWeight: FontWeight.w900, height: 1)),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4, left: 4),
                                      child: Text('/ mes', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(LucideIcons.sparkles, color: const Color(0xFFF59E0B).withValues(alpha: 0.5), size: 48),
                          ],
                        ),
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
                          childAspectRatio: 1.3,
                        ),
                        itemCount: features.length,
                        itemBuilder: (context, index) {
                          final f = features[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(f['icon'] as IconData, color: const Color(0xFFF59E0B), size: 24),
                                const Spacer(),
                                Text(f['text'] as String, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 12, fontWeight: FontWeight.w600, height: 1.2)),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // CTA
                      if (!isPremium)
                        GestureDetector(
                          onTap: () async {
                            await ref.read(authProvider.notifier).upgradeToPremium();
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Felicidades! Eres VIP 👑'), backgroundColor: Color(0xFFD97706)));
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEA580C)]),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: const Center(
                              child: Text('Desbloquear Todo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            ),
                          ),
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
                              Text('VIP Activado', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
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
                          child: const Text('Cancelar Suscripción', style: TextStyle(color: Colors.redAccent)),
                        )
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
