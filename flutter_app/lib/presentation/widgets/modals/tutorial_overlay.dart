import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_icons/lucide_icons.dart';

class TutorialStep {
  final GlobalKey key;
  final String title;
  final String description;
  final Alignment textAlignment;

  TutorialStep({
    required this.key,
    required this.title,
    required this.description,
    this.textAlignment = Alignment.bottomCenter,
  });
}

class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onFinish;

  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.onFinish,
  });

  static void show(BuildContext context, List<TutorialStep> steps, VoidCallback onFinish) {
    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => TutorialOverlay(
        steps: steps,
        onFinish: () {
          overlayEntry.remove();
          onFinish();
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> with TickerProviderStateMixin {
  int _currentStepIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStepIndex < widget.steps.length - 1) {
      _fadeController.reset();
      setState(() {
        _currentStepIndex++;
      });
      _fadeController.forward();
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentStepIndex];
    final RenderBox? renderBox = step.key.currentContext?.findRenderObject() as RenderBox?;
    
    Rect highlightRect = Rect.zero;
    if (renderBox != null) {
      final offset = renderBox.localToGlobal(Offset.zero);
      highlightRect = Rect.fromLTWH(
        offset.dx - 12,
        offset.dy - 12,
        renderBox.size.width + 24,
        renderBox.size.height + 24,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _nextStep,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([_fadeAnimation, _pulseAnimation]),
          builder: (context, child) {
            return Stack(
              children: [
                // Blurred background with spotlight
                ClipPath(
                  clipper: _InvertedRectClipper(highlightRect),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      color: (isDark ? Colors.black : const Color(0xFF0F172A)).withValues(alpha: 0.65 * _fadeAnimation.value),
                    ),
                  ),
                ),
                
                // Pulsing highlight ring
                if (highlightRect != Rect.zero)
                  Positioned.fromRect(
                    rect: highlightRect.inflate(10 * _pulseAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value * 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),

                // Tooltip Card
                if (highlightRect != Rect.zero)
                  Positioned(
                    top: step.textAlignment.y < 0 ? highlightRect.bottom + 24 : null,
                    bottom: step.textAlignment.y > 0 ? MediaQuery.of(context).size.height - highlightRect.top + 24 : null,
                    left: 24,
                    right: 24,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - _fadeAnimation.value)),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(LucideIcons.sparkles, color: Color(0xFF3B82F6), size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      step.title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                step.description,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: isDark ? Colors.grey[300] : const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: List.generate(widget.steps.length, (index) {
                                      final active = index == _currentStepIndex;
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.only(right: 6),
                                        height: 6,
                                        width: active ? 20 : 6,
                                        decoration: BoxDecoration(
                                          color: active ? const Color(0xFF3B82F6) : (isDark ? Colors.grey[700] : Colors.grey[300]),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      );
                                    }),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(color: const Color(0xFF3B82F6).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          _currentStepIndex < widget.steps.length - 1 ? 'Siguiente' : 'Finalizar',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(LucideIcons.arrowRight, color: Colors.white, size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InvertedRectClipper extends CustomClipper<Path> {
  final Rect rect;

  _InvertedRectClipper(this.rect);

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant _InvertedRectClipper oldClipper) {
    return oldClipper.rect != rect;
  }
}
