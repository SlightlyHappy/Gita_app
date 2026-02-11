import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bhagavad_gita_model.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import 'verses_screen.dart';

/// Scriptures Overview — replaces the old ChaptersScreen.
/// Displays chapters as expandable paragraph-style cards with search + filter.
class ScripturesOverviewScreen extends StatefulWidget {
  const ScripturesOverviewScreen({super.key});

  @override
  State<ScripturesOverviewScreen> createState() =>
      _ScripturesOverviewScreenState();
}

class _ScripturesOverviewScreenState extends State<ScripturesOverviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _activeFilter = 'All';
  Timer? _debounce;

  static const List<String> _filters = [
    'All',
    'Karma Yoga',
    'Bhakti Yoga',
    'Jnana Yoga',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = query.toLowerCase());
    });
  }

  List<Chapter> _filterChapters(List<Chapter> chapters) {
    var filtered = chapters;

    // Text search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(_searchQuery) ||
            c.transliteration.toLowerCase().contains(_searchQuery) ||
            c.meaning.toLowerCase().contains(_searchQuery) ||
            c.summary.toLowerCase().contains(_searchQuery) ||
            'chapter ${c.chapterNumber}'.contains(_searchQuery);
      }).toList();
    }

    // Category filter
    if (_activeFilter != 'All') {
      filtered = filtered.where((c) {
        final name = c.name.toLowerCase();
        final meaning = c.meaning.toLowerCase();
        final filter = _activeFilter.toLowerCase();
        return name.contains(filter) || meaning.contains(filter);
      }).toList();
    }

    return filtered;
  }

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
                  Text('Could not load chapters',
                      style: AppTextStyles.bodyMedium),
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
                      child: Text('Retry', style: AppTextStyles.buttonText),
                    ),
                  ),
                ],
              ),
            );
          }

          final allChapters = appState.chapters ?? [];
          final chapters = _filterChapters(allChapters);

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── Sticky Header ──
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              // ── Search Bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _buildSearchBar(),
                ),
              ),

              // ── Filter Chips ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 0, 8),
                  child: _buildFilterChips(),
                ),
              ),

              // ── Chapter Count ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 8, 24, 4),
                  child: Text(
                    '${chapters.length} chapter${chapters.length == 1 ? '' : 's'} of divine wisdom',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textWhite40,
                    ),
                  ),
                ),
              ),

              // ── Chapter Cards ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chapter = chapters[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ScriptureCard(
                          chapter: chapter,
                          isBookmarked:
                              appState.isChapterBookmarked(chapter.chapterNumber),
                          onBookmark: () => appState
                              .toggleChapterBookmark(chapter.chapterNumber),
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
                        ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.scripturesLabel,
                  style: AppTextStyles.sectionLabel.copyWith(
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.scripturesTitle,
                  style: AppTextStyles.h1.copyWith(fontSize: 28),
                ),
              ],
            ),
          ),
          // Profile avatar
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
            child: const ClipOval(
              child: Icon(
                Icons.self_improvement,
                color: AppColors.primary,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: AppColors.primary.withAlpha(51),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textWhite,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.scripturesSearch,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textWhite40,
                      fontWeight: FontWeight.w300,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(Icons.close,
                      color: AppColors.textWhite40, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isActive = filter == _activeFilter;

          return GestureDetector(
            onTap: () => setState(() => _activeFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.glassBg,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.glassBorderLight,
                  width: 1,
                ),
              ),
              child: Text(
                filter,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isActive
                      ? AppColors.backgroundDark
                      : AppColors.textWhite70,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Scripture Card (Expandable) ────────────────────────────────────────────

class _ScriptureCard extends StatefulWidget {
  final Chapter chapter;
  final bool isBookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onTap;

  const _ScriptureCard({
    required this.chapter,
    required this.isBookmarked,
    required this.onBookmark,
    required this.onTap,
  });

  @override
  State<_ScriptureCard> createState() => _ScriptureCardState();
}

class _ScriptureCardState extends State<_ScriptureCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    final readTimeMinutes = (chapter.versesCount * 0.4).ceil();

    return GestureDetector(
      onTap: () {
        setState(() => _expanded = !_expanded);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.glassBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _expanded
                    ? AppColors.glassBorder
                    : AppColors.glassBorderLight,
                width: 1,
              ),
              boxShadow: _expanded
                  ? [
                      const BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 32,
                        offset: Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                // Decorative glow (top-right)
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withAlpha(_expanded ? 25 : 13),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: badge + title + bookmark
                    Row(
                      children: [
                        // Chapter number badge
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(76),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${chapter.chapterNumber}'.padLeft(2, '0'),
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.backgroundDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title + subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapter.name,
                                style: AppTextStyles.h2.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                chapter.transliteration.toUpperCase(),
                                style: AppTextStyles.sectionLabel.copyWith(
                                  color: AppColors.primary.withAlpha(178),
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bookmark
                        GestureDetector(
                          onTap: widget.onBookmark,
                          child: Icon(
                            widget.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: widget.isBookmarked
                                ? AppColors.primary
                                : AppColors.textWhite40,
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Description
                    Text(
                      chapter.summary.isNotEmpty
                          ? chapter.summary
                          : chapter.meaning,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textWhite60,
                        height: 1.6,
                      ),
                      maxLines: _expanded ? null : 2,
                      overflow:
                          _expanded ? null : TextOverflow.ellipsis,
                    ),

                    // Expanded content
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          if (chapter.meaning.isNotEmpty &&
                              chapter.summary.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGhost,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withAlpha(38),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.lightbulb_outline,
                                      color: AppColors.primary, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Meaning: ${chapter.meaning}',
                                      style:
                                          AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary
                                            .withAlpha(204),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          // Read chapter button
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.primary.withAlpha(76),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'READ CHAPTER',
                                    style:
                                        AppTextStyles.buttonText.copyWith(
                                      fontSize: 13,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.arrow_forward,
                                      size: 16,
                                      color: AppColors.backgroundDark),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      crossFadeState: _expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),

                    const SizedBox(height: 14),

                    // Metadata row
                    Row(
                      children: [
                        Icon(Icons.format_list_numbered,
                            size: 14, color: AppColors.textWhite40),
                        const SizedBox(width: 4),
                        Text(
                          '${chapter.versesCount} VERSES',
                          style: AppTextStyles.sectionLabel.copyWith(
                            color: AppColors.textWhite40,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Icon(Icons.schedule,
                            size: 14, color: AppColors.textWhite40),
                        const SizedBox(width: 4),
                        Text(
                          '$readTimeMinutes MIN READ',
                          style: AppTextStyles.sectionLabel.copyWith(
                            color: AppColors.textWhite40,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 20,
                          color: AppColors.textWhite40,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
