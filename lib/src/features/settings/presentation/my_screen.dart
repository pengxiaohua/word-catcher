import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_catcher/core/theme/theme.dart';
import 'package:word_catcher/core/widgets/widgets.dart';

import '../data/voice_settings_notifier.dart';
import '../domain/example_sentence_difficulty.dart';
import 'sentence_difficulty_page.dart';
import 'voice_settings_page.dart';

class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(voiceSettingsProvider);
    final voiceLabel = settings.value?.sentenceVoice.label ?? '女声-美式';
    final difficultyLabel =
        settings.value?.sentenceDifficulty.label ??
        ExampleSentenceDifficulty.a1.label;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            const _ProfileCard(),
            const SizedBox(height: AppSpacing.xl),
            Text('学习设置', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _SettingsTile(
              icon: Icons.record_voice_over_rounded,
              title: '发音设置',
              subtitle: '当前例句声音：$voiceLabel',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const VoiceSettingsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _SettingsTile(
              icon: Icons.auto_stories_rounded,
              title: '例句难度',
              subtitle: '当前水平：$difficultyLabel，生成例句会按这个学段控制。',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SentenceDifficultyPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            const _SettingsNote(),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.macaronButterSoft,
      borderColor: AppColors.macaronButterSoft,
      child: Row(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.macaronPinkSoft,
              borderRadius: AppRadius.large,
            ),
            child: Padding(
              padding: AppSpacing.compactCard,
              child: Icon(
                Icons.camera_alt_rounded,
                color: Theme.of(context).colorScheme.secondary,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('词光里', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '把生活里的照片，变成温柔的英语记忆。',
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.compactCard,
      child: Row(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.macaronMintSoft,
              borderRadius: AppRadius.medium,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.mutedInk),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.mutedInk),
        ],
      ),
    );
  }
}

class _SettingsNote extends StatelessWidget {
  const _SettingsNote();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.macaronLavenderSoft,
      borderColor: AppColors.macaronLavenderSoft,
      shadows: AppShadows.none,
      padding: AppSpacing.compactCard,
      child: Text(
        '照片词汇历史已经放在“学习”里，每个词都可以播放、听写和再次制作分享卡。',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.photoInk,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
