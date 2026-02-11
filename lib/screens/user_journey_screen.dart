import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/achievement_model.dart';
import '../models/reading_session_model.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/cosmic_background.dart';

/// User Journey / Progress page — accessible via profile button on home screen.
/// Displays real reading progress, streak, achievements with progress,
/// reading stats, and timeline from actual data.
class UserJourneyScreen extends StatelessWidget {
  const UserJourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          bottom: false,
          child: Consumer<AppStateProvider>(
            builder: (context, appState, _) {
              return CustomScrollView(
                slivers: [
                  // ── Header ──
                  SliverToBoxAdapter(
                    child: _buildHeader(context, appState),
                  ),

                  // ── Stats Overview ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: _StatsOverview(appState: appState),
                    ),
                  ),

                  // ── Consecutive Days Streak ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child:
                          _StreakCard(streak: appState.consecutiveDays),
                    ),
                  ),

                  // ── Active Journeys (Chapter Progress) ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _SectionHeader(
                        title: AppStrings.activeJourneys,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _ActiveJourneysList(appState: appState),
                    ),
                  ),

                  // ── Cosmic Achievements ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _SectionHeader(
                        title: AppStrings.cosmicAchievements,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: _AchievementsGrid(appState: appState),
                    ),
                  ),

                  // ── Reading Time by Chapter ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _SectionHeader(
                        title: 'Reading Time',
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: _ReadingTimeSection(appState: appState),
                    ),
                  ),

                  // ── Wisdom Timeline ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _SectionHeader(
                        title: AppStrings.wisdomTimeline,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                      child: _WisdomTimeline(appState: appState),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppStateProvider appState) {
    final name =
        appState.userName.isNotEmpty ? appState.userName : 'Seeker';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          // Back button
          GlassCard(
            borderRadius: 9999,
            padding: const EdgeInsets.all(10),
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textWhite,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),

          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withAlpha(128),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.backgroundDark,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.verified,
                      size: 10,
                      color: AppColors.backgroundDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.journeyLevel} ${appState.seekerLevel}',
                  style: AppTextStyles.sectionLabel.copyWith(
                    color: AppColors.primary.withAlpha(178),
                    fontSize: 10,
                  ),
                ),
                Text(
                  "$name${AppStrings.journeyTitle}",
                  style: AppTextStyles.h2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Overview ─────────────────────────────────────────────────────────

class _StatsOverview extends StatelessWidget {
  final AppStateProvider appState;

  const _StatsOverview({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(
          label: 'Verses Read',
          value: '${appState.totalVersesRead}',
          icon: Icons.menu_book,
        ),
        const SizedBox(width: 12),
        _StatTile(
          label: 'Chapters',
          value: '${appState.chaptersStarted}/18',
          icon: Icons.library_books,
        ),
        const SizedBox(width: 12),
        _StatTile(
          label: 'Bookmarks',
          value: '${appState.favoriteKeys.length}',
          icon: Icons.bookmark,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textWhite,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textWhite40,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Streak Card ────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final int streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final nextMilestone = ((streak ~/ 10) + 1) * 10;
    final milestoneProgress =
        nextMilestone > 0 ? (streak / nextMilestone).clamp(0.0, 1.0) : 0.0;

    return GlassCard(
      featured: true,
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -20,
            child: Icon(
              Icons.local_fire_department,
              size: 120,
              color: AppColors.textWhite.withAlpha(13),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'CONSECUTIVE DAYS',
                          style: AppTextStyles.sectionLabel.copyWith(
                            color: AppColors.primary.withAlpha(178),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$streak',
                          style: AppTextStyles.statNumber.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Days',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textWhite60,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Next Milestone: $nextMilestone Days',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textWhite60,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 6,
                        color: AppColors.primary.withAlpha(25),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: milestoneProgress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(128),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.h3);
  }
}

// ─── Active Journeys (Real Chapter Progress) ────────────────────────────────

class _ActiveJourneysList extends StatelessWidget {
  final AppStateProvider appState;

  const _ActiveJourneysList({required this.appState});

  @override
  Widget build(BuildContext context) {
    final chapters = appState.chapters ?? [];
    // Show chapters that have progress, or first 5 if none started
    final progressChapters = chapters.where((c) {
      final p = appState.chapterProgressMap[c.chapterNumber];
      return p != null && p.versesRead.isNotEmpty;
    }).toList();

    final displayChapters =
        progressChapters.isNotEmpty ? progressChapters : chapters.take(5).toList();

    if (displayChapters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Start reading to see your progress here.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textWhite40),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: displayChapters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final chapter = displayChapters[index];
          final versesRead =
              appState.getVersesReadCount(chapter.chapterNumber);
          final totalVerses = chapter.versesCount;
          final progress = totalVerses > 0
              ? (versesRead / totalVerses).clamp(0.0, 1.0)
              : 0.0;
          final timeSpent =
              appState.getChapterTimeFormatted(chapter.chapterNumber);

          return _JourneyCard(
            chapterName: chapter.name,
            chapterNumber: chapter.chapterNumber,
            progress: progress,
            versesRead: versesRead,
            totalVerses: totalVerses,
            timeSpent: timeSpent,
            isHighlighted: progress > 0 && progress < 1.0,
          );
        },
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  final String chapterName;
  final int chapterNumber;
  final double progress;
  final int versesRead;
  final int totalVerses;
  final String timeSpent;
  final bool isHighlighted;

  const _JourneyCard({
    required this.chapterName,
    required this.chapterNumber,
    required this.progress,
    required this.versesRead,
    required this.totalVerses,
    required this.timeSpent,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? AppColors.primary.withAlpha(102)
              : AppColors.glassBorderLight,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress ring
          SizedBox(
            width: 72,
            height: 72,
            child: CustomPaint(
              painter: _ProgressRingPainter(
                progress: progress,
                primaryColor: AppColors.primary,
                trackColor: AppColors.textWhite.withAlpha(25),
              ),
              child: Center(
                child: Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Chapter name
          Text(
            chapterName,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textWhite70,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Verses read
          Text(
            '$versesRead/$totalVerses verses',
            style: AppTextStyles.sectionLabel.copyWith(
              color: AppColors.textWhite40,
              fontSize: 9,
            ),
          ),

          // Time spent
          if (timeSpent != '0m')
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                timeSpent,
                style: AppTextStyles.sectionLabel.copyWith(
                  color: AppColors.primary.withAlpha(178),
                  fontSize: 9,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Progress Ring Painter ──────────────────────────────────────────────────

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color trackColor;

  _ProgressRingPainter({
    required this.progress,
    required this.primaryColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) => old.progress != progress;
}

// ─── Achievements Grid (All 10 with Progress) ──────────────────────────────

class _AchievementsGrid extends StatelessWidget {
  final AppStateProvider appState;

  const _AchievementsGrid({required this.appState});

  @override
  Widget build(BuildContext context) {
    final achievements = appState.achievements;

    if (achievements.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Start reading to unlock achievements!',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite40),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          achievements.map((a) => _AchievementTile(achievement: a, appState: appState)).toList(),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final AppStateProvider appState;

  const _AchievementTile({required this.achievement, required this.appState});

  String _getProgressText() {
    switch (achievement.id) {
      case 'first_step':
        return appState.totalVersesRead > 0 ? 'Done!' : '0/1 verse';
      case 'chapter_master':
        final completed = appState.chaptersCompleted.length;
        return '$completed/1 chapter';
      case 'seeker':
        return '${appState.chaptersStarted}/5 chapters';
      case 'devoted_learner':
        return '${appState.chaptersStarted}/10 chapters';
      case 'wisdom_warrior':
        return '${appState.chaptersStarted}/15 chapters';
      case 'complete_knowledge':
        return '${appState.chaptersStarted}/18 chapters';
      case 'seven_day_sage':
        return '${appState.consecutiveDays}/7 days';
      case 'thirty_day_saint':
        return '${appState.consecutiveDays}/30 days';
      case 'bookmark_collector':
        return '${appState.favoriteKeys.length}/10 bookmarks';
      case 'shared_wisdom':
        return appState.shareCount > 0 ? 'Done!' : '0/1 share';
      default:
        return '';
    }
  }

  double _getProgressFraction() {
    switch (achievement.id) {
      case 'first_step':
        return appState.totalVersesRead > 0 ? 1.0 : 0.0;
      case 'chapter_master':
        return appState.chaptersCompleted.isNotEmpty ? 1.0 : 0.0;
      case 'seeker':
        return (appState.chaptersStarted / 5).clamp(0.0, 1.0);
      case 'devoted_learner':
        return (appState.chaptersStarted / 10).clamp(0.0, 1.0);
      case 'wisdom_warrior':
        return (appState.chaptersStarted / 15).clamp(0.0, 1.0);
      case 'complete_knowledge':
        return (appState.chaptersStarted / 18).clamp(0.0, 1.0);
      case 'seven_day_sage':
        return (appState.consecutiveDays / 7).clamp(0.0, 1.0);
      case 'thirty_day_saint':
        return (appState.consecutiveDays / 30).clamp(0.0, 1.0);
      case 'bookmark_collector':
        return (appState.favoriteKeys.length / 10).clamp(0.0, 1.0);
      case 'shared_wisdom':
        return appState.shareCount > 0 ? 1.0 : 0.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final progressFraction = _getProgressFraction();
    final progressText = _getProgressText();

    return GestureDetector(
      onTap: () => _showAchievementDetail(context),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - 60) / 2,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          borderColor: isUnlocked
              ? AppColors.primary.withAlpha(80)
              : AppColors.glassBorderLight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    achievement.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const Spacer(),
                  if (isUnlocked)
                    Icon(Icons.check_circle,
                        size: 18, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                achievement.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isUnlocked
                      ? AppColors.textWhite
                      : AppColors.textWhite60,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                achievement.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textWhite40,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              // Progress bar
              if (!isUnlocked) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progressFraction,
                    backgroundColor: AppColors.textWhite.withAlpha(25),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  progressText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textWhite40,
                    fontSize: 9,
                  ),
                ),
              ],
              if (isUnlocked && achievement.unlockedAt != null)
                Text(
                  'Unlocked ${DateFormat.yMMMd().format(achievement.unlockedAt!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary.withAlpha(178),
                    fontSize: 9,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textWhite20,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              achievement.emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              achievement.name,
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textWhite60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (achievement.isUnlocked && achievement.unlockedAt != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGhost,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Unlocked on ${DateFormat.yMMMMd().format(achievement.unlockedAt!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (!achievement.isUnlocked) ...[
              Text(
                _getProgressText(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _getProgressFraction(),
                    backgroundColor: AppColors.textWhite.withAlpha(25),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Reading Time Section ───────────────────────────────────────────────────

class _ReadingTimeSection extends StatelessWidget {
  final AppStateProvider appState;

  const _ReadingTimeSection({required this.appState});

  @override
  Widget build(BuildContext context) {
    final chaptersWithTime = <int>[];
    for (int i = 1; i <= 18; i++) {
      final progress = appState.chapterProgressMap[i];
      if (progress != null && progress.totalTimeSeconds > 0) {
        chaptersWithTime.add(i);
      }
    }

    if (chaptersWithTime.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'Start reading chapters to track time spent.',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite40),
          ),
        ),
      );
    }

    // Sort by most time spent
    chaptersWithTime.sort((a, b) {
      final ta = appState.chapterProgressMap[a]!.totalTimeSeconds;
      final tb = appState.chapterProgressMap[b]!.totalTimeSeconds;
      return tb.compareTo(ta);
    });

    // Find max for bar chart scaling
    final maxTime =
        appState.chapterProgressMap[chaptersWithTime.first]!.totalTimeSeconds;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: chaptersWithTime.map((chNum) {
          final progress = appState.chapterProgressMap[chNum]!;
          final fraction =
              maxTime > 0 ? progress.totalTimeSeconds / maxTime : 0.0;
          final timeStr = appState.getChapterTimeFormatted(chNum);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    'Ch $chNum',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textWhite60,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: fraction,
                      backgroundColor: AppColors.textWhite.withAlpha(20),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 40,
                  child: Text(
                    timeStr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Wisdom Timeline (from real reading sessions) ──────────────────────────

class _WisdomTimeline extends StatelessWidget {
  final AppStateProvider appState;

  const _WisdomTimeline({required this.appState});

  @override
  Widget build(BuildContext context) {
    final sessions = appState.readingSessions;

    if (sessions.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.timeline, size: 40, color: AppColors.textWhite20),
              const SizedBox(height: 12),
              Text(
                'Your reading journey will appear here.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textWhite40),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Group sessions by day
    final grouped = <String, List<VerseReadingSession>>{};
    for (final s in sessions) {
      final dayKey = DateFormat.yMMMd().format(s.readAt.toLocal());
      grouped.putIfAbsent(dayKey, () => []).add(s);
    }

    // Sort days descending (most recent first)
    final sortedDays = grouped.keys.toList()
      ..sort((a, b) {
        final da = DateFormat.yMMMd().parse(a);
        final db = DateFormat.yMMMd().parse(b);
        return db.compareTo(da);
      });

    // Take last 10 days max
    final displayDays = sortedDays.take(10).toList();

    return Column(
      children: [
        for (int i = 0; i < displayDays.length; i++)
          _TimelineDay(
            dateLabel: displayDays[i],
            sessions: grouped[displayDays[i]]!,
            isLast: i == displayDays.length - 1,
          ),
      ],
    );
  }
}

class _TimelineDay extends StatelessWidget {
  final String dateLabel;
  final List<VerseReadingSession> sessions;
  final bool isLast;

  const _TimelineDay({
    required this.dateLabel,
    required this.sessions,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    // Group by chapter
    final byChapter = <int, int>{};
    for (final s in sessions) {
      byChapter[s.chapterNumber] = (byChapter[s.chapterNumber] ?? 0) + 1;
    }

    final chapterSummaries = byChapter.entries
        .map((e) => 'Ch ${e.key}: ${e.value} verse${e.value > 1 ? 's' : ''}')
        .join(', ');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline spine
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(76),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.backgroundDark,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.primary.withAlpha(76),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: AppTextStyles.sectionLabel.copyWith(
                      color: AppColors.primary.withAlpha(153),
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Read ${sessions.length} verse${sessions.length > 1 ? 's' : ''}',
                    style: AppTextStyles.h3.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chapterSummaries,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textWhite60,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
