import 'package:flutter/material.dart';

// ─── Color Palette ───────────────────────────────────────────────────────────

class AppColors {
  // Primary
  static const Color primary = Color(0xFFECB613);
  static const Color primaryDim = Color(0x80ECB613); // 50%
  static const Color primarySubtle = Color(0x33ECB613); // 20%
  static const Color primaryGhost = Color(0x1AECB613); // 10%

  // Backgrounds
  static const Color backgroundDark = Color(0xFF0A0A1A);
  static const Color backgroundDarkAlt = Color(0xFF221D10);
  static const Color backgroundDarkDeep = Color(0xFF16140D);
  static const Color backgroundLight = Color(0xFFF8F8F6);
  static const Color cosmicIndigo = Color(0xFF1E1B4B);

  // Surface / Glass
  static const Color glassBg = Color(0x0DFFFFFF); // white 5%
  static const Color glassBorder = Color(0x33ECB613); // primary 20%
  static const Color glassBorderLight = Color(0x1AFFFFFF); // white 10%
  static const Color glassBadgeBg = Color(0x26ECB613); // primary 15%
  static const Color glassBadgeBorder = Color(0x66ECB613); // primary 40%

  // Text
  static const Color textWhite = Colors.white;
  static const Color textWhite90 = Color(0xE6FFFFFF);
  static const Color textWhite70 = Color(0xB3FFFFFF);
  static const Color textWhite60 = Color(0x99FFFFFF);
  static const Color textWhite40 = Color(0x66FFFFFF);
  static const Color textWhite20 = Color(0x33FFFFFF);
  static const Color textDark = Color(0xFF333333);

  // Semantic
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);

  // Secondary accent
  static const Color secondaryPurple = Color(0xFF7C3AED);
}

// ─── Glass Morphism Decorations ─────────────────────────────────────────────

class AppDecorations {
  static BoxDecoration glass({
    double borderRadius = 16,
    Color? borderColor,
    bool featured = false,
  }) {
    return BoxDecoration(
      color: AppColors.glassBg,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ??
            (featured ? AppColors.glassBorder : AppColors.glassBorderLight),
        width: 1,
      ),
      boxShadow: featured
          ? [
              const BoxShadow(
                color: Color(0xCC000000),
                blurRadius: 32,
                offset: Offset(0, 8),
              ),
            ]
          : null,
    );
  }

  static BoxDecoration glassBadge() {
    return BoxDecoration(
      color: AppColors.glassBadgeBg,
      borderRadius: BorderRadius.circular(9999),
      border: Border.all(color: AppColors.glassBadgeBorder, width: 1),
    );
  }

  static BoxDecoration glassCircle({Color? borderColor}) {
    return BoxDecoration(
      color: AppColors.glassBg,
      shape: BoxShape.circle,
      border: Border.all(
        color: borderColor ?? AppColors.glassBorder,
        width: 1,
      ),
    );
  }

  static BoxDecoration cosmicGradient() {
    return const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(0.5, -0.5),
        radius: 1.5,
        colors: [AppColors.cosmicIndigo, AppColors.backgroundDark],
      ),
    );
  }

  static BoxDecoration settingsGradient() {
    return const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(0.7, -0.7),
        radius: 1.5,
        colors: [Color(0xFF3D2F0A), AppColors.backgroundDarkDeep, Colors.black],
      ),
    );
  }
}

// ─── Typography ─────────────────────────────────────────────────────────────

class AppTextStyles {
  static const String fontFamily = 'Inter';

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite90,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite70,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite60,
  );

  // Sanskrit display
  static const TextStyle sanskrit = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Color(0xE6ECB613), // primary 90%
    height: 1.5,
  );

  static const TextStyle sanskritLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Color(0xE6ECB613),
    height: 1.4,
  );

  // Labels / Badges
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Color(0x99ECB613), // primary 60%
    letterSpacing: 3.0,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 1.5,
  );

  static const TextStyle verseRef = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xCCECB613), // primary 80%
  );

  // Italic quote style
  static const TextStyle quoteText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    color: AppColors.textWhite90,
    height: 1.6,
  );

  // Button
  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.backgroundDark,
    letterSpacing: 0.5,
  );

  // Nav label
  static const TextStyle navLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  // Display heading (large titles)
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // Subtitle / medium weight
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite70,
    height: 1.5,
  );

  // Stat / large number
  static const TextStyle statNumber = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    height: 1.0,
  );
}

// ─── Strings ────────────────────────────────────────────────────────────────

class AppStrings {
  static const String appName = 'Bhagavad Gita';
  static const String dailyWisdom = 'Daily Wisdom';
  static const String namaste = 'Namaste, Seeker';
  static const String searchHint = 'Search verses or topics...';
  static const String verseOfTheDay = 'VERSE OF THE DAY';
  static const String shareWisdom = 'SHARE WISDOM';
  static const String chapters = 'Chapters';
  static const String verses = 'Verses';
  static const String meaning = 'Meaning';
  static const String commentary = 'Commentary';
  static const String noData = 'No data available';
  static const String loading = 'Loading...';
  static const String error = 'An error occurred';
  static const String settings = 'Settings';
  static const String saved = 'Saved';
  static const String home = 'Home';
  static const String originalSanskrit = 'ORIGINAL SANSKRIT';
  static const String translation = 'TRANSLATION';
  static const String relatedVerses = 'RELATED VERSES';
  static const String shareQuote = 'Share Quote';
  static const String noFavorites = 'No saved verses yet';
  static const String addFavorites = 'Tap the heart icon on any verse to save it here';
  static const String appVersion = 'GITA WISDOM V1.0.0';

  // Onboarding
  static const String onboardingTitle = 'Begin Your';
  static const String onboardingTitleAccent = 'Wisdom';
  static const String onboardingSubtitle = 'THE ETERNAL SONG AWAITS';
  static const String onboardingNameHint = 'Enter your name, Seeker';
  static const String onboardingCta = 'BEGIN JOURNEY';
  static const String onboardingSwipeHint = 'Swipe to continue';

  // Scriptures
  static const String scripturesTitle = 'Scripture Overview';
  static const String scripturesLabel = 'ETERNAL WISDOM';
  static const String scripturesSearch = 'Search chapters or verses...';

  // Loading
  static const String loadingPreparing = 'PREPARING SPACE';
  static const String loadingBreath = 'TAKE A DEEP BREATH';

  // Journey
  static const String journeyTitle = "'s Wisdom";
  static const String journeyLevel = 'SEEKER LEVEL';
  static const String meditationStreak = 'MEDITATION STREAK';
  static const String activeJourneys = 'Active Journeys';
  static const String cosmicAchievements = 'Cosmic Achievements';
  static const String wisdomTimeline = 'Wisdom Timeline';
}

// ─── Spacing ────────────────────────────────────────────────────────────────

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 24);
  static const EdgeInsets cardPadding = EdgeInsets.all(24);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(16);
}
