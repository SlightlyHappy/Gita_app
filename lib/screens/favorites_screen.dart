import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bhagavad_gita_model.dart';
import '../providers/app_state_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import 'verse_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final Map<String, Verse> _versesCache = {};
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavoriteVerses();
  }

  Future<void> _loadFavoriteVerses() async {
    final provider = context.read<AppStateProvider>();
    final keys = provider.favoriteKeys;

    // Find keys we haven't loaded yet
    final newKeys =
        keys.where((k) => !_versesCache.containsKey(k)).toList();
    if (newKeys.isEmpty) return;

    setState(() => _isLoading = true);

    for (final key in newKeys) {
      try {
        final parts = key.split(':');
        if (parts.length == 2) {
          final chapter = int.parse(parts[0]);
          final verse = int.parse(parts[1]);
          final v = await ApiService.fetchVerse(chapter, verse);
          if (mounted) {
            _versesCache[key] = v;
          }
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Consumer<AppStateProvider>(
        builder: (context, appState, _) {
          final favKeys = appState.favoriteKeys.toList();

          // Remove cached verses that are no longer favorites
          _versesCache.removeWhere((k, _) => !favKeys.contains(k));

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.saved, style: AppTextStyles.h1),
                      const SizedBox(height: 4),
                      Text(
                        '${favKeys.length} bookmarked verse${favKeys.length == 1 ? '' : 's'}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              if (favKeys.isEmpty && !_isLoading)
                // Empty state
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: AppDecorations.glassCircle(
                            borderColor: AppColors.glassBorder,
                          ),
                          child: const Icon(
                            Icons.bookmark,
                            size: 36,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(AppStrings.noFavorites,
                            style: AppTextStyles.h3.copyWith(fontSize: 16)),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Text(
                            AppStrings.addFavorites,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isLoading && _versesCache.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final key = favKeys[index];
                        final verse = _versesCache[key];

                        if (verse == null) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Loading verse $key...',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _FavoriteVerseCard(
                            verse: verse,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VerseDetailScreen(verse: verse),
                                ),
                              );
                            },
                            onRemove: () {
                              appState.toggleFavorite(
                                verse.chapterNumber,
                                verse.verseNumber,
                              );
                            },
                          ),
                        );
                      },
                      childCount: favKeys.length,
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

class _FavoriteVerseCard extends StatelessWidget {
  final Verse verse;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _FavoriteVerseCard({
    required this.verse,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse indicator
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryGhost,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${verse.chapterNumber}',
                  style: AppTextStyles.badge.copyWith(fontSize: 13),
                ),
                Text(
                  ':${verse.verseNumber}',
                  style: AppTextStyles.badge.copyWith(
                    fontSize: 10,
                    color: AppColors.primaryDim,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verse.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary.withAlpha(200),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (verse.meaning.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    verse.meaning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.bookmark,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
