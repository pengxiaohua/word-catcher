import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_catcher/core/theme/theme.dart';
import 'package:word_catcher/core/widgets/widgets.dart';

import '../data/voice_settings_notifier.dart';
import '../domain/tts_voice_option.dart';

class VoiceSettingsPage extends ConsumerWidget {
  const VoiceSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(voiceSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('发音设置')),
      body: SafeArea(
        child: settings.when(
          data: (data) => ListView(
            padding: AppSpacing.screen,
            children: [
              _WordVoiceNote(),
              const SizedBox(height: AppSpacing.lg),
              Text('例句发音', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '选择后，下一次拍照生成的 3 条例句会使用这个声音。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              RadioGroup<SentenceTtsVoice>(
                groupValue: data.sentenceVoice,
                onChanged: (voice) {
                  if (voice == null) {
                    return;
                  }
                  ref
                      .read(voiceSettingsProvider.notifier)
                      .updateSentenceVoice(voice);
                },
                child: Column(
                  children: [
                    for (final voice in SentenceTtsVoice.values) ...[
                      _VoiceOptionCard(
                        voice: voice,
                        selected: data.sentenceVoice == voice,
                        onSelected: () => ref
                            .read(voiceSettingsProvider.notifier)
                            .updateSentenceVoice(voice),
                      ),
                      if (voice != SentenceTtsVoice.values.last)
                        const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: AppSpacing.screen,
            child: LoadingStateView(title: '正在读取发音偏好', compact: true),
          ),
          error: (error, stackTrace) => Padding(
            padding: AppSpacing.screen,
            child: ErrorStateView(
              title: '设置暂时不可用',
              message: '发音偏好没有读取成功，请稍后再试。',
              retryLabel: '重试',
              onRetry: () => ref.invalidate(voiceSettingsProvider),
            ),
          ),
        ),
      ),
    );
  }
}

class _WordVoiceNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: AppRadius.medium,
            ),
            child: Padding(
              padding: AppSpacing.compactCard,
              child: Icon(
                Icons.record_voice_over_rounded,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('单词发音', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '美式单词默认女声-美式，英式单词默认女声-英式。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceOptionCard extends StatelessWidget {
  const _VoiceOptionCard({
    required this.voice,
    required this.selected,
    required this.onSelected,
  });

  final SentenceTtsVoice voice;
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
          _VoiceIcon(voice: voice, selected: selected),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        voice.label,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _AccentBadge(label: voice.accentLabel),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  voice.description,
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
          Radio<SentenceTtsVoice>(value: voice),
        ],
      ),
    );
  }
}

class _VoiceIcon extends StatelessWidget {
  const _VoiceIcon({required this.voice, required this.selected});

  final SentenceTtsVoice voice;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUs = voice.accentLabel == '美式';
    final icon = switch (voice) {
      SentenceTtsVoice.femaleUs ||
      SentenceTtsVoice.femaleUk => Icons.face_3_rounded,
      SentenceTtsVoice.maleUs || SentenceTtsVoice.maleUk => Icons.face_rounded,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primary
            : isUs
            ? colorScheme.secondaryContainer
            : colorScheme.tertiaryContainer,
        borderRadius: AppRadius.medium,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(
          icon,
          color: selected
              ? colorScheme.onPrimary
              : isUs
              ? colorScheme.onSecondaryContainer
              : colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

class _AccentBadge extends StatelessWidget {
  const _AccentBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
