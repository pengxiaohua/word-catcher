import 'package:flutter/material.dart';
import 'package:word_catcher/core/theme/theme.dart';

import '../models/share_card_data.dart';
import 'share_card_photo.dart';
import 'share_card_template_helpers.dart';

class FilmNoteTemplate extends StatelessWidget {
  const FilmNoteTemplate({required this.data, super.key});

  final ShareCardData data;

  @override
  Widget build(BuildContext context) {
    final sentence = data.selectedSentence;
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFF4EAD8)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: AppRadius.medium,
            boxShadow: AppShadows.floating,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const ShareCardTextPill(text: 'FILM 03'),
                    const Spacer(),
                    if (data.showDate && data.createdAt != null)
                      Text(
                        formatShareCardDate(data.createdAt!),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  flex: 7,
                  child: ClipRRect(
                    borderRadius: AppRadius.small,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ShareCardPhoto(
                          imageUrl: data.imageUrl,
                          localImagePath: data.localImagePath,
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.38),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              child: Text(
                                data.englishWord.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.englishWord,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.photoInk,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (data.showPhoneticText && data.phoneticText.isNotEmpty)
                      ShareCardTextPill(text: data.phoneticText),
                    if (data.showChineseMeaning &&
                        data.chineseMeaning.isNotEmpty)
                      ShareCardTextPill(text: data.chineseMeaning),
                  ],
                ),
                if (data.showSentence && sentence != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    sentence.english,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.photoInk,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Captured from life',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (data.showWatermark)
                      const ShareCardWatermark(color: AppColors.mutedInk),
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
