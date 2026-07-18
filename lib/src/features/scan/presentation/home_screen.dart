import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:word_catcher/core/theme/theme.dart';
import 'package:word_catcher/core/widgets/widgets.dart';

import '../../settings/data/voice_settings_notifier.dart';
import '../../share_card/models/share_card_data.dart';
import '../../share_card/pages/share_card_editor_page.dart';
import '../domain/analyze_result.dart';
import 'result_card_widget.dart';
import 'scan_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _meaningLanguage = '中文';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanNotifierProvider);
    final voiceSettings = ref.watch(voiceSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: AppBottomNavigationLayout.pageScrollPadding(context),
          children: [
            const _HomeGreeting(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              '拍照识物，学会英语',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '把身边的小物拍下来，收集今天闪闪发光的新单词。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _CapturePanel(
              isLoading: state.isLoading,
              sentenceVoiceLabel:
                  voiceSettings.value?.sentenceVoice.label ?? '女声-美式',
              sentenceDifficultyLabel:
                  voiceSettings.value?.sentenceDifficulty.label ?? 'A1-小学',
              onCamera: () => _analyze(ImageSource.camera),
              onGallery: () => _analyze(ImageSource.gallery),
            ),
            if (state.isLoading) ...[
              const SizedBox(height: AppSpacing.lg),
              LoadingStateView(
                title: state.loadingLabel,
                message: '请稍等，正在把照片整理成学习卡片。',
                compact: true,
              ),
            ],
            if (state.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ErrorStateView(
                title: '识别没有完成',
                message: state.errorMessage!,
                retryLabel: '清除',
                onRetry: () => ref.read(scanNotifierProvider.notifier).reset(),
                compact: true,
              ),
            ],
            if (state.localImagePath != null && state.result == null) ...[
              const SizedBox(height: AppSpacing.lg),
              _ImagePreview(path: state.localImagePath!),
            ],
            if (state.result != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ResultCardWidget(
                result: state.result!,
                targetLanguage: _meaningLanguage,
                localImagePath: state.localImagePath,
                onGenerateShareCard: () =>
                    _openShareCardEditor(state.result!, state.localImagePath),
                onSaveToWordbook: _saveToWordbook,
                onTakeAnotherPhoto: () => _analyze(ImageSource.camera),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _analyze(ImageSource source) {
    final voiceSettings =
        ref.read(voiceSettingsProvider).value ?? const VoiceSettings();
    ref
        .read(scanNotifierProvider.notifier)
        .analyzeFrom(
          source: source,
          targetLanguage: _meaningLanguage,
          sentenceVoiceId: voiceSettings.sentenceVoice.id,
          sentenceDifficulty: voiceSettings.sentenceDifficulty.id,
        );
  }

  void _openShareCardEditor(AnalyzeResult result, String? localImagePath) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ShareCardEditorPage(
          initialData: ShareCardData.fromAnalyzeResult(
            result: result,
            targetLanguage: _meaningLanguage,
            localImagePath: localImagePath,
          ),
        ),
      ),
    );
  }

  void _saveToWordbook() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已放进学习页，稍后可以继续复习和分享。')));
  }
}

class _HomeGreeting extends StatelessWidget {
  const _HomeGreeting();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.macaronPinkSoft,
      borderColor: AppColors.macaronPinkSoft,
      child: Row(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.paper,
              borderRadius: AppRadius.large,
            ),
            child: Padding(
              padding: AppSpacing.compactCard,
              child: Icon(
                Icons.wb_sunny_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今天也去捕捉词光吧',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '照片、发音、例句和跟读练习，会一起变成你的学习卡。',
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

class _CapturePanel extends StatelessWidget {
  const _CapturePanel({
    required this.isLoading,
    required this.sentenceVoiceLabel,
    required this.sentenceDifficultyLabel,
    required this.onCamera,
    required this.onGallery,
  });

  final bool isLoading;
  final String sentenceVoiceLabel;
  final String sentenceDifficultyLabel;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.macaronMintSoft,
      borderColor: AppColors.macaronMintSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Icons.camera_alt_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '捕捉身边的英文单词',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '拍一张照片，生成单词、音标、例句和可分享的学习卡。例句：$sentenceDifficultyLabel · $sentenceVoiceLabel。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppButton.primary(
                  icon: Icons.photo_camera_rounded,
                  label: '拍照识别',
                  onPressed: isLoading ? null : onCamera,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton.tonal(
                  icon: Icons.photo_library_rounded,
                  label: '相册选择',
                  onPressed: isLoading ? null : onGallery,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final image = kIsWeb
        ? Image.network(path, fit: BoxFit.cover)
        : Image.file(File(path), fit: BoxFit.cover);

    return ClipRRect(
      borderRadius: AppRadius.small,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: image,
        ),
      ),
    );
  }
}
