import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/bhagavad_gita_model.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';
import 'glass_card.dart';

/// Versatile verse card used in feeds and lists.
/// Shows chapter/verse reference, Sanskrit text, translation, and action buttons.
/// Long-press opens a context menu with bookmark, mark-as-read, copy, share.
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

  void _showContextMenu(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    final isBookmarked =
        provider.isBookmarked(verse.chapterNumber, verse.verseNumber);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundDarkAlt,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle indicator
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.textWhite20,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Chapter ${verse.chapterNumber}, Verse ${verse.verseNumber}',
                style: AppTextStyles.h3.copyWith(fontSize: 15),
              ),
            ),
            const SizedBox(height: 8),

            _ContextMenuItem(
              icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              label: isBookmarked ? 'Remove Bookmark' : 'Bookmark',
              onTap: () {
                provider.toggleBookmark(
                    verse.chapterNumber, verse.verseNumber);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isBookmarked
                        ? 'Bookmark removed'
                        : 'Verse bookmarked'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: AppColors.backgroundDarkAlt,
                  ),
                );
              },
            ),
            _ContextMenuItem(
              icon: Icons.bookmark_added_outlined,
              label: 'Mark as Last Read',
              onTap: () {
                provider.markLastReadLocation(
                    verse.chapterNumber, verse.verseNumber);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Marked as last read'),
                    duration: Duration(seconds: 1),
                    backgroundColor: AppColors.backgroundDarkAlt,
                  ),
                );
              },
            ),
            _ContextMenuItem(
              icon: Icons.copy,
              label: 'Copy',
              onTap: () {
                final textToCopy =
                    'Chapter ${verse.chapterNumber}, Verse ${verse.verseNumber}\n\n'
                    '${verse.text}\n\n'
                    '${verse.meaning}';
                Clipboard.setData(ClipboardData(text: textToCopy));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 1),
                    backgroundColor: AppColors.backgroundDarkAlt,
                  ),
                );
              },
            ),
            _ContextMenuItem(
              icon: Icons.share,
              label: 'Share',
              onTap: () async {
                final shareText =
                    '📖 Bhagavad Gita — Chapter ${verse.chapterNumber}, Verse ${verse.verseNumber}\n\n'
                    '${verse.text}\n\n'
                    '"${verse.meaning}"\n\n'
                    '— From the Bhagavad Gita App';
                Navigator.pop(ctx);
                await SharePlus.instance.share(ShareParams(text: shareText));
                provider.incrementShareCount();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final isMarked =
        provider.isBookmarked(verse.chapterNumber, verse.verseNumber);

    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: GlassCard(
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
              style: featured
                  ? AppTextStyles.sanskritLarge
                  : AppTextStyles.sanskrit,
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
                  : AppTextStyles.bodyMedium
                      .copyWith(fontStyle: FontStyle.italic),
              maxLines: featured ? null : 3,
              overflow: featured ? null : TextOverflow.ellipsis,
            ),

            // Action row
            const SizedBox(height: 16),
            Row(
              children: [
                _ActionButton(
                  icon: isMarked
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  label: isMarked ? 'Bookmarked' : 'Bookmark',
                  color: isMarked
                      ? AppColors.primary
                      : AppColors.textWhite40,
                  onTap: () => provider.toggleBookmark(
                    verse.chapterNumber,
                    verse.verseNumber,
                  ),
                ),
                const Spacer(),
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
                  child: const Icon(
                    Icons.ios_share,
                    size: 18,
                    color: AppColors.textWhite40,
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
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ContextMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContextMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium
            .copyWith(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
