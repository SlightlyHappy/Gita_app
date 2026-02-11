import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bhagavad_gita_model.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/cosmic_background.dart';
import 'verses_screen.dart';

/// Search screen with functional chapter search.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Chapter> _results = [];
  bool _hasSearched = false;

  void _performSearch(String query) {
    final provider = context.read<AppStateProvider>();
    final chapters = provider.chapters ?? [];

    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    final q = query.toLowerCase();
    setState(() {
      _hasSearched = true;
      _results = chapters.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.transliteration.toLowerCase().contains(q) ||
            c.meaning.toLowerCase().contains(q) ||
            c.summary.toLowerCase().contains(q) ||
            'chapter ${c.chapterNumber}'.contains(q);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
                child: Row(
                  children: [
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
                    Text('Search', style: AppTextStyles.h2),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Search Input ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassCard(
                  borderRadius: 9999,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 4),
                  borderColor: AppColors.glassBorderLight,
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _performSearch,
                          autofocus: true,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textWhite,
                          ),
                          decoration: InputDecoration(
                            hintText: AppStrings.searchHint,
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
                            _performSearch('');
                          },
                          child: const Icon(Icons.close,
                              color: AppColors.textWhite40, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Results ──
              Expanded(
                child: _hasSearched
                    ? _results.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 48, color: AppColors.textWhite20),
                                const SizedBox(height: 16),
                                Text(
                                  'No chapters found',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try a different search term',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                24, 0, 24, 100),
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final chapter = _results[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 12),
                                child: _SearchResultCard(
                                  chapter: chapter,
                                  query: _searchController.text,
                                ),
                              );
                            },
                          )
                    : _buildSuggestions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      'Karma Yoga',
      'Dharma',
      'Self-realization',
      'Meditation',
      'Devotion',
      'Knowledge',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'POPULAR TOPICS',
            style: AppTextStyles.sectionLabel,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((s) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = s;
                  _performSearch(s);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: AppDecorations.glassBadge(),
                  child: Text(
                    s,
                    style: AppTextStyles.badge.copyWith(fontSize: 12),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final Chapter chapter;
  final String query;

  const _SearchResultCard({required this.chapter, required this.query});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VersesScreen(
              chapterNumber: chapter.chapterNumber,
              chapterName: chapter.name,
            ),
          ),
        );
      },
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryGhost,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Center(
              child: Text(
                '${chapter.chapterNumber}',
                style: AppTextStyles.badge.copyWith(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapter.name,
                  style: AppTextStyles.h3.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  chapter.transliteration,
                  style: AppTextStyles.verseRef.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  '${chapter.versesCount} verses • ${chapter.meaning}',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 12,
            color: AppColors.textWhite40,
          ),
        ],
      ),
    );
  }
}
