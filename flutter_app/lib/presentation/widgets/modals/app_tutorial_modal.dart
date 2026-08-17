import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppTutorialModal extends ConsumerStatefulWidget {
  const AppTutorialModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => const AppTutorialModal(),
    );
  }

  @override
  ConsumerState<AppTutorialModal> createState() => _AppTutorialModalState();
}

class _AppTutorialModalState extends ConsumerState<AppTutorialModal> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Bienvenido a QUIVO',
      'subtitle': 'Tu libertad financiera inicia aquí',
      'description': 'Lleva un control milimétrico de tus finanzas. Interfaz rediseñada, reportes exclusivos y control total de tus ingresos y gastos en segundos.',
      'icon': LucideIcons.wallet,
      'color': const Color(0xFF3B82F6),
      'gradient': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
    },
    {
      'title': 'Sincronización Total',
      'subtitle': 'Trabaja por ti en el fondo',
      'description': 'Con el plan Premium, QUIVO lee las notificaciones de tus tarjetas para registrar tus gastos automáticamente, clasificando Débito y Crédito al instante.',
      'icon': LucideIcons.bellRing,
      'color': const Color(0xFF10B981),
      'gradient': [const Color(0xFF34D399), const Color(0xFF059669)],
    },
    {
      'title': 'Habla con Siri',
      'subtitle': 'Agrega gastos con tu voz',
      'description': 'Solo di "Oye Siri, Agregar a QUIVO". Dile cuánto gastaste y en qué, y QUIVO lo guardará en la nube sin que tengas que abrir la aplicación.',
      'icon': LucideIcons.mic,
      'color': const Color(0xFF8B5CF6),
      'gradient': [const Color(0xFFA78BFA), const Color(0xFF7C3AED)],
    },
    {
      'title': 'Reportes y PDF',
      'subtitle': 'Tus números, claros',
      'description': 'Exporta análisis financieros hermosos. Accede a vistas exclusivas de tus ingresos netos y balances mensuales detallados por categoría.',
      'icon': LucideIcons.fileBarChart2,
      'color': const Color(0xFFF59E0B),
      'gradient': [const Color(0xFFFBBF24), const Color(0xFFD97706)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final slide = _slides[_currentPage];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: size.width * 0.9,
            height: size.height * 0.8,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
            ),
            child: Stack(
              children: [
                // Background Gradient Splash
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          slide['color'].withValues(alpha: 0.3),
                          slide['color'].withValues(alpha: 0.0)
                        ],
                      ),
                    ),
                  ),
                ),
                
                Column(
                  children: [
                    // Top Bar (Skip)
                    Padding(
                      padding: const EdgeInsets.only(top: 24, right: 24, left: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Dots Indicator
                          Row(
                            children: List.generate(_slides.length, (index) {
                              final isActive = _currentPage == index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 6),
                                width: isActive ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive ? slide['color'] : Colors.grey.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Saltar', style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) => setState(() => _currentPage = index),
                        itemCount: _slides.length,
                        itemBuilder: (context, index) {
                          final currentSlide = _slides[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Animated Icon Container
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: 1.0 + (_pulseController.value * 0.05),
                                      child: Container(
                                        padding: const EdgeInsets.all(40),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: currentSlide['gradient'],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: currentSlide['color'].withValues(alpha: 0.4),
                                              blurRadius: 30,
                                              spreadRadius: 10 * _pulseController.value,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          currentSlide['icon'],
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 50),
                                // Text Content
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: currentSlide['color'].withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    currentSlide['subtitle'].toUpperCase(),
                                    style: TextStyle(
                                      color: currentSlide['color'],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  currentSlide['title'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  currentSlide['description'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Bottom Button
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: InkWell(
                        onTap: _nextPage,
                        borderRadius: BorderRadius.circular(24),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _slides[_currentPage]['color'],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _slides.length - 1 ? '¡Comenzar Aventura!' : 'Siguiente',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
