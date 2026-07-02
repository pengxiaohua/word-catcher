import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_catcher/core/theme/theme.dart';
import 'package:word_catcher/core/widgets/widgets.dart';

import '../../scan/data/audio_playback_service.dart';
import '../data/history_api_service.dart';
import '../domain/scan_history_item.dart';
import 'dictation_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('历史生词本')),
      body: SafeArea(
        child: history.when(
          loading: () => const Center(
            child: Padding(
              padding: AppSpacing.screen,
              child: LoadingStateView(
                title: '正在整理生词本',
                message: '把最近捕捉到的单词带回来。',
                useCard: false,
              ),
            ),
          ),
          error: (error, _) => _HistoryError(
            message: error.toString(),
            onRetry: () => ref.invalidate(historyProvider),
          ),
          data: (items) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(historyProvider),
            child: ListView(
              padding: AppSpacing.screen,
              children: [
                AppButton.primary(
                  icon: Icons.hearing_rounded,
                  label: '开始听写测试',
                  onPressed: items.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => DictationScreen(items: items),
                            ),
                          );
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                if (items.isEmpty)
                  const _EmptyHistory()
                else
                  for (final item in items) _HistoryTile(item: item),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.item});

  final ScanHistoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: AppSpacing.compactCard,
        leading: ClipRRect(
          borderRadius: AppRadius.small,
          child: Image.network(
            item.imageUrl,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const SizedBox(
                width: 64,
                height: 64,
                child: Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
        ),
        title: Text(
          item.sourceWord,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(_formatDate(item.createdAt)),
        trailing: AudioPlayButton(
          label: '播放音频',
          tooltip: '播放音频',
          compact: true,
          onPressed: () => _playAudio(context, ref),
        ),
      ),
    );
  }

  Future<void> _playAudio(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(audioPlaybackServiceProvider)
          .playUrl(item.audioLinks.preferred);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('这个单词音频暂不可用：$error')));
    }
  }

  String _formatDate(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateView(
      title: '还没有识别记录',
      message: '拍下一张照片后，它会变成你的第一张生词卡。',
      useCard: false,
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screen,
      child: Center(
        child: ErrorStateView(
          title: '生词本暂时打不开',
          message: message,
          onRetry: onRetry,
          useCard: false,
        ),
      ),
    );
  }
}
