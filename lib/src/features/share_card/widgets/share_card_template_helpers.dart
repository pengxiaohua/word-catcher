import 'package:flutter/material.dart';
import 'package:word_catcher/core/theme/theme.dart';

String formatShareCardDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}.$month.$day';
}

class ShareCardWatermark extends StatelessWidget {
  const ShareCardWatermark({
    this.color,
    this.alignment = MainAxisAlignment.start,
    super.key,
  });

  final Color? color;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.camera_alt_outlined,
          size: 13,
          color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          '拍沃德 / WordCatcher',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class ShareCardTextPill extends StatelessWidget {
  const ShareCardTextPill({
    required this.text,
    this.foreground,
    this.background,
    super.key,
  });

  final String text;
  final Color? foreground;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background ?? colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: foreground ?? colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
