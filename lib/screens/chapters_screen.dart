import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bhagavad_gita_model.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import 'verses_screen.dart';

/// Chapters listing screen — "Chapters" tab in bottom nav.
class ChaptersScreen extends StatelessWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Consumer<AppStateProvider>(
        builder: (context, appState, _) {
          if (appState.isLoadingChapters) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (appState.chaptersError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Could not load chapters',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => appState.loadChapters(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child:
                          Text('Retry', style: AppTextStyles.buttonText),
                    ),
                  ),
                ],
              ),
            );
          }

          final chapters = appState.chapters ?? [];

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.chapters, style: AppTextStyles.h1),
                      const SizedBox(height: 4),
                      Text(
                        '${chapters.length} chapters of divine wisdom',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              // Chapter cards
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chapter = chapters[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ChapterCard(chapter: chapter),
                      );
                    },
                    childCount: chapters.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Chapter chapter;

  const _ChapterCard({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VersesScreen(
              chapterNumber: chapter.chapterNumber,
              chapterName: chapter.name,
            ),
          ),
        );
      },
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Chapter number badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryGhost,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Center(
              child: Text(
                '${chapter.chapterNumber}',
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.name,
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  chapter.transliteration,
                  style: AppTextStyles.verseRef.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${chapter.versesCount} verses',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textWhite40,
          ),
        ],
      ),
    );
  }
}
