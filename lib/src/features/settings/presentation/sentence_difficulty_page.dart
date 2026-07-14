import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_catcher/core/theme/theme.dart';
import 'package:word_catcher/core/widgets/widgets.dart';

import '../data/voice_settings_notifier.dart';
import '../domain/example_sentence_difficulty.dart';

class SentenceDifficultyPage extends ConsumerWidget {
  const SentenceDifficultyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(voiceSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('例句难度')),
      body: SafeArea(
        child: settings.when(
          data: (data) => ListView(
            padding: AppSpacing.screen,
            children: [
              const _DifficultyNote(),
              const SizedBox(height: AppSpacing.lg),
              Text('选择例句水平', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '下一次拍照生成的 3 条例句，会按所选学段控制词汇和句式。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              RadioGroup<ExampleSentenceDifficulty>(
                groupValue: data.sentenceDifficulty,
                onChanged: (difficulty) {
                  if (difficulty == null) {
                    return;
                  }
                  ref
                      .read(voiceSettingsProvider.notifier)
                      .updateSentenceDifficulty(difficulty);
                },
                child: Column(
                  children: [
                    for (final difficulty
                        in ExampleSentenceDifficulty.values) ...[
                      _DifficultyOptionCard(
                        difficulty: difficulty,
                        selected: data.sentenceDifficulty == difficulty,
                        onSelected: () => ref
                            .read(voiceSettingsProvider.notifier)
                            .updateSentenceDifficulty(difficulty),
                      ),
                      if (difficulty != ExampleSentenceDifficulty.values.last)
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: AppSpacing.screen,
            child: LoadingStateView(title: '正在读取例句难度', compact: true),
          ),
          error: (error, stackTrace) => Padding(
            padding: AppSpacing.screen,
            child: ErrorStateView(
              title: '设置暂时不可用',
              message: '例句难度没有读取成功，请稍后再试。',
              retryLabel: '重试',
              onRetry: () => ref.invalidate(voiceSettingsProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyNote extends StatelessWidget {
  const _DifficultyNote();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      backgroundColor: AppColors.macaronSkySoft,
      borderColor: AppColors.macaronSkySoft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.paper,
              borderRadius: AppRadius.large,
            ),
            child: Padding(
              padding: AppSpacing.compactCard,
              child: Icon(
                Icons.auto_stories_rounded,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('让例句刚刚好', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '从 A1 到 B2 逐步增加句子长度和表达复杂度，跟读时更贴近你的学习阶段。',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyOptionCard extends StatelessWidget {
  const _DifficultyOptionCard({
    required this.difficulty,
    required this.selected,
    required this.onSelected,
  });

  final ExampleSentenceDifficulty difficulty;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      onTap: onSelected,
      shadows: selected ? AppShadows.card : AppShadows.none,
      borderColor: selected ? colorScheme.primary : colorScheme.outlineVariant,
      backgroundColor: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.36)
          : null,
      padding: AppSpacing.compactCard,
      child: Row(
        children: [
          _DifficultyBadge(difficulty: difficulty, selected: selected),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  difficulty.label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  difficulty.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Radio<ExampleSentenceDifficulty>(value: difficulty),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty, required this.selected});

  final ExampleSentenceDifficulty difficulty;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? colorScheme.primary : AppColors.macaronButterSoft,
        borderRadius: AppRadius.medium,
      ),
      child: SizedBox.square(
        dimension: 48,
        child: Center(
          child: Text(
            difficulty.shortLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: selected ? colorScheme.onPrimary : AppColors.photoInk,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
