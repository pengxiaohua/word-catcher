import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'app_button.dart';
import 'app_card.dart';

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({
    required this.title,
    this.message,
    this.progress,
    this.compact = false,
    this.useCard = true,
    super.key,
  });

  final String title;
  final String? message;
  final double? progress;
  final bool compact;
  final bool useCard;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(value: progress, borderRadius: AppRadius.pill),
        SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    if (!useCard) {
      return content;
    }

    return AppCard(
      padding: compact ? AppSpacing.compactCard : AppSpacing.card,
      child: content,
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.title,
    this.message,
    this.icon = Icons.photo_library_outlined,
    this.actionLabel,
    this.onAction,
    this.useCard = true,
    super.key,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool useCard;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: colorScheme.primary),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: AppSpacing.lg),
          AppButton.tonal(label: actionLabel!, onPressed: onAction),
        ],
      ],
    );

    if (!useCard) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        child: content,
      );
    }

    return AppCard(child: content);
  }
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    required this.message,
    this.title = '暂时没有成功',
    this.retryLabel = '重试',
    this.onRetry,
    this.compact = false,
    this.useCard = true,
    super.key,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;
  final bool compact;
  final bool useCard;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.error_outline_rounded, color: colorScheme.error),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                message,
                maxLines: compact ? 3 : 5,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton.text(label: retryLabel, onPressed: onRetry),
              ],
            ],
          ),
        ),
      ],
    );

    if (!useCard) {
      return content;
    }

    return AppCard(
      backgroundColor: colorScheme.errorContainer,
      borderColor: colorScheme.error.withValues(alpha: 0.16),
      padding: compact ? AppSpacing.compactCard : AppSpacing.card,
      shadows: AppShadows.none,
      child: content,
    );
  }
}
