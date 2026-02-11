import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/bhagavad_gita_model.dart';
import '../providers/app_state_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/cosmic_background.dart';

class VerseDetailScreen extends StatefulWidget {
  final Verse verse;

  const VerseDetailScreen({super.key, required this.verse});

  @override
  State<VerseDetailScreen> createState() => _VerseDetailScreenState();
}

class _VerseDetailScreenState extends State<VerseDetailScreen> {
  List<Verse> _relatedVerses = [];
  int _selectedTranslationIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRelatedVerses();
  }

  Future<void> _loadRelatedVerses() async {
    try {
      final verses =
          await ApiService.fetchVerses(widget.verse.chapterNumber);
      if (mounted) {
        setState(() {
          _relatedVerses = verses
              .where(
                  (v) => v.verseNumber != widget.verse.verseNumber)
              .take(5)
              .toList();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final isFav = provider.isBookmarked(
        widget.verse.chapterNumber, widget.verse.verseNumber);

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top Navigation ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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

                    // Center title
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'GITA VERSE',
                            style: AppTextStyles.bodySmall.copyWith(
                              letterSpacing: 3,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textWhite60,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            'Chapter ${widget.verse.chapterNumber}, Verse ${widget.verse.verseNumber}',
                            style: AppTextStyles.h3.copyWith(fontSize: 17),
                          ),
                        ],
                      ),
                    ),

                    // Favorite button
                    GlassCard(
                      borderRadius: 9999,
                      padding: const EdgeInsets.all(10),
                      onTap: () => provider.toggleBookmark(
                        widget.verse.chapterNumber,
                        widget.verse.verseNumber,
                      ),
                      child: Icon(
                        isFav ? Icons.bookmark : Icons.bookmark_border,
                        color: isFav ? AppColors.primary : AppColors.textWhite,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable content ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Verse Card ──
                      _buildVerseCard(),

                      const SizedBox(height: 24),

                      // ── Word Meanings (collapsible) ──
                      if (widget.verse.wordMeanings.isNotEmpty)
                        _buildWordMeanings(),

                      // ── Translation Pills + Content ──
                      if (widget.verse.translations.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildTranslationPills(),
                        const SizedBox(height: 16),
                        _buildSelectedTranslation(),
                      ],

                      // ── Meaning (if available) ──
                      if (widget.verse.meaning.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildMeaningSection(),
                      ],

                      const SizedBox(height: 24),

                      // ── Audio Section (simulated) ──
                      _buildAudioSection(),

                      const SizedBox(height: 32),

                      // ── Related Verses ──
                      if (_relatedVerses.isNotEmpty)
                        _buildRelatedVerses(),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // ── Bottom Actions ──
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Original Sanskrit ──
        GlassCard(
          featured: true,
          borderColor: const Color(0x26ECB613),
          padding: const EdgeInsets.all(28),
          child: Stack(
            children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGhost,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(50),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'SANSKRIT (ORIGINAL)',
                          style: AppTextStyles.badge.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.verse.text,
                    style: AppTextStyles.sanskritLarge.copyWith(fontSize: 22),
                    textAlign: TextAlign.justify,
                  ),
                  if (widget.verse.translations.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'by ${widget.verse.translations.firstWhere((t) => t.language == 'sanskrit', orElse: () => VerseTranslation(id: 0, description: '', authorName: 'Unknown', language: '')).authorName}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textWhite60,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  // ── Word Meanings (collapsible) ──
  Widget _buildWordMeanings() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: Colors.teal.withAlpha(40),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 12),
          iconColor: AppColors.textWhite60,
          collapsedIconColor: AppColors.textWhite40,
          title: Row(
            children: [
              Icon(Icons.text_fields, size: 16, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                'WORD MEANINGS',
                style: AppTextStyles.badge.copyWith(
                  fontSize: 11,
                  color: Colors.teal,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          children: [
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.teal.withAlpha(0),
                    Colors.teal.withAlpha(50),
                    Colors.teal.withAlpha(0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.verse.wordMeanings.map((wm) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal.withAlpha(40)),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: wm.word,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.teal.shade200,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        if (wm.meaning.isNotEmpty) ...[
                          TextSpan(
                            text: ' — ',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textWhite40,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: wm.meaning,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textWhite70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Translation Pills ──
  Widget _buildTranslationPills() {
    final translations = widget.verse.translations;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: translations.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final t = translations[index];
          final isSelected = index == _selectedTranslationIndex;
          final label = t.authorName.isNotEmpty
              ? t.authorName
              : t.language.toUpperCase();
          return GestureDetector(
            onTap: () =>
                setState(() => _selectedTranslationIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(40)
                    : AppColors.glassBg,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.glassBorderLight,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color:
                        isSelected ? AppColors.primary : AppColors.textWhite60,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedTranslation() {
    final translations = widget.verse.translations;
    if (translations.isEmpty) return const SizedBox.shrink();
    final idx = _selectedTranslationIndex.clamp(0, translations.length - 1);
    final t = translations[idx];

    // Pick color based on language
    Color color;
    IconData icon;
    switch (t.language.toLowerCase()) {
      case 'english':
        color = Colors.blue;
        icon = Icons.abc;
        break;
      case 'hindi':
        color = Colors.orange;
        icon = Icons.language;
        break;
      case 'sanskrit':
        color = AppColors.primary;
        icon = Icons.auto_stories;
        break;
      default:
        color = Colors.purple;
        icon = Icons.translate;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: GlassCard(
        key: ValueKey(t.id),
        padding: const EdgeInsets.all(20),
        borderColor: color.withAlpha(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  t.language.toUpperCase(),
                  style: AppTextStyles.badge.copyWith(
                    fontSize: 11,
                    color: color,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withAlpha(0),
                    color.withAlpha(50),
                    color.withAlpha(0),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t.description,
              style: AppTextStyles.quoteText.copyWith(
                fontSize: 16,
                height: 1.6,
              ),
              textAlign: TextAlign.justify,
            ),
            if (t.authorName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '— ${t.authorName}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textWhite60,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeaningSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.primary.withAlpha(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'MEANING',
                style: AppTextStyles.badge.copyWith(
                  fontSize: 11,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withAlpha(0),
                  AppColors.primary.withAlpha(50),
                  AppColors.primary.withAlpha(0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.verse.meaning,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textWhite,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Play button
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(77),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow,
              color: AppColors.backgroundDark,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // Info + waveform
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sanskrit Recitation',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Param Pujya Swami-ji',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textWhite40,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '0:45 / 2:10',
                      style: AppTextStyles.badge.copyWith(
                        fontSize: 10,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Waveform bars
                _buildWaveform(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    final played = [12, 20, 8, 24, 16, 28, 12];
    final remaining = [20, 8, 24, 16, 28, 12, 20, 8, 16];

    return Row(
      children: [
        ...played.map((h) => _WaveBar(height: h.toDouble(), active: true)),
        ...remaining
            .map((h) => _WaveBar(height: h.toDouble(), active: false)),
      ],
    );
  }

  Widget _buildRelatedVerses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.relatedVerses,
                  style: AppTextStyles.sectionLabel.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 2,
                  )),
              Row(
                children: [
                  Text(
                    'View All',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textWhite40,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      size: 12, color: AppColors.textWhite40),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal carousel
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _relatedVerses.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final rv = _relatedVerses[index];
              return _RelatedVerseCard(
                verse: rv,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VerseDetailScreen(verse: rv),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _shareVerse() async {
    final v = widget.verse;
    final provider =
      Provider.of<AppStateProvider>(context, listen: false);
    final text =
        '"${v.meaning.isNotEmpty ? v.meaning : v.text}"\n\n'
        '— Bhagavad Gita, Chapter ${v.chapterNumber}, Verse ${v.verseNumber}\n\n'
        'Discover more wisdom in the Bhagavad Gita app.';
    await SharePlus.instance.share(ShareParams(text: text));
    provider.incrementShareCount();
  }

  Widget _buildBottomActions() {
    final provider = Provider.of<AppStateProvider>(context);
    final isBookmarked = provider.isBookmarked(
        widget.verse.chapterNumber, widget.verse.verseNumber);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          color: AppColors.backgroundDark.withAlpha(77),
          child: Row(
            children: [
              // Share button
              Expanded(
                child: GlassCard(
                  onTap: _shareVerse,
                  borderRadius: 9999,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderColor: AppColors.textWhite20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.share,
                          size: 18, color: AppColors.textWhite),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.shareQuote,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Bookmark button
              GlassCard(
                onTap: () => provider.toggleBookmark(
                    widget.verse.chapterNumber, widget.verse.verseNumber),
                borderRadius: 9999,
                padding: const EdgeInsets.all(16),
                borderColor: isBookmarked
                    ? AppColors.primary.withAlpha(128)
                    : AppColors.textWhite20,
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 20,
                  color: isBookmarked ? AppColors.primary : AppColors.textWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveBar extends StatelessWidget {
  final double height;
  final bool active;

  const _WaveBar({required this.height, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.textWhite20,
        borderRadius: BorderRadius.circular(9999),
      ),
    );
  }
}

class _RelatedVerseCard extends StatelessWidget {
  final Verse verse;
  final VoidCallback? onTap;

  const _RelatedVerseCard({required this.verse, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGhost,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'CH ${verse.chapterNumber} • V ${verse.verseNumber}',
                    style: AppTextStyles.badge.copyWith(fontSize: 10),
                  ),
                ),
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.textWhite20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                verse.meaning.isNotEmpty
                    ? '"${verse.meaning}"'
                    : verse.text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textWhite70,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
