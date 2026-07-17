import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import 'premium_modal.dart';

class AppTutorialModal extends ConsumerStatefulWidget {
  const AppTutorialModal({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
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
      'tag': 'VISTA GENERAL',
      'title': 'Tu Centro de Mando Financiero',
      'subtitle': 'Todo bajo control sin hojas de cálculo complicadas',
      'description':
          'Visualiza el saldo exacto de tu cuenta, monitorea el rendimiento de tus tarjetas y contrasta tus ingresos contra tus gastos en tiempo real. Un diseño limpio, ágil y pensado en tus metas.',
      'accent': Color(0xFF0284C7),
    },
    {
      'tag': 'ZENT AI • INTELIGENCIA DE VOZ',
      'title': 'Habla y la IA se encarga de todo',
      'subtitle': 'Exclusivo del Plan Premium • Cero digitación manual',
      'isPremium': true,
      'description':
          'Olvídate de abrir menús y llenar formularios. Solo presiona el micrófono y di: "Gasté 85 en Burger King con tarjeta". Nuestra Inteligencia Artificial extrae el monto, asigna el rubro exacto y lo registra al segundo.',
      'accent': Color(0xFF059669),
    },
    {
      'tag': 'CONTROL DE GASTOS',
      'title': 'Presupuestos que Sí se Cumplen',
      'subtitle': 'Topes por categoría con alertas oportunas antes del corte',
      'description':
          'Asigna un límite mensual inteligente para restaurantes, súper, entretenimiento y servicios. El sistema supervisa tu ritmo de gasto día y noche para avisarte antes de que superes tu meta.',
      'accent': Color(0xFF7C3AED),
    },
    {
      'tag': 'PRIVACIDAD TOTAL',
      'title': 'Tu Patrimonio Siempre Blindado',
      'subtitle': 'Biometría instantánea y auto-bloqueo por inactividad',
      'description':
          'Ingresa de forma veloz y segura usando Face ID o tu Huella Digital. Si dejas la aplicación en segundo plano o descuidada por más de un minuto, se bloqueará automáticamente por tu tranquilidad.',
      'accent': Color(0xFF2563EB),
    },
    {
      'tag': 'MEMBRESÍA VIP',
      'title': 'La Experiencia Definitiva Premium 👑',
      'subtitle': 'Desbloquea el máximo poder de la IA y personalización total',
      'isPremiumUpsell': true,
      'description':
          'Registro por voz inteligente ilimitado, sincronización en la nube multi-dispositivo, exportación de reportes formales en PDF/CSV y acceso ilimitado a todas las paletas de color de la tienda.',
      'accent': Color(0xFFD97706),
    },
  ];

  Future<void> _finishTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_app_tutorial', true);
    if (mounted) {
      await ref.read(authProvider.notifier).completeTour();
    }
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
    final bgColor = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF162032) : Colors.white;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 700,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? const Color(0xFF22304A) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              // Editorial Top Navigation & Progress Bar
              Container(
                padding: const EdgeInsets.fromLTRB(28, 22, 22, 18),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF22304A) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0284C7),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'GUÍA RÁPIDA DE INICIO',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : const Color(0xFF475569),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _finishTutorial,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Row(
                              children: [
                                Text(
                                  'Saltar introducción',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(LucideIcons.x, size: 15, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Multi-segment step bar
                    Row(
                      children: List.generate(_steps.length, (index) {
                        final isActive = index == _currentPage;
                        final isPast = index < _currentPage;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.only(right: index < _steps.length - 1 ? 6 : 0),
                            height: 4,
                            decoration: BoxDecoration(
                              color: isActive || isPast
                                  ? _steps[_currentPage]['accent']
                                  : (isDark ? const Color(0xFF22304A) : const Color(0xFFE2E8F0)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Main Editorial Slides View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    final step = _steps[index];
                    final Color accentColor = step['accent'];

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(32, 26, 32, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  step['tag'],
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              if (step['isPremium'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(LucideIcons.crown, size: 12, color: Colors.white),
                                      SizedBox(width: 5),
                                      Text('PLAN PREMIUM', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Editorial Title
                          Text(
                            step['title'],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              letterSpacing: -0.6,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            step['subtitle'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Bespoke Human-Crafted UI Component Illustration
                          _buildHumanCraftedIllustration(index, isDark, accentColor),

                          const SizedBox(height: 22),

                          // Natural conversational description
                          Text(
                            step['description'],
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.55,
                              color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                            ),
                          ),

                          if (step['isPremiumUpsell'] == true) ...[
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => PremiumModal.show(context),
                                icon: const Icon(LucideIcons.crown, color: Colors.white, size: 18),
                                label: const Text(
                                  'Conocer Beneficios y Explorar Planes Premium',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.5),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD97706),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 6,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Action Controls Bar
              Container(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 22),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? const Color(0xFF22304A) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton.icon(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: Icon(LucideIcons.arrowLeft, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[700]),
                        label: Text(
                          'Anterior',
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      const SizedBox(),
                    
                    ElevatedButton(
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
                        backgroundColor: _steps[_currentPage]['accent'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage < _steps.length - 1 ? 'Siguiente paso' : '¡Comenzar ahora!',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage < _steps.length - 1 ? LucideIcons.arrowRight : LucideIcons.check,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHumanCraftedIllustration(int index, bool isDark, Color accentColor) {
    switch (index) {
      case 0: // Balance Overview UI
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accentColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SALDO DISPONIBLE EN CUENTAS', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('\$ 24,850.00', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.6)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.trendingUp, size: 14, color: Color(0xFF10B981)),
                        SizedBox(width: 4),
                        Text('+14.2% mes', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF0F172A) : Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.arrowDownLeft, color: Color(0xFF10B981), size: 18),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ingresos', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                              Text('+\$6,400', style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF0F172A) : Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.arrowUpRight, color: Color(0xFFEF4444), size: 18),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gastos', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                              Text('-\$2,150', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 1: // Voice AI UI
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131D2E) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1120) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF059669).withValues(alpha: 0.15), shape: BoxShape.circle),
                      child: const Icon(LucideIcons.mic, color: Color(0xFF059669), size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Audio detectado (3 seg)...', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          SizedBox(height: 2),
                          Text('"Cena con amigos 180 quetzales con tarjeta"', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF059669).withValues(alpha: 0.18), const Color(0xFF10B981).withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('✨ Inteligencia Artificial ha registrado el gasto:', style: TextStyle(color: Color(0xFF10B981), fontSize: 11.5, fontWeight: FontWeight.w800)),
                          SizedBox(height: 3),
                          Text('🍔 Restaurantes • Q 180.00 • Tarjeta de Crédito', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 2: // Budgets & Alerts UI
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131D2E) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text('🍽️ Restaurantes y Salidas', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  Text('Q 820 / Q 1,000 [82%]', style: TextStyle(color: const Color(0xFFF59E0B), fontSize: 12.5, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 0.82,
                  minHeight: 10,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.bellRing, color: Color(0xFFF59E0B), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Te queda un margen de Q 180.00 en esta categoría antes de fin de mes.', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 3: // Security UI
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131D2E) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(LucideIcons.shieldCheck, color: Color(0xFF3B82F6), size: 36),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Autenticación y Cifrado Biométrico', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(
                      'Rostro (Face ID) o Huella Digital habilitados.',
                      style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.grey[700], fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: const Text('🔒 Auto-bloqueo activo tras 1 min de inactividad', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 4: // VIP Pass UI
      default:
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.6), width: 2),
            boxShadow: [
              BoxShadow(color: const Color(0xFFF59E0B).withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 10)),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.crown, color: Color(0xFFFCD34D), size: 24),
                      SizedBox(width: 10),
                      Text('PASAPORTE VIP INFINITY', style: TextStyle(color: Color(0xFFFCD34D), fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    ],
                  ),
                  Text('STATUS: ACTIVO', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800)),
                ],
              ),
              SizedBox(height: 14),
              Text(
                '• Asistente y registro de voz por IA ilimitados\n• Reportes financieros en PDF/CSV al instante\n• Sincronización multi-dispositivo segura en la nube\n• Acceso a todas las paletas de color y temas VIP',
                style: TextStyle(color: Colors.white, fontSize: 13, height: 1.6, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
    }
  }
}
