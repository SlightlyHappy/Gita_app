import 'package:flutter/material.dart';
import '../models/bhagavad_gita_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/cosmic_background.dart';

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
  late Future<List<Verse>> futureVerses;

  @override
  void initState() {
    super.initState();
    futureVerses = ApiService.fetchVerses(widget.chapterNumber);
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
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Verses Content (Book-like Reading) ──
              Expanded(
                child: FutureBuilder<List<Verse>>(
                  future: futureVerses,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: AppColors.primary),
                            const SizedBox(height: 16),
                            Text('Could not load verses',
                                style: AppTextStyles.bodyMedium),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  futureVerses = ApiService.fetchVerses(
                                      widget.chapterNumber);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text('Retry',
                                    style: AppTextStyles.buttonText),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final verses = snapshot.data ?? [];

                    return SingleChildScrollView(
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
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: AppColors.primary,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Verse number label
                                    Text(
                                      'Verse ${verse.verseNumber}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                        fontSize: 11,
                                      ),
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
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
