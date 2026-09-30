import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isDark;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    required this.isDark,
    this.borderRadius = 24.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.05) 
                  : Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.white.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
