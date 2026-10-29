import 'package:flutter/material.dart';
import 'common/sami_avatar_widget.dart';

class Animated3DAvatar extends StatefulWidget {
  final String? avatarId;
  final String? emoji;
  final double size;
  final VoidCallback? onTap;
  final bool isDark;

  const Animated3DAvatar({
    super.key,
    this.avatarId,
    this.emoji,
    required this.size,
    required this.isDark,
    this.onTap,
  });

  @override
  State<Animated3DAvatar> createState() => _Animated3DAvatarState();
}

class _Animated3DAvatarState extends State<Animated3DAvatar>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveId = widget.avatarId ?? widget.emoji ?? 'sami_default';

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
              scale: _isPressed ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutBack,
              child: SamiAvatarWidget(
                avatarId: effectiveId,
                size: widget.size,
                isDark: widget.isDark,
                showAccessoryBadge: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
