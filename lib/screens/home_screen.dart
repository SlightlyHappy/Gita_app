import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/bhagavad_gita_model.dart';
import '../providers/app_state_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/verse_card.dart';
import 'verse_detail_screen.dart';
import 'search_screen.dart';
import 'user_journey_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Verse? _verseOfTheDay;
  List<Verse> _feedVerses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load verse of the day from chapter 2 verse 47
      final votd = await ApiService.fetchVerse(2, 47);
      // Load a few feed verses from chapter 6
      final feed = await ApiService.fetchVerses(6);
      if (mounted) {
        setState(() {
          _verseOfTheDay = votd;
          _feedVerses = feed.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Consumer<AppStateProvider>(
                builder: (context, appState, _) {
                  final name = appState.userName.isNotEmpty
                      ? appState.userName
                      : 'Seeker';
                  return Row(
                    children: [
                      // User avatar — tappable, navigates to journey
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserJourneyScreen(),
                          ),
                        ),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: AppDecorations.glassCircle(),
                          child: const ClipOval(
                            child: Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.dailyWisdom,
                                style: AppTextStyles.h3),
                            Text(
                              'Namaste, $name',
                              style: AppTextStyles.verseRef
                                  .copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                    ],
                  );
                },
              ),
            ),
          ),

          // ── Search Bar ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SearchScreen(),
                    ),
                  );
                },
                child: GlassCard(
                  borderRadius: 9999,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  borderColor: AppColors.glassBorderLight,
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        AppStrings.searchHint,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textWhite40,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else ...[
            // Verse of the Day section label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 24, 24, 8),
                child: Text(
                  AppStrings.verseOfTheDay,
                  style: AppTextStyles.sectionLabel,
                ),
              ),
            ),

            // Verse of the Day card
            if (_verseOfTheDay != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _FeaturedVerseCard(
                    verse: _verseOfTheDay!,
                    onTap: () => _navigateToDetail(_verseOfTheDay!),
                  ),
                ),
              ),

            // Feed verses
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final verse = _feedVerses[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: VerseCard(
                        verse: verse,
                        onTap: () => _navigateToDetail(verse),
                      ),
                    );
                  },
                  childCount: _feedVerses.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToDetail(Verse verse) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerseDetailScreen(verse: verse),
      ),
    );
  }
}

/// Featured "Verse of the Day" card with decorative quote icon.
class _FeaturedVerseCard extends StatelessWidget {
  final Verse verse;
  final VoidCallback? onTap;

  const _FeaturedVerseCard({required this.verse, this.onTap});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final isMarked =
        provider.isBookmarked(verse.chapterNumber, verse.verseNumber);

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        featured: true,
        borderColor: AppColors.glassBorder,
        child: Stack(
          children: [
            // Decorative quote icon
            Positioned(
              top: -8,
              right: -8,
              child: Icon(
                Icons.format_quote,
                size: 64,
                color: AppColors.textWhite.withAlpha(25),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chapter ${verse.chapterNumber} • Verse ${verse.verseNumber}',
                  style: AppTextStyles.verseRef,
                ),
                const SizedBox(height: 16),
                Text(verse.text, style: AppTextStyles.sanskritLarge),
                const SizedBox(height: 12),
                Text(
                  '"${verse.meaning}"',
                  style: AppTextStyles.quoteText.copyWith(
                    color: AppColors.textWhite70,
                  ),
                ),
                const SizedBox(height: 20),
                // Bottom action bar
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.glassBorderLight),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => provider.toggleBookmark(
                              verse.chapterNumber,
                              verse.verseNumber,
                            ),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGhost,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.textWhite20,
                                ),
                              ),
                              child: Icon(
                                isMarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 14,
                                color: isMarked
                                    ? AppColors.primary
                                    : AppColors.textWhite,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          final shareText =
                              '📖 Bhagavad Gita — Chapter ${verse.chapterNumber}, Verse ${verse.verseNumber}\n\n'
                              '${verse.text}\n\n'
                              '"${verse.meaning}"\n\n'
                              '— From the Bhagavad Gita App';
                          await SharePlus.instance.share(ShareParams(text: shareText));
                          provider.incrementShareCount();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            AppStrings.shareWisdom,
                            style: AppTextStyles.buttonText,
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
      ),
    );
  }
}
