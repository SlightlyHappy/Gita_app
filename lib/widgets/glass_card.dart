import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Reusable glass morphism container widget.
/// Wraps its child with semi-transparent background, blur, and gold border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final bool featured;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.borderColor,
    this.padding = const EdgeInsets.all(24),
    this.featured = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: AppDecorations.glass(
              borderRadius: borderRadius,
              borderColor: borderColor,
              featured: featured,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
