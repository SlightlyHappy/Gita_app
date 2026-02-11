import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';

/// Onboarding screen shown on first app launch.
/// Collects user name, preferred language, and transitions to the main app.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  String _selectedLanguage = 'en';
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    final provider = context.read<AppStateProvider>();
    final name = _nameController.text.trim();

    provider.setUserName(name.isNotEmpty ? name : 'Seeker');
    provider.setPreferredLanguage(_selectedLanguage);
    await provider.saveUserProfile();
    await provider.completeOnboarding();

    widget.onComplete();
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
              Color(0xFF3A321A),
              Color(0xFF221D10),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Star field
            const _StarField(),

            // Decorative glow — top
            Positioned(
              top: -80,
              right: -60,
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

            // Decorative glow — bottom
            Positioned(
              bottom: -40,
              left: -80,
              child: Container(
                width: 350,
                height: 350,
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

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // Mandala glow
                        _MandalaOrb(),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          AppStrings.onboardingTitle,
                          style: AppTextStyles.display.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          AppStrings.onboardingTitleAccent,
                          style: AppTextStyles.display.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          AppStrings.onboardingSubtitle,
                          style: AppTextStyles.sectionLabel.copyWith(
                            color: AppColors.primary.withAlpha(153),
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Name input
                        _GlassInput(
                          controller: _nameController,
                          hintText: AppStrings.onboardingNameHint,
                        ),

                        const SizedBox(height: 24),

                        // Language selector
                        _LanguageSelector(
                          selected: _selectedLanguage,
                          onChanged: (lang) {
                            setState(() => _selectedLanguage = lang);
                          },
                        ),

                        const SizedBox(height: 40),

                        // CTA button
                        _BeginButton(onTap: _handleComplete),

                        const Spacer(flex: 2),

                        // Swipe hint
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.keyboard_double_arrow_up,
                                color: AppColors.textWhite.withAlpha(102),
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.onboardingSwipeHint,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textWhite.withAlpha(102),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mandala Orb Widget ─────────────────────────────────────────────────────

class _MandalaOrb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(38),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          // Inner ring
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withAlpha(102),
                width: 2,
              ),
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withAlpha(25),
                  Colors.transparent,
                ],
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
    );
  }
}

// ─── Star Field Background ──────────────────────────────────────────────────

class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.15,
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _StarPainter(),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    // Deterministic star positions
    final stars = <Offset>[
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.08),
      Offset(size.width * 0.45, size.height * 0.12),
      Offset(size.width * 0.7, size.height * 0.3),
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.9, size.height * 0.55),
      Offset(size.width * 0.55, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.75),
      Offset(size.width * 0.8, size.height * 0.85),
      Offset(size.width * 0.35, size.height * 0.9),
      Offset(size.width * 0.05, size.height * 0.6),
      Offset(size.width * 0.65, size.height * 0.45),
      Offset(size.width * 0.3, size.height * 0.25),
      Offset(size.width * 0.95, size.height * 0.35),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.65),
      Offset(size.width * 0.4, size.height * 0.05),
      Offset(size.width * 0.6, size.height * 0.95),
    ];

    for (int i = 0; i < stars.length; i++) {
      final radius = (i % 3 == 0) ? 1.5 : 1.0;
      canvas.drawCircle(stars[i], radius, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => false;
}

// ─── Glass Input Field ──────────────────────────────────────────────────────

class _GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _GlassInput({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x08FFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withAlpha(51),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textWhite.withAlpha(51),
                      fontWeight: FontWeight.w300,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              Icon(
                Icons.self_improvement,
                color: AppColors.primary.withAlpha(178),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Language Selector Chips ────────────────────────────────────────────────

class _LanguageSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'PREFERRED LANGUAGE',
            style: AppTextStyles.sectionLabel.copyWith(
              color: AppColors.primary.withAlpha(178),
              fontSize: 10,
            ),
          ),
        ),
        Row(
          children: [
            _LanguageChip(
              label: 'English',
              value: 'en',
              isSelected: selected == 'en',
              onTap: () => onChanged('en'),
            ),
            const SizedBox(width: 10),
            _LanguageChip(
              label: 'Sanskrit',
              value: 'sa',
              isSelected: selected == 'sa',
              onTap: () => onChanged('sa'),
            ),
            const SizedBox(width: 10),
            _LanguageChip(
              label: 'Hindi',
              value: 'hi',
              isSelected: selected == 'hi',
              onTap: () => onChanged('hi'),
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : const Color(0x08FFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withAlpha(51),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.backgroundDark
                        : AppColors.textWhite.withAlpha(204),
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Begin Journey Button ───────────────────────────────────────────────────

class _BeginButton extends StatefulWidget {
  final VoidCallback onTap;

  const _BeginButton({required this.onTap});

  @override
  State<_BeginButton> createState() => _BeginButtonState();
}

class _BeginButtonState extends State<_BeginButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(76),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.onboardingCta,
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward,
                color: AppColors.backgroundDark,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
