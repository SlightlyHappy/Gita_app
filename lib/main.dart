import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/scriptures_overview_screen.dart';
import 'screens/app_settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'utils/constants.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/cosmic_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent status bar for immersive cosmic look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundDark,
    ),
  );

  final provider = AppStateProvider();
  await provider.init();

  // Track daily app open for consecutive-days streak
  provider.trackAppOpen();

  // Initialize notifications
  await NotificationService.instance.init();
  await NotificationService.instance.restoreSchedule();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const GitaApp(),
    ),
  );
}

class GitaApp extends StatelessWidget {
  const GitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          themeMode: appState.themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: appState.isFirstLaunch
              ? OnboardingScreen(
                  onComplete: () {
                    // Rebuild via notifyListeners already called
                  },
                )
              : const MainShell(),
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark() : ThemeData.light();

    return base.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        surface: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: isDark ? AppColors.textWhite : AppColors.textDark,
        displayColor: isDark ? AppColors.textWhite : AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}

/// Main shell with bottom navigation switching between 4 tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    ScripturesOverviewScreen(),
    AppSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-load chapters after build completes
    Future.microtask(() {
      if (!mounted) return;
      context.read<AppStateProvider>().loadChapters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        useSettingsGradient: _currentIndex == 3,
        child: Stack(
          children: [
            // Screen content
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
            // Floating bottom nav
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
