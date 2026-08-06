import 'package:flutter/material.dart';

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

class _TutorialOverlayState extends State<TutorialOverlay> with SingleTickerProviderStateMixin {
  int _currentStepIndex = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStepIndex < widget.steps.length - 1) {
      _controller.reset();
      setState(() {
        _currentStepIndex++;
      });
      _controller.forward();
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
        offset.dx - 8,
        offset.dy - 8,
        renderBox.size.width + 16,
        renderBox.size.height + 16,
      );
    }

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _nextStep,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _SpotlightPainter(
                    rect: highlightRect,
                    opacity: _animation.value,
                  ),
                ),
                if (highlightRect != Rect.zero)
                  Positioned(
                    top: step.textAlignment.y < 0 ? highlightRect.bottom + 20 : null,
                    bottom: step.textAlignment.y > 0 ? MediaQuery.of(context).size.height - highlightRect.top + 20 : null,
                    left: 24,
                    right: 24,
                    child: Opacity(
                      opacity: _animation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              step.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _currentStepIndex < widget.steps.length - 1 ? 'Siguiente' : 'Finalizar',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
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

class _SpotlightPainter extends CustomPainter {
  final Rect rect;
  final double opacity;

  _SpotlightPainter({required this.rect, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7 * opacity)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (rect != Rect.zero) {
      final spotlightPath = Path()
        ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)));
      
      final resultPath = Path.combine(PathOperation.difference, path, spotlightPath);
      canvas.drawPath(resultPath, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.rect != rect || oldDelegate.opacity != opacity;
  }
}
