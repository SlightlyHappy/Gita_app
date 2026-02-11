import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Full-screen loading / transition page used between chapter navigations
/// and other heavy transitions. Displays a rotating mandala with contextual
/// wisdom quotes and a progress indicator.
class LoadingTransitionScreen extends StatefulWidget {
  /// Text displayed as the main heading (shimmer effect).
  final String? heading;

  /// Italic sub-quote below heading.
  final String? subtitle;

  /// Duration before auto-dismiss. If null, must be popped manually.
  final Duration? autoDismissAfter;

  /// Called when the transition completes (auto-dismiss or manual).
  final VoidCallback? onComplete;

  const LoadingTransitionScreen({
    super.key,
    this.heading,
    this.subtitle,
    this.autoDismissAfter,
    this.onComplete,
  });

  @override
  State<LoadingTransitionScreen> createState() =>
      _LoadingTransitionScreenState();
}

class _LoadingTransitionScreenState extends State<LoadingTransitionScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: widget.autoDismissAfter ?? const Duration(seconds: 3),
    )..forward();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeIn = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    if (widget.autoDismissAfter != null) {
      _progressController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.3),
            radius: 1.8,
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF0A0A1A),
              Colors.black,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Star field
            const _TransitionStarField(),

            // Top gradient fade
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(128),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Bottom gradient fade
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha(128),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    // Top nav bar
                    _buildTopBar(),

                    const Spacer(),

                    // Central mandala + text
                    _buildCenterContent(),

                    const Spacer(),

                    // Progress footer
                    _buildProgressFooter(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Icon(
              Icons.close,
              color: AppColors.textWhite60,
              size: 24,
            ),
          ),
          const Spacer(),
          // Page indicator dots
          Row(
            children: [
              _dot(false),
              const SizedBox(width: 6),
              _dot(false),
              const SizedBox(width: 6),
              // Active pill
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 24), // balance the X button
        ],
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.primary.withAlpha(102),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCenterContent() {
    final heading =
        widget.heading ?? 'As Arjuna sought clarity...';
    final subtitle = widget.subtitle ??
        '...may you find peace in this moment of stillness.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rotating mandala
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow
                Container(
                  width: 200,
                  height: 200,
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
                // Rotating outer ring
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * pi,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withAlpha(51),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                // Counter-rotating inner ring
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: -_rotationController.value * 2 * pi * 0.7,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withAlpha(38),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                // Center icon
                Icon(
                  Icons.self_improvement,
                  size: 48,
                  color: AppColors.primary.withAlpha(200),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Shimmer heading
          Text(
            heading,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textWhite.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, _) {
          final progress = _progressController.value;
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
                    '${(progress * 100).round()}%',
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
                      widthFactor: progress,
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
              const SizedBox(height: 12),
              Text(
                AppStrings.loadingBreath,
                style: AppTextStyles.sectionLabel.copyWith(
                  color: AppColors.primary.withAlpha(102),
                  fontSize: 10,
                  letterSpacing: 4,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Star Field for Transition ──────────────────────────────────────────────

class _TransitionStarField extends StatelessWidget {
  const _TransitionStarField();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.3,
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _TransitionStarPainter(),
      ),
    );
  }
}

class _TransitionStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()..color = Colors.white;
    final goldPaint = Paint()..color = AppColors.primary;

    final stars = <Offset>[
      Offset(size.width * 0.12, size.height * 0.1),
      Offset(size.width * 0.88, size.height * 0.06),
      Offset(size.width * 0.5, size.height * 0.18),
      Offset(size.width * 0.72, size.height * 0.28),
      Offset(size.width * 0.22, size.height * 0.38),
      Offset(size.width * 0.92, size.height * 0.48),
      Offset(size.width * 0.38, size.height * 0.58),
      Offset(size.width * 0.08, size.height * 0.68),
      Offset(size.width * 0.78, size.height * 0.78),
      Offset(size.width * 0.48, size.height * 0.88),
      Offset(size.width * 0.62, size.height * 0.42),
      Offset(size.width * 0.28, size.height * 0.22),
    ];

    for (int i = 0; i < stars.length; i++) {
      final paint = (i % 4 == 0) ? goldPaint : whitePaint;
      final radius = (i % 3 == 0) ? 1.5 : 1.0;
      canvas.drawCircle(stars[i], radius, paint);
    }
  }

  @override
  bool shouldRepaint(_TransitionStarPainter old) => false;
}
