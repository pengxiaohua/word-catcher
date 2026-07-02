import 'package:flutter/material.dart';
import 'package:word_catcher/core/theme/theme.dart';

import '../models/share_card_data.dart';
import 'share_card_photo.dart';
import 'share_card_template_helpers.dart';

class MagazineTemplate extends StatelessWidget {
  const MagazineTemplate({required this.data, super.key});

  final ShareCardData data;

  @override
  Widget build(BuildContext context) {
    final sentence = data.selectedSentence;

    return Stack(
      fit: StackFit.expand,
      children: [
        ShareCardPhoto(
          imageUrl: data.imageUrl,
          localImagePath: data.localImagePath,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x990B1120), Color(0x220B1120), Color(0xDD0B1120)],
              stops: [0, 0.42, 1],
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'WORD FIELD NOTES',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (data.showDate && data.createdAt != null)
                ShareCardTextPill(
                  text: formatShareCardDate(data.createdAt!),
                  foreground: Colors.white,
                  background: Colors.white.withValues(alpha: 0.18),
                ),
            ],
          ),
        ),
        Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.showChineseMeaning && data.chineseMeaning.isNotEmpty)
                ShareCardTextPill(
                  text: data.chineseMeaning,
                  foreground: AppColors.photoInk,
                  background: Colors.white.withValues(alpha: 0.86),
                ),
              const SizedBox(height: AppSpacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  data.englishWord,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                  ),
                ),
              ),
              if (data.showPhoneticText && data.phoneticText.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  data.phoneticText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.postcardGold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
              if (data.showSentence && sentence != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  sentence.english,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
              if (data.showWatermark) ...[
                const SizedBox(height: AppSpacing.lg),
                ShareCardWatermark(color: Colors.white.withValues(alpha: 0.78)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
