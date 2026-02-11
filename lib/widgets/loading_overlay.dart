import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Loading state types for contextual overlay variants.
enum LoadingType {
  /// Default: rotating mandala with cycling quotes.
  defaultLoading,

  /// Chapter navigation transition.
  navigation,

  /// Word-by-word quote reveal.
  quoteReveal,

  /// Empty / no results state.
  empty,
}

/// Reusable loading overlay widget with contextual variants.
/// Use over any screen to indicate loading with a spiritual aesthetic.
class LoadingOverlay extends StatefulWidget {
  final LoadingType type;
  final String? message;
  final double? progress;
  final VoidCallback? onDismiss;

  const LoadingOverlay({
    super.key,
    this.type = LoadingType.defaultLoading,
    this.message,
    this.progress,
    this.onDismiss,
  });

  /// Show as a modal overlay on top of the current screen.
  static Future<void> show(
    BuildContext context, {
    LoadingType type = LoadingType.defaultLoading,
    String? message,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.backgroundDark.withAlpha(200),
      builder: (_) => LoadingOverlay(type: type, message: message),
    );
  }

  /// Dismiss the loading overlay.
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  // Inspirational quotes that cycle
  static const List<String> _quotes = [
    'As the sun illuminates, so does wisdom...',
    'Be still, and know the Self within...',
    'The soul is neither born, nor does it die...',
    'Action is the foundation of success...',
    'In the depths of stillness, truth reveals itself...',
    'Surrender the fruits of action...',
  ];

  int _currentQuoteIndex = 0;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Cycle quotes every 3 seconds
    _quoteTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _currentQuoteIndex =
              (_currentQuoteIndex + 1) % _quotes.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _quoteTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVisual(),
            const SizedBox(height: 32),
            _buildText(),
            if (widget.progress != null) ...[
              const SizedBox(height: 24),
              _buildProgressBar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisual() {
    switch (widget.type) {
      case LoadingType.defaultLoading:
      case LoadingType.navigation:
        return _buildMandala();
      case LoadingType.quoteReveal:
        return _buildQuoteRevealIcon();
      case LoadingType.empty:
        return _buildEmptyState();
    }
  }

  Widget _buildMandala() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(38),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Rotating ring
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * pi,
                child: child,
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withAlpha(76),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cardinal dots
                  for (int i = 0; i < 4; i++)
                    Positioned(
                      top: i == 0 ? 0 : null,
                      bottom: i == 2 ? 0 : null,
                      left: i == 3 ? 0 : null,
                      right: i == 1 ? 0 : null,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(153),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Center icon
          Icon(
            Icons.self_improvement,
            size: 36,
            color: AppColors.primary.withAlpha(200),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteRevealIcon() {
    return Icon(
      Icons.auto_stories,
      size: 64,
      color: AppColors.primary.withAlpha(178),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: AppDecorations.glassCircle(
            borderColor: AppColors.glassBorder,
          ),
          child: const Icon(
            Icons.search_off,
            size: 36,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildText() {
    switch (widget.type) {
      case LoadingType.defaultLoading:
      case LoadingType.navigation:
        return Column(
          children: [
            // Shimmer quote text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                widget.message ?? _quotes[_currentQuoteIndex],
                key: ValueKey<int>(_currentQuoteIndex),
                textAlign: TextAlign.center,
                style: AppTextStyles.quoteText.copyWith(
                  color: AppColors.textWhite.withAlpha(204),
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.loadingBreath,
              style: AppTextStyles.sectionLabel.copyWith(
                color: AppColors.primary.withAlpha(102),
                fontSize: 10,
              ),
            ),
          ],
        );

      case LoadingType.quoteReveal:
        return Text(
          widget.message ?? 'Revealing wisdom...',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textWhite70,
          ),
        );

      case LoadingType.empty:
        return Column(
          children: [
            Text(
              widget.message ?? 'No results found',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The cosmos holds infinite wisdom — try a different search',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        );
    }
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.loadingPreparing,
              style: AppTextStyles.sectionLabel.copyWith(
                color: AppColors.primary.withAlpha(153),
                fontSize: 10,
              ),
            ),
            Text(
              '${(widget.progress! * 100).round()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Container(
            height: 2,
            color: AppColors.primary.withAlpha(25),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: widget.progress!.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(128),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
