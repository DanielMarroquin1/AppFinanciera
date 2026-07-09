import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../premium_modal.dart';

class AppTutorialModal extends ConsumerStatefulWidget {
  const AppTutorialModal({super.key});

  static Future<void> show(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AppTutorialModal(),
    );
  }

  @override
  ConsumerState<AppTutorialModal> createState() => _AppTutorialModalState();
}

class _AppTutorialModalState extends ConsumerState<AppTutorialModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'icon': LucideIcons.pieChart,
      'color': Color(0xFF38BDF8),
      'title': '1. Control Total en un Solo Dashboard',
      'subtitle': 'Finanzas claras y en tiempo real',
      'description':
          'Visualiza el balance de tu cuenta, ingresos, gastos y el estado de todas tus Tarjetas de Crédito en una interfaz limpia, premium y sin complicaciones.',
    },
    {
      'icon': LucideIcons.mic,
      'color': Color(0xFF10B981),
      'title': '2. Registro por Voz Inteligente con IA',
      'subtitle': '👑 Exclusivo con el Plan Premium • Cero digitación',
      'isPremiumFeature': true,
      'description':
          'Toca el micrófono y habla naturalmente: "Gasté 45 quetzales en Burger King con tarjeta" o "Compré gas por 125". Nuestra IA procesa y registra todo en segundos. (Exclusivo para usuarios con Plan Premium)',
    },
    {
      'icon': LucideIcons.creditCard,
      'color': Color(0xFF8B5CF6),
      'title': '3. Tarjetas, Deudas e Ingresos Fijos',
      'subtitle': 'Gestión automatizada de compromisos',
      'description':
          'Organiza tus fechas de corte, configura cobros automáticos para suscripciones o préstamos y recibe alertas oportunas para que nunca pagues intereses de más.',
    },
    {
      'icon': LucideIcons.shieldCheck,
      'color': Color(0xFF3B82F6),
      'title': '4. Seguridad y Autenticación Biométrica',
      'subtitle': 'Tu patrimonio siempre protegido',
      'description':
          'Entra al instante con tu Huella Digital o Face ID. Además, si dejas la aplicación inactiva por 1 minuto, se bloqueará automáticamente para proteger tus datos.',
    },
    {
      'icon': LucideIcons.crown,
      'color': Color(0xFFF59E0B),
      'title': '5. Desbloquea el Poder Total con Premium 👑',
      'subtitle': 'Potencia tu control financiero al máximo nivel',
      'isPremiumUpsell': true,
      'description':
          'Obtén Registro por Voz Ilimitado con IA, sincronización multi-dispositivo en la nube, reportes exportables en PDF/CSV y personalización PRO de paletas de colores.',
    },
  ];

  Future<void> _finishTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_app_tutorial', true);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 14, bottom: 8),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Header Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.compass, size: 14, color: Color(0xFF38BDF8)),
                      SizedBox(width: 6),
                      Text(
                        'GUÍA RÁPIDA DE FINANZAS',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _finishTutorial,
                  child: Text(
                    'Omitir',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Carousel Pages
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                final Color stepColor = step['color'];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glowing Icon Emblem
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: stepColor.withValues(alpha: isDark ? 0.2 : 0.12),
                          border: Border.all(color: stepColor.withValues(alpha: 0.4), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: stepColor.withValues(alpha: 0.3),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            step['icon'],
                            size: 52,
                            color: stepColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Premium Feature Badge (For step 2)
                      if (step['isPremiumFeature'] == true) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.35), blurRadius: 8),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.crown, size: 13, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                'FUNCIÓN EXCLUSIVA PLAN PREMIUM',
                                style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.6),
                              ),
                            ],
                          ),
                        ),
                      ],

                      Text(
                        step['title'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step['subtitle'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: stepColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        step['description'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),

                      // Premium Upsell CTA Button inside slide 5
                      if (step['isPremiumUpsell'] == true) ...[
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () {
                            PremiumModal.show(context);
                          },
                          icon: const Icon(LucideIcons.crown, color: Colors.white, size: 18),
                          label: const Text(
                            'Ver Planes y Suscribirme a Premium',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 6,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Indicators & Navigation Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: isActive ? 28 : 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF38BDF8)
                            : (isDark ? Colors.grey[700] : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (_currentPage > 0) ...[
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'Anterior',
                            style: TextStyle(
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < _steps.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _finishTutorial();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF0284C7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: Text(
                          _currentPage < _steps.length - 1 ? 'Siguiente' : '¡Comenzar a Usar!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
