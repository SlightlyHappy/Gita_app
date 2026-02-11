import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bhagavad_gita_model.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import 'glass_card.dart';

/// Versatile verse card used in feeds and lists.
/// Shows chapter/verse reference, Sanskrit text, translation, and action buttons.
class VerseCard extends StatelessWidget {
  final Verse verse;
  final bool featured;
  final VoidCallback? onTap;

  const VerseCard({
    super.key,
    required this.verse,
    this.featured = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final isFav = provider.isFavorite(verse.chapterNumber, verse.verseNumber);

    return GlassCard(
      featured: featured,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse reference
          Text(
            'Chapter ${verse.chapterNumber} • Verse ${verse.verseNumber}',
            style: AppTextStyles.verseRef,
          ),
          const SizedBox(height: 12),

          // Sanskrit text
          Text(
            verse.text,
            style: featured ? AppTextStyles.sanskritLarge : AppTextStyles.sanskrit,
            maxLines: featured ? null : 3,
            overflow: featured ? null : TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Translation / meaning
          Text(
            verse.meaning.isNotEmpty
                ? '"${verse.meaning}"'
                : verse.transliteration,
            style: featured
                ? AppTextStyles.quoteText
                : AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic),
            maxLines: featured ? null : 3,
            overflow: featured ? null : TextOverflow.ellipsis,
          ),

          // Action row
          const SizedBox(height: 16),
          Row(
            children: [
              _ActionButton(
                icon: isFav ? Icons.favorite : Icons.favorite_border,
                label: isFav ? 'Saved' : 'Save',
                color: isFav ? AppColors.primary : AppColors.textWhite40,
                onTap: () => provider.toggleFavorite(
                  verse.chapterNumber,
                  verse.verseNumber,
                ),
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.bookmark_border,
                label: 'Bookmark',
                color: AppColors.textWhite40,
                onTap: () {},
              ),
              const Spacer(),
              Icon(
                Icons.ios_share,
                size: 18,
                color: AppColors.textWhite40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
