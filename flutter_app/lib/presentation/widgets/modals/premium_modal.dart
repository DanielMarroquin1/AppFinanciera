import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import 'premium_sync_hub_modal.dart';

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

class _PremiumModalState extends ConsumerState<PremiumModal> {
  String selectedPlan = 'annual';

  final features = [
    {'icon': LucideIcons.bellRing, 'text': 'Lector de notificaciones (Android) y Atajos de Siri (iOS)'},
    {'icon': LucideIcons.sliders, 'text': 'Límite de presupuesto mensual y por categoría'},
    {'icon': LucideIcons.palette, 'text': 'Apariencia y paletas de colores VIP'},
    {'icon': LucideIcons.sparkles, 'text': 'Asistente IA, Simulador "What If" y Botón IA de Ahorros'},
    {'icon': LucideIcons.mic, 'text': 'Registro inteligente de gastos por VOZ'},
    {'icon': LucideIcons.filter, 'text': 'Filtros avanzados en reportes de gastos'},
    {'icon': LucideIcons.fileSpreadsheet, 'text': 'Reporte mensual detallado del balance general'},
    {'icon': LucideIcons.zap, 'text': 'Experiencia sin límites publicitarios'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPremium = ref.watch(authProvider).user?.isPremium ?? false;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFC2410C)]) // amber-600 to orange-700
                  : const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF97316)]), // amber-400 to orange-500
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(LucideIcons.x, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: 64, height: 64,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(LucideIcons.crown, color: Colors.white, size: 40),
                    ),
                    const Text('Hazte Premium', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Desbloquea todo el potencial de tu app financiera', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14), textAlign: TextAlign.center),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Plan Selection Modern Redesign
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedPlan = 'monthly'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                              decoration: BoxDecoration(
                                gradient: selectedPlan == 'monthly'
                                    ? (isDark
                                        ? const LinearGradient(colors: [Color(0xFF334155), Color(0xFF1E293B)])
                                        : const LinearGradient(colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)]))
                                    : null,
                                color: selectedPlan != 'monthly'
                                    ? (isDark ? const Color(0xFF111827) : Colors.white)
                                    : null,
                                border: Border.all(
                                  color: selectedPlan == 'monthly'
                                      ? (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706))
                                      : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                                  width: selectedPlan == 'monthly' ? 2 : 1.5,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: selectedPlan == 'monthly'
                                    ? [BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))]
                                    : [],
                              ),
                              child: Column(
                                children: [
                                  Text('Plan Mensual', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text('\$1.99', style: TextStyle(color: selectedPlan == 'monthly' ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)) : (isDark ? Colors.white : Colors.black), fontSize: 28, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 4),
                                  Text('Facturado mes a mes', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedPlan = 'annual'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                              decoration: BoxDecoration(
                                gradient: selectedPlan == 'annual'
                                    ? (isDark
                                        ? const LinearGradient(colors: [Color(0xFF451A03), Color(0xFF78350F)])
                                        : const LinearGradient(colors: [Color(0xFFFef08a), Color(0xFFFDE047)]))
                                    : null,
                                color: selectedPlan != 'annual'
                                    ? (isDark ? const Color(0xFF111827) : Colors.white)
                                    : null,
                                border: Border.all(
                                  color: selectedPlan == 'annual'
                                      ? (isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706))
                                      : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                                  width: selectedPlan == 'annual' ? 2 : 1.5,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: selectedPlan == 'annual'
                                    ? [BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]
                                    : [],
                              ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    top: -30, right: -12, left: -12,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
                                        ),
                                        child: const Text('AHORRA \$3.89', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text('Plan Anual', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text('\$19.99', style: TextStyle(color: selectedPlan == 'annual' ? (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)) : (isDark ? Colors.white : Colors.black), fontSize: 28, fontWeight: FontWeight.w900)),
                                      const SizedBox(height: 4),
                                      Text('Facturado anualmente', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Features list updated
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Beneficios Exclusivos:', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                        ...features.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF374151) : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                                child: Icon(f['icon'] as IconData, color: const Color(0xFFF59E0B), size: 18),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Text(f['text'] as String, style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[800], fontSize: 13.5, fontWeight: FontWeight.w600))),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary Redesign
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: isDark ? const LinearGradient(colors: [Color(0xFF111827), Color(0xFF1F2937)]) : const LinearGradient(colors: [Color(0xFFF1F5F9), Color(0xFFF8FAFC)]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedPlan == 'monthly' ? 'Total hoy (Mensual)' : 'Total hoy (Anual)', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, fontWeight: FontWeight.bold)),
                            Text(selectedPlan == 'monthly' ? '\$1.99' : '\$19.99', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        if (selectedPlan == 'annual') ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Equivalente mensual', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12)),
                              Text('\$1.66 / mes', style: TextStyle(color: const Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  if (!isPremium) ...[
                    Builder(
                      builder: (context) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 1.0, end: 1.02),
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: child,
                            );
                          },
                          onEnd: () {
                            // Este setState o rediseño forzaría el re-render infinito para latir,
                            // pero como no tenemos un AnimationController aquí, lo dejaremos como 
                            // un pequeño pop y un brillo. Usaremos solo un botón super vibrante.
                          },
                          child: GestureDetector(
                            onTap: () async {
                              await ref.read(authProvider.notifier).upgradeToPremium();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('👑 ¡Felicidades! Has actualizado al Plan Premium. Disfruta de todas las funciones exclusivas.'),
                                    backgroundColor: Color(0xFFD97706),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                gradient: isDark 
                                    ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEA580C)]) 
                                    : const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF97316)]),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.6), blurRadius: 16, offset: const Offset(0, 6)),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.crown, color: Colors.white, size: 24),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Suscribirme al Plan Premium', 
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 12),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        border: Border.all(color: Colors.green, width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.checkCircle2, color: Colors.green, size: 22),
                          SizedBox(width: 8),
                          Text('Ya tienes el Plan Premium Activo 👑', style: TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],


                  // Test cancel / subscription management
                  TextButton.icon(
                    onPressed: () async {
                      if (isPremium) {
                        await ref.read(authProvider.notifier).cancelSubscription();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Suscripción Premium cancelada correctamente para pruebas.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(isPremium ? LucideIcons.xCircle : LucideIcons.arrowLeft, color: isPremium ? Colors.redAccent : (isDark ? Colors.grey[400] : Colors.grey[600]), size: 16),
                    label: Text(
                      isPremium ? 'Cancelar Suscripción (Para Probar)' : 'Volver atrás',
                      style: TextStyle(color: isPremium ? Colors.redAccent : (isDark ? Colors.grey[400] : Colors.grey[600]), fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Cancela cuando quieras. Sin compromisos.', style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[500], fontSize: 12), textAlign: TextAlign.center),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
