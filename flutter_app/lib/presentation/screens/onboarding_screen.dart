import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'dart:ui';
import 'dart:math' as math;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  late final AnimationController _fadeController;
  late final AnimationController _floatController;
  
  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Control Total',
      'description': 'Lleva un registro preciso de tus gastos e ingresos con un dashboard inteligente y hermoso.',
      'icon': LucideIcons.pieChart,
      'colors': [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
      'bgGradient': [const Color(0xFF1E3A8A).withOpacity(0.15), const Color(0xFF172554).withOpacity(0.05)],
    },
    {
      'title': 'Inteligencia Artificial',
      'description': 'Analiza tu salud financiera y recibe consejos personalizados impulsados por IA.',
      'icon': LucideIcons.sparkles,
      'colors': [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      'bgGradient': [const Color(0xFF4C1D95).withOpacity(0.15), const Color(0xFF2E1065).withOpacity(0.05)],
    },
    {
      'title': 'Reportes y Metas',
      'description': 'Genera PDFs profesionales, ahorra para tus sueños y gestiona tus tarjetas de crédito.',
      'icon': LucideIcons.trendingUp,
      'colors': [const Color(0xFF10B981), const Color(0xFF047857)],
      'bgGradient': [const Color(0xFF064E3B).withOpacity(0.15), const Color(0xFF022C22).withOpacity(0.05)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (mounted) {
      final authState = ref.read(authProvider);
      if (authState.user != null) {
        context.go('/dashboard');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final page = _pages[_currentPage];
    final bgColors = page['bgGradient'] as List<Color>;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Animated Gradients
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? bgColors 
                    : [bgColors[0].withOpacity(0.05), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Floating background blobs
          Positioned(
            top: -100,
            left: -50,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * math.sin(_floatController.value * math.pi)),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (page['colors'] as List<Color>)[0].withOpacity(isDark ? 0.2 : 0.1),
                      boxShadow: [
                        BoxShadow(
                          color: (page['colors'] as List<Color>)[0].withOpacity(isDark ? 0.3 : 0.15),
                          blurRadius: 100,
                          spreadRadius: 20,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top header (Skip button)
                Padding(
                  padding: const EdgeInsets.only(top: 16, right: 24, left: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: _completeOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Omitir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                    ],
                  ),
                ),
                
                // PageView for content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      _fadeController.forward(from: 0.0);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPageContent(
                        _pages[index], 
                        isDark, 
                        index == _currentPage
                      );
                    },
                  ),
                ),
                
                // Bottom Controls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                  child: Column(
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 32 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? (page['colors'] as List<Color>)[0]
                                  : (isDark ? Colors.grey[800] : Colors.grey[300]),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Main Action Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: page['colors'] as List<Color>,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (page['colors'] as List<Color>)[0].withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (_currentPage == _pages.length - 1) {
                                _completeOnboarding();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutCubic,
                                );
                              }
                            },
                            child: Center(
                              child: Text(
                                _currentPage == _pages.length - 1 ? 'Empezar ahora' : 'Siguiente',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(Map<String, dynamic> page, bool isDark, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: AnimatedSlide(
              offset: isActive ? Offset.zero : const Offset(0, 0.2),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 10 * math.sin(_floatController.value * math.pi + 1.0)),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: (page['colors'] as List<Color>)[0].withOpacity(0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          )
                        ],
                        border: Border.all(
                          color: (page['colors'] as List<Color>)[0].withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        page['icon'] as IconData,
                        size: 80,
                        color: (page['colors'] as List<Color>)[0],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 60),
          
          // Text Content
          AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: const Interval(0.2, 1.0),
            child: AnimatedSlide(
              offset: isActive ? Offset.zero : const Offset(0, 0.2),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              child: Column(
                children: [
                  Text(
                    page['title'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    page['description'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
