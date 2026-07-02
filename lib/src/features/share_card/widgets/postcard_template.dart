import 'package:flutter/material.dart';
import 'package:word_catcher/core/theme/theme.dart';

import '../models/share_card_data.dart';
import 'share_card_photo.dart';
import 'share_card_template_helpers.dart';

class PostcardTemplate extends StatelessWidget {
  const PostcardTemplate({required this.data, super.key});

  final ShareCardData data;

  @override
  Widget build(BuildContext context) {
    final sentence = data.selectedSentence;
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: AppColors.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ShareCardPhoto(
                  imageUrl: data.imageUrl,
                  localImagePath: data.localImagePath,
                ),
                Positioned(
                  left: AppSpacing.lg,
                  top: AppSpacing.lg,
                  child: ShareCardTextPill(
                    text: 'LIFE WORD',
                    foreground: Colors.white,
                    background: Colors.black.withValues(alpha: 0.32),
                  ),
                ),
                if (data.showDate && data.createdAt != null)
                  Positioned(
                    right: AppSpacing.lg,
                    top: AppSpacing.lg,
                    child: ShareCardTextPill(
                      text: formatShareCardDate(data.createdAt!),
                      foreground: Colors.white,
                      background: Colors.black.withValues(alpha: 0.32),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: AppSpacing.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data.englishWord,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.photoInk,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                  if (data.showPhoneticText && data.phoneticText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        data.phoneticText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (data.showChineseMeaning &&
                      data.chineseMeaning.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      data.chineseMeaning,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.photoInk,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  if (data.showSentence && sentence != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Divider(color: colorScheme.outlineVariant),
                    const SizedBox(height: AppSpacing.xs),
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
                  if (data.showWatermark)
                    const ShareCardWatermark(color: AppColors.mutedInk),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
