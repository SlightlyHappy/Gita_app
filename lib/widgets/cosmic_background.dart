import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Full-screen cosmic background with radial gradient and gold glow accents.
/// Wraps its child in a Stack with decorative positioned glow circles.
class CosmicBackground extends StatelessWidget {
  final Widget child;
  final bool useSettingsGradient;

  const CosmicBackground({
    super.key,
    required this.child,
    this.useSettingsGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: useSettingsGradient
          ? AppDecorations.settingsGradient()
          : AppDecorations.cosmicGradient(),
      child: Stack(
        children: [
          // Top-left gold glow
          Positioned(
            top: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withAlpha(20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom-right gold glow
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withAlpha(13),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main child
          child,
        ],
      ),
    );
  }
}
