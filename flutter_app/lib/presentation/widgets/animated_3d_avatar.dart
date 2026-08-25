import 'package:flutter/material.dart';

class Animated3DAvatar extends StatefulWidget {
  final String emoji;
  final double size;
  final VoidCallback? onTap;
  final bool isDark;

  const Animated3DAvatar({
    super.key,
    required this.emoji,
    required this.size,
    required this.isDark,
    this.onTap,
  });

  @override
  State<Animated3DAvatar> createState() => _Animated3DAvatarState();
}

class _Animated3DAvatarState extends State<Animated3DAvatar> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _isPressed ? 0 : _floatAnimation.value),
            child: AnimatedScale(
              scale: _isPressed ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isDark
                        ? [const Color(0xFF334155), const Color(0xFF0F172A)]
                        : [Colors.white, const Color(0xFFE2E8F0)],
                  ),
                  border: Border.all(
                    color: widget.isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white,
                    width: widget.size * 0.04,
                  ),
                  boxShadow: [
                    // Sombra principal (3D flotante)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: widget.isDark ? 0.5 : 0.15),
                      blurRadius: _isPressed ? 8 : 20,
                      offset: Offset(0, _isPressed ? 4 : 10),
                    ),
                    // Highlight interior superior izquierdo (luz)
                    BoxShadow(
                      color: widget.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                      blurRadius: 10,
                      offset: const Offset(-2, -2),
                    ),
                    // Sombra interior inferior derecha (profundidad)
                    BoxShadow(
                      color: widget.isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFF94A3B8).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(4, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.emoji,
                    style: TextStyle(
                      fontSize: widget.size * 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
