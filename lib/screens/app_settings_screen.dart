import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import '../providers/app_state_provider.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

/// App Settings screen matching the mockup — appearance, notifications,
/// typography, general actions.

void _rescheduleIfEnabled(AppStateProvider appState) {
  if (!appState.dailyQuotesEnabled) return;
  int hour24 = appState.notificationHour;
  if (!appState.isAM && hour24 != 12) hour24 += 12;
  if (appState.isAM && hour24 == 12) hour24 = 0;
  NotificationService.instance
      .scheduleDailyQuote(hour: hour24, minute: appState.notificationMinute);
}

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Consumer<AppStateProvider>(
        builder: (context, appState, _) {
          return CustomScrollView(
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.settings, style: AppTextStyles.h1),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(9999),
                          border:
                              Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(
                          'Done',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Appearance Section ──
              _sectionHeader('APPEARANCE'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Dark Mode Toggle
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGhost,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.dark_mode,
                                  color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Text('Dark Mode',
                                style: AppTextStyles.bodyLarge
                                    .copyWith(fontWeight: FontWeight.w500)),
                            const Spacer(),
                            _GoldSwitch(
                              value: appState.isDarkMode,
                              onChanged: (_) => appState.toggleTheme(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Theme Intensity
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Theme Intensity',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textWhite40)),
                            Text(
                              '${appState.themeIntensity.round()}%',
                              style: AppTextStyles.badge.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: _goldSliderTheme(),
                          child: Slider(
                            value: appState.themeIntensity,
                            min: 0,
                            max: 100,
                            onChanged: (v) => appState.setThemeIntensity(v),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Inspiration Section ──
              _sectionHeader('INSPIRATION'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // Daily Quotes toggle
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGhost,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.notifications_active,
                                    color: AppColors.primary,
                                    size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Daily Quotes',
                                        style: AppTextStyles.bodyLarge
                                            .copyWith(
                                                fontWeight:
                                                    FontWeight.w500)),
                                    Text('Wisdom delivered daily',
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                                color:
                                                    AppColors.textWhite40)),
                                  ],
                                ),
                              ),
                              _GoldSwitch(
                                value: appState.dailyQuotesEnabled,
                                onChanged: (_) {
                                    appState.toggleDailyQuotes();
                                    if (appState.dailyQuotesEnabled) {
                                      // Convert 12-hour to 24-hour
                                      int hour24 = appState.notificationHour;
                                      if (!appState.isAM && hour24 != 12) hour24 += 12;
                                      if (appState.isAM && hour24 == 12) hour24 = 0;
                                      NotificationService.instance.scheduleDailyQuote(
                                          hour: hour24, minute: appState.notificationMinute);
                                    } else {
                                      NotificationService.instance.cancelAll();
                                    }
                                },
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          height: 1,
                          color: AppColors.glassBorderLight.withAlpha(12),
                        ),

                        // Time picker
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          color: AppColors.primaryGhost.withAlpha(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _TimeBox(
                                label: 'HOURS',
                                value: appState.notificationHour
                                    .toString()
                                    .padLeft(2, '0'),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 24),
                                child: Text(
                                  ':',
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.primaryDim,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              _TimeBox(
                                label: 'MINUTES',
                                value: appState.notificationMinute
                                    .toString()
                                    .padLeft(2, '0'),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                children: [
                                  _AmPmButton(
                                    label: 'AM',
                                    isSelected: appState.isAM,
                                    onTap: () {
                                        appState.setNotificationTime(
                                            appState.notificationHour,
                                            appState.notificationMinute,
                                            true);
                                        _rescheduleIfEnabled(appState);
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  _AmPmButton(
                                    label: 'PM',
                                    isSelected: !appState.isAM,
                                    onTap: () {
                                        appState.setNotificationTime(
                                            appState.notificationHour,
                                            appState.notificationMinute,
                                            false);
                                        _rescheduleIfEnabled(appState);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Typography Section ──
              _sectionHeader('TYPOGRAPHY'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Font Size',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textWhite40)),
                            Row(
                              children: [
                                Text('A',
                                    style: AppTextStyles.bodySmall
                                        .copyWith(fontSize: 12)),
                                const SizedBox(width: 8),
                                Text('A',
                                    style: AppTextStyles.h3
                                        .copyWith(fontSize: 20)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: _goldSliderTheme(),
                          child: Slider(
                            value: appState.fontSize,
                            min: 12,
                            max: 24,
                            onChanged: (v) => appState.setFontSize(v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Font preview
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(50),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.glassBorderLight.withAlpha(12),
                            ),
                          ),
                          child: Text(
                            '"You have the right to work, but for the work\'s sake only."',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontStyle: FontStyle.italic,
                              fontSize: appState.fontSize,
                              color: AppColors.textWhite70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── General Section ──
              _sectionHeader('GENERAL'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SettingsListTile(
                          icon: Icons.star_outline,
                          label: 'Rate the App',
                          onTap: () async {
                            final inAppReview = InAppReview.instance;
                            if (await inAppReview.isAvailable()) {
                              inAppReview.requestReview();
                            } else {
                              inAppReview.openStoreListing();
                            }
                          },
                        ),
                        Container(
                          height: 1,
                          color: AppColors.glassBorderLight.withAlpha(12),
                        ),
                        _SettingsListTile(
                          icon: Icons.share,
                          label: 'Share with Friends',
                          onTap: () async {
                            await SharePlus.instance.share(
                              ShareParams(
                                text:
                                    'Discover the timeless wisdom of the Bhagavad Gita! '
                                    'Download the Bhagavad Gita app and explore verses, '
                                    'translations, and insights for your spiritual journey. 🙏✨',
                              ),
                            );
                          },
                        ),
                        Container(
                          height: 1,
                          color: AppColors.glassBorderLight.withAlpha(12),
                        ),
                        _SettingsListTile(
                          icon: Icons.help_outline,
                          label: 'Contact Support',
                          onTap: () async {
                            final uri = Uri(
                              scheme: 'mailto',
                              path: 'admin@bearsystems.in',
                              queryParameters: {
                                'subject': 'Bhagavad Gita App - Support Request',
                                'body': 'Hi,\n\nI need help with:\n\n'
                                    '---\n'
                                    'App Version: ${AppStrings.appVersion}\n',
                              },
                            );
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Footer ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.appVersion,
                        style: AppTextStyles.sectionLabel.copyWith(
                          color: AppColors.primary.withAlpha(100),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('PRIVACY POLICY',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10,
                                color: AppColors.textWhite40,
                                letterSpacing: -0.3,
                              )),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8),
                            child: Text('•',
                                style: TextStyle(
                                    color: AppColors.textWhite20)),
                          ),
                          Text('TERMS OF SERVICE',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10,
                                color: AppColors.textWhite40,
                                letterSpacing: -0.3,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _sectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 24, 10),
        child: Text(title, style: AppTextStyles.sectionLabel),
      ),
    );
  }

  SliderThemeData _goldSliderTheme() {
    return SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.primary.withAlpha(50),
      thumbColor: AppColors.primary,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      overlayColor: AppColors.primary.withAlpha(50),
      trackHeight: 4,
    );
  }
}

// ─── Helper Widgets ─────────────────────────────────────────────────────────

class _GoldSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GoldSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.glassBorderLight,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String label;
  final String value;

  const _TimeBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withAlpha(50)),
            ),
            child: Center(
              child: Text(
                value,
                style: AppTextStyles.h1.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.sectionLabel.copyWith(
              fontSize: 8,
              color: AppColors.textWhite40,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmPmButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmPmButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.glassBg,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? AppColors.backgroundDark
                : AppColors.textWhite40,
          ),
        ),
      ),
    );
  }
}

class _SettingsListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsListTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary.withAlpha(150)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 22, color: AppColors.textWhite20),
          ],
        ),
      ),
    );
  }
}
