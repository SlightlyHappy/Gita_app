import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/bhagavad_gita_model.dart';
import '../providers/app_state_provider.dart';
import '../services/local_cache_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/cosmic_background.dart';
import 'verse_detail_screen.dart';

/// Verses screen — book-like flowing layout for a single chapter.
/// Features:
///  • 5-second idle verse reading auto-tracking
///  • Chapter session duration tracking
///  • Auto-scroll to last-read verse
///  • Long-press context menu on each verse
class VersesScreen extends StatefulWidget {
  final int chapterNumber;
  final String chapterName;

  const VersesScreen({
    super.key,
    required this.chapterNumber,
    required this.chapterName,
  });

  @override
  State<VersesScreen> createState() => _VersesScreenState();
}

class _VersesScreenState extends State<VersesScreen> {
  List<Verse>? _verses;
  bool _isLoading = true;
  String? _error;

  final ScrollController _scrollController = ScrollController();

  // ── Reading tracking ──
  final Map<int, GlobalKey> _verseKeys = {};
  Timer? _readTimer;
  DateTime? _sessionStart;
  final Set<int> _sessionMarked = {}; // verses already marked this session

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();
    _loadVerses();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _readTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // Record session duration
    _recordSessionDuration();
    super.dispose();
  }

  void _recordSessionDuration() {
    if (_sessionStart == null) return;
    final seconds = DateTime.now().difference(_sessionStart!).inSeconds;
    if (seconds > 0) {
      final provider =
          Provider.of<AppStateProvider>(context, listen: false);
      provider.addChapterTime(widget.chapterNumber, seconds);
    }
  }

  Future<void> _loadVerses() async {
    try {
      final verses =
          await LocalCacheService.instance.loadVerses(widget.chapterNumber);
      if (!mounted) return;
      setState(() {
        _verses = verses;
        _isLoading = false;
      });
      // Auto-scroll to last-read verse after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoScrollToLastRead();
        // Start tracking visible verse after initial scroll
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _detectVisibleVerse();
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _autoScrollToLastRead() {
    final provider =
        Provider.of<AppStateProvider>(context, listen: false);
    final targetVerse = provider.getLastReadVerse(widget.chapterNumber);
    if (targetVerse != null) {
      final key = _verseKeys[targetVerse];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.1, // 10% from top
        );
      }
    }
  }

  // ── Scroll-based reading detection ──
  void _onScroll() {
    // Cancel existing timer when scrolling
    _readTimer?.cancel();

    // Set new timer – fire 5 seconds after scrolling stops
    _readTimer = Timer(const Duration(seconds: 5), () {
      _detectVisibleVerse();
    });
  }

  void _detectVisibleVerse() {
    if (!mounted || _verses == null || _verses!.isEmpty) return;

    final viewportTop = _scrollController.offset;
    final viewportHeight = _scrollController.position.viewportDimension;
    final viewportCenter = viewportTop + viewportHeight / 2;

    int? closestVerse;
    double closestDistance = double.infinity;

    for (final entry in _verseKeys.entries) {
      final key = entry.value;
      if (key.currentContext == null) continue;

      final renderBox =
          key.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) continue;

      final position = renderBox.localToGlobal(Offset.zero,
          ancestor: context.findRenderObject());
      final widgetCenter = viewportTop + position.dy + renderBox.size.height / 2;
      final distance = (widgetCenter - viewportCenter).abs();

      if (distance < closestDistance) {
        closestDistance = distance;
        closestVerse = entry.key;
      }
    }

    if (closestVerse != null && !_sessionMarked.contains(closestVerse)) {
      _markVerseAsRead(closestVerse);
    }
  }

  void _markVerseAsRead(int verseNumber) {
    _sessionMarked.add(verseNumber);
    final provider =
        Provider.of<AppStateProvider>(context, listen: false);
    provider.markVerseAsRead(widget.chapterNumber, verseNumber);
  }

  // ── Context menu ──
  void _showVerseContextMenu(Verse verse) {
    final provider =
        Provider.of<AppStateProvider>(context, listen: false);
    final isBookmarked = provider.isBookmarked(
        verse.chapterNumber, verse.verseNumber);

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
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textWhite20,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ch ${verse.chapterNumber} • Verse ${verse.verseNumber}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textWhite60,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _ContextMenuItem(
              icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              label: isBookmarked ? 'Remove Bookmark' : 'Bookmark Verse',
              color: isBookmarked ? AppColors.primary : AppColors.textWhite,
              onTap: () {
                provider.toggleBookmark(
                    verse.chapterNumber, verse.verseNumber);
                Navigator.pop(ctx);
              },
            ),
            _ContextMenuItem(
              icon: Icons.auto_stories,
              label: 'Mark as Last Read',
              color: AppColors.textWhite,
              onTap: () {
                provider.markLastReadLocation(
                    verse.chapterNumber, verse.verseNumber);
                Navigator.pop(ctx);
              },
            ),
            _ContextMenuItem(
              icon: Icons.copy_rounded,
              label: 'Copy Verse',
              color: AppColors.textWhite,
              onTap: () {
                final text =
                    '${verse.text}\n\n${verse.meaning}\n\n— Bhagavad Gita ${verse.chapterNumber}.${verse.verseNumber}';
                Clipboard.setData(ClipboardData(text: text));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verse copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            _ContextMenuItem(
              icon: Icons.share,
              label: 'Share Verse',
              color: AppColors.textWhite,
              onTap: () async {
                Navigator.pop(ctx);
                final text =
                    '"${verse.meaning.isNotEmpty ? verse.meaning : verse.text}"\n\n'
                    '— Bhagavad Gita, Ch ${verse.chapterNumber}, V ${verse.verseNumber}\n\n'
                    'Discover more wisdom in the Bhagavad Gita app.';
                await SharePlus.instance.share(ShareParams(text: text));
                provider.incrementShareCount();
              },
            ),
            _ContextMenuItem(
              icon: Icons.open_in_new,
              label: 'View Details',
              color: AppColors.textWhite,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VerseDetailScreen(verse: verse),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
              _buildHeader(),

              const SizedBox(height: 16),

              // ── Verses Content ──
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chapter ${widget.chapterNumber}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textWhite60,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
                Text(
                  widget.chapterName,
                  style: AppTextStyles.h3,
                ),
              ],
            ),
          ),
          // Reading progress indicator
          Consumer<AppStateProvider>(
            builder: (context, provider, _) {
              final progress = provider.chapterProgressMap[widget.chapterNumber];
              final versesRead = progress?.versesRead.length ?? 0;
              final total = _verses?.length ?? 0;
              if (total == 0) return const SizedBox.shrink();
              return GlassCard(
                borderRadius: 9999,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  '$versesRead/$total read',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('Could not load verses', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadVerses();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

    final verses = _verses ?? [];

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter intro
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chapter ${widget.chapterNumber}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textWhite60,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.chapterName,
                  style: AppTextStyles.h2,
                ),
              ],
            ),
          ),

          // Verses as flowing paragraphs
          ...verses.map((verse) {
            _verseKeys.putIfAbsent(
                verse.verseNumber, () => GlobalKey());
            final key = _verseKeys[verse.verseNumber]!;

            return GestureDetector(
              key: key,
              onLongPress: () => _showVerseContextMenu(verse),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VerseDetailScreen(verse: verse),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Consumer<AppStateProvider>(
                  builder: (context, provider, _) {
                    final isBookmarked = provider.isBookmarked(
                        verse.chapterNumber, verse.verseNumber);
                    final isRead = provider.chapterProgressMap[
                                widget.chapterNumber]
                            ?.versesRead
                            .contains(verse.verseNumber) ??
                        false;

                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: isRead
                                ? AppColors.primary.withAlpha(128)
                                : AppColors.primary,
                            width: 3,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Verse number label + bookmark icon
                          Row(
                            children: [
                              Text(
                                'Verse ${verse.verseNumber}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  fontSize: 11,
                                ),
                              ),
                              if (isRead) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppColors.primary.withAlpha(128),
                                ),
                              ],
                              const Spacer(),
                              if (isBookmarked)
                                const Icon(
                                  Icons.bookmark,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Verse text (Sanskrit/Original)
                          Text(
                            verse.text,
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.textWhite,
                              height: 1.7,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),

                          // Translation
                          if (verse.translations.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              verse.translations[0].description,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textWhite,
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],

                          // Meaning/Commentary
                          if (verse.meaning.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              verse.meaning,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textWhite70,
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContextMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(color: color),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
