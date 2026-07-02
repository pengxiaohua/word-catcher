import 'package:flutter/material.dart';

import '../theme/theme.dart';

class ScoreBadge extends StatelessWidget {
  const ScoreBadge({
    required this.score,
    this.label,
    this.compact = false,
    super.key,
  });

  final int score;
  final String? label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = _colors(context);
    final text = label ?? '跟读 $score 分';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: AppRadius.pill,
        border: Border.all(color: colors.foreground.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : AppSpacing.md,
          vertical: compact ? AppSpacing.xxs : AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: compact ? 16 : 18, color: colors.foreground),
            const SizedBox(width: AppSpacing.xs),
            Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: colors.foreground),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    if (score >= 85) {
      return Icons.verified_rounded;
    }
    if (score >= 60) {
      return Icons.trending_up_rounded;
    }
    return Icons.refresh_rounded;
  }

  _ScoreBadgeColors _colors(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (score >= 85) {
      return const _ScoreBadgeColors(
        foreground: AppColors.success,
        background: AppColors.successContainer,
      );
    }
    if (score >= 60) {
      return const _ScoreBadgeColors(
        foreground: AppColors.warning,
        background: AppColors.warningContainer,
      );
    }
    return _ScoreBadgeColors(
      foreground: colorScheme.error,
      background: colorScheme.errorContainer,
    );
  }
}

class _ScoreBadgeColors {
  const _ScoreBadgeColors({required this.foreground, required this.background});

  final Color foreground;
  final Color background;
}
