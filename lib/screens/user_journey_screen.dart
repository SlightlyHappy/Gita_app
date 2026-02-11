import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/cosmic_background.dart';

/// User Journey / Progress page — accessible via profile button on home screen.
/// Displays reading progress, meditation streak, achievements, and timeline.
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

                  // ── Meditation Streak ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: _StreakCard(streak: appState.meditationStreak),
                    ),
                  ),

                  // ── Active Journeys ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: _SectionHeader(
                        title: AppStrings.activeJourneys,
                        trailing: 'View All',
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
                      child: _AchievementsBadges(appState: appState),
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
                // Verified badge
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

          // Settings
          GlassCard(
            borderRadius: 9999,
            padding: const EdgeInsets.all(10),
            child: const Icon(
              Icons.settings,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
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
          // Background fire icon watermark
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
              // Left: Streak info
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
                          AppStrings.meditationStreak,
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

              // Right: Progress to milestone
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
  final String? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h3),
        if (trailing != null)
          Text(
            trailing!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

// ─── Active Journeys (Horizontal Cards with Progress Rings) ─────────────────

class _ActiveJourneysList extends StatelessWidget {
  final AppStateProvider appState;

  const _ActiveJourneysList({required this.appState});

  @override
  Widget build(BuildContext context) {
    final chapters = appState.chapters ?? [];
    // Show first 5 chapters as active journeys
    final journeyChapters = chapters.take(5).toList();

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: journeyChapters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final chapter = journeyChapters[index];
          final completed =
              appState.chaptersCompleted.contains(chapter.chapterNumber);
          final progress = completed ? 1.0 : (index == 0 ? 0.8 : index == 1 ? 0.45 : 0.1);
          final isHighlighted = index == 1;

          return _JourneyCard(
            chapterName: chapter.name,
            chapterNumber: chapter.chapterNumber,
            progress: progress,
            isHighlighted: isHighlighted,
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
  final bool isHighlighted;

  const _JourneyCard({
    required this.chapterName,
    required this.chapterNumber,
    required this.progress,
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
            width: 80,
            height: 80,
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
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Chapter name
          Text(
            chapterName,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textWhite70,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Status
          Text(
            progress >= 1.0 ? 'COMPLETED' : 'CHAPTER $chapterNumber',
            style: AppTextStyles.sectionLabel.copyWith(
              color: progress >= 1.0
                  ? AppColors.success
                  : AppColors.primary,
              fontSize: 9,
              letterSpacing: 1.5,
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

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
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
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress;
}

// ─── Achievement Badges ─────────────────────────────────────────────────────

class _AchievementsBadges extends StatelessWidget {
  final AppStateProvider appState;

  const _AchievementsBadges({required this.appState});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      _AchievementData(
        icon: Icons.auto_awesome,
        label: 'First Verse',
        isEarned: appState.favoriteKeys.isNotEmpty,
        gradient: const [AppColors.primary, Color(0xFFF97316)],
      ),
      _AchievementData(
        icon: Icons.self_improvement,
        label: 'Zen Master',
        isEarned: appState.meditationStreak >= 7,
        gradient: const [AppColors.primary, Color(0xFFFBBF24)],
      ),
      _AchievementData(
        icon: Icons.workspace_premium,
        label: '100 Days',
        isEarned: appState.meditationStreak >= 100,
        gradient: const [AppColors.primary, Color(0xFFF97316)],
      ),
      _AchievementData(
        icon: Icons.stars,
        label: 'Sage Status',
        isEarned: appState.chaptersCompleted.length >= 18,
        gradient: const [AppColors.primary, Color(0xFFFBBF24)],
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: achievements
          .map((a) => _AchievementBadge(data: a))
          .toList(),
    );
  }
}

class _AchievementData {
  final IconData icon;
  final String label;
  final bool isEarned;
  final List<Color> gradient;

  const _AchievementData({
    required this.icon,
    required this.label,
    required this.isEarned,
    required this.gradient,
  });
}

class _AchievementBadge extends StatelessWidget {
  final _AchievementData data;

  const _AchievementBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: data.isEarned ? 1.0 : 0.4,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: data.isEarned
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: data.gradient,
                    )
                  : null,
              color: data.isEarned ? null : AppColors.glassBg,
              border: data.isEarned
                  ? null
                  : Border.all(color: AppColors.glassBorderLight),
              boxShadow: data.isEarned
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(76),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              data.icon,
              size: 28,
              color: data.isEarned
                  ? AppColors.backgroundDark
                  : AppColors.textWhite.withAlpha(128),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: data.isEarned
                  ? AppColors.textWhite70
                  : AppColors.textWhite40,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wisdom Timeline ────────────────────────────────────────────────────────

class _WisdomTimeline extends StatelessWidget {
  final AppStateProvider appState;

  const _WisdomTimeline({required this.appState});

  @override
  Widget build(BuildContext context) {
    final completedCount = appState.chaptersCompleted.length;

    // Build timeline nodes
    final nodes = <_TimelineNodeData>[
      if (completedCount > 0)
        _TimelineNodeData(
          status: _NodeStatus.completed,
          title: 'The Way of Knowledge',
          description: 'You completed your first chapter and began your journey of wisdom.',
          date: 'Completed',
          icon: Icons.check,
        ),
      _TimelineNodeData(
        status: completedCount > 0
            ? _NodeStatus.inProgress
            : _NodeStatus.inProgress,
        title: 'Path of Understanding',
        description: 'Continue exploring the verses to deepen your understanding.',
        date: 'In Progress',
        icon: Icons.play_arrow,
        showContinueButton: true,
      ),
      _TimelineNodeData(
        status: _NodeStatus.locked,
        title: 'Mastery of Action',
        description: 'Unlock by completing more chapters.',
        date: 'Locked',
        icon: Icons.lock,
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < nodes.length; i++)
          _TimelineNode(
            data: nodes[i],
            isLast: i == nodes.length - 1,
          ),
      ],
    );
  }
}

enum _NodeStatus { completed, inProgress, locked }

class _TimelineNodeData {
  final _NodeStatus status;
  final String title;
  final String description;
  final String date;
  final IconData icon;
  final bool showContinueButton;

  const _TimelineNodeData({
    required this.status,
    required this.title,
    required this.description,
    required this.date,
    required this.icon,
    this.showContinueButton = false,
  });
}

class _TimelineNode extends StatelessWidget {
  final _TimelineNodeData data;
  final bool isLast;

  const _TimelineNode({required this.data, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isLocked = data.status == _NodeStatus.locked;

    return Opacity(
      opacity: isLocked ? 0.4 : 1.0,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline spine
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  // Node circle
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: data.status == _NodeStatus.completed
                          ? AppColors.primary
                          : data.status == _NodeStatus.inProgress
                              ? AppColors.primary
                              : AppColors.glassBg,
                      border: data.status == _NodeStatus.inProgress
                          ? Border.all(
                              color: AppColors.backgroundDark,
                              width: 3,
                            )
                          : isLocked
                              ? Border.all(
                                  color: AppColors.glassBorderLight)
                              : null,
                      boxShadow: data.status != _NodeStatus.locked
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(76),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      data.icon,
                      size: 16,
                      color: isLocked
                          ? AppColors.textWhite.withAlpha(128)
                          : AppColors.backgroundDark,
                    ),
                  ),
                  // Connecting line
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppColors.primary.withAlpha(76),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
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
                padding: data.status == _NodeStatus.inProgress
                    ? const EdgeInsets.all(16)
                    : null,
                decoration: data.status == _NodeStatus.inProgress
                    ? BoxDecoration(
                        color: AppColors.primary.withAlpha(13),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(128),
                        ),
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.date,
                      style: AppTextStyles.sectionLabel.copyWith(
                        color: AppColors.primary.withAlpha(153),
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.title,
                      style: AppTextStyles.h3.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textWhite60,
                        height: 1.5,
                      ),
                    ),
                    if (data.showContinueButton) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(76),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'CONTINUE JOURNEY',
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
