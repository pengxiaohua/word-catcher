import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:word_catcher/core/theme/theme.dart';
import 'package:word_catcher/core/widgets/widgets.dart';

import '../../history/presentation/history_screen.dart';
import '../../settings/data/voice_settings_notifier.dart';
import '../../settings/presentation/voice_settings_page.dart';
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
      appBar: AppBar(
        title: const Text('拍沃德 WordCatcher'),
        actions: [
          IconButton(
            tooltip: '发音设置',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const VoiceSettingsPage(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: '历史生词本',
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            Text(
              '拍照识物，学会英语',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '选择照片后会识别英文单词，并生成中文释义、例句和英美发音。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _CapturePanel(
              isLoading: state.isLoading,
              sentenceVoiceLabel:
                  voiceSettings.value?.sentenceVoice.label ?? '女声-美式',
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
    ).showSnackBar(const SnackBar(content: Text('已放进生词本，稍后可以在历史里复习。')));
  }
}

class _CapturePanel extends StatelessWidget {
  const _CapturePanel({
    required this.isLoading,
    required this.sentenceVoiceLabel,
    required this.onCamera,
    required this.onGallery,
  });

  final bool isLoading;
  final String sentenceVoiceLabel;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Icons.camera_alt_outlined,
                    color: colorScheme.onPrimaryContainer,
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
                      '拍一张照片，生成单词、音标、例句和可分享的学习卡。例句：$sentenceVoiceLabel。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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
