import 'dart:io';

import 'package:flutter/material.dart';
import 'package:word_catcher/core/theme/theme.dart';
import 'package:word_catcher/core/widgets/widgets.dart';

import '../models/share_card_data.dart';
import '../models/share_card_template.dart';
import '../services/share_card_export_service.dart';
import '../widgets/share_card_preview.dart';
import '../widgets/template_selector.dart';

class ShareCardEditorPage extends StatefulWidget {
  const ShareCardEditorPage({required this.initialData, super.key});

  final ShareCardData initialData;

  @override
  State<ShareCardEditorPage> createState() => _ShareCardEditorPageState();
}

class _ShareCardEditorPageState extends State<ShareCardEditorPage> {
  final GlobalKey _cardKey = GlobalKey();
  final ShareCardExportService _exportService = const ShareCardExportService();

  late ShareCardData _data;
  _ExportAction? _activeExport;
  String? _exportError;

  bool get _isExporting => _activeExport != null;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('制作单词卡')),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screen,
          children: [
            Text(
              '把今天捕捉到的单词，做成一张可以分享的照片卡。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: RepaintBoundary(
                  key: _cardKey,
                  child: ShareCardPreview(data: _data),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionTitle(title: '选择样式', subtitle: _data.template.description),
            const SizedBox(height: AppSpacing.sm),
            TemplateSelector(
              selected: _data.template,
              onChanged: (template) => _update(template: template),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_data.sentences.length > 1) ...[
              _SectionTitle(title: '选择例句', subtitle: '卡片只放一句，留出一点呼吸感。'),
              const SizedBox(height: AppSpacing.sm),
              _SentenceSelector(
                data: _data,
                onChanged: (index) => _update(selectedSentenceIndex: index),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            _SectionTitle(title: '显示内容', subtitle: '按你想分享的重点来取舍。'),
            const SizedBox(height: AppSpacing.sm),
            _DisplayOptions(data: _data, onChanged: _update),
            if (_activeExport != null) ...[
              const SizedBox(height: AppSpacing.lg),
              LoadingStateView(
                title: _activeExport == _ExportAction.share
                    ? '正在生成分享图片'
                    : '正在保存图片',
                message: '会导出高清 PNG，不会截取结果页。',
                compact: true,
              ),
            ],
            if (_exportError != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ErrorStateView(
                title: '导出没有成功',
                message: _exportError!,
                retryLabel: '知道了',
                onRetry: () => setState(() => _exportError = null),
                compact: true,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: AppButton.tonal(
                    label: '保存图片',
                    icon: Icons.download_rounded,
                    isLoading: _activeExport == _ExportAction.save,
                    onPressed: _isExporting ? null : _saveCard,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton.primary(
                    label: '分享卡片',
                    icon: Icons.ios_share_rounded,
                    isLoading: _activeExport == _ExportAction.share,
                    onPressed: _isExporting ? null : _shareCard,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _update({
    ShareCardTemplate? template,
    int? selectedSentenceIndex,
    bool? showChineseMeaning,
    bool? showPhoneticText,
    bool? showSentence,
    bool? showDate,
    bool? showWatermark,
  }) {
    setState(() {
      _exportError = null;
      _data = _data.copyWith(
        template: template,
        selectedSentenceIndex: selectedSentenceIndex,
        showChineseMeaning: showChineseMeaning,
        showPhoneticText: showPhoneticText,
        showSentence: showSentence,
        showDate: showDate,
        showWatermark: showWatermark,
      );
    });
  }

  Future<void> _saveCard() async {
    await _runExport(_ExportAction.save, () async {
      final file = await _exportService.saveCard(
        boundaryKey: _cardKey,
        fileNamePrefix: 'wordcatcher-${_data.safeFileWord}',
      );
      if (!mounted) {
        return;
      }
      _showSuccess('单词卡已保存：${_shortPath(file)}');
    });
  }

  Future<void> _shareCard() async {
    await _runExport(_ExportAction.share, () async {
      final box = context.findRenderObject() as RenderBox?;
      await _exportService.shareCard(
        boundaryKey: _cardKey,
        fileNamePrefix: 'wordcatcher-${_data.safeFileWord}',
        word: _data.englishWord,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      );
      if (!mounted) {
        return;
      }
      _showSuccess('单词卡已交给系统分享。');
    });
  }

  Future<void> _runExport(
    _ExportAction action,
    Future<void> Function() run,
  ) async {
    setState(() {
      _activeExport = action;
      _exportError = null;
    });

    try {
      await run();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _exportError = error.toString());
    } finally {
      if (mounted) {
        setState(() => _activeExport = null);
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _shortPath(File file) {
    final parts = file.path.split(Platform.pathSeparator);
    if (parts.length <= 2) {
      return file.path;
    }
    return parts.sublist(parts.length - 2).join(Platform.pathSeparator);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SentenceSelector extends StatelessWidget {
  const _SentenceSelector({required this.data, required this.onChanged});

  final ShareCardData data;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: data.selectedSentenceIndex.clamp(
        0,
        data.sentences.length - 1,
      ),
      decoration: const InputDecoration(labelText: '卡片例句'),
      items: [
        for (var index = 0; index < data.sentences.length; index++)
          DropdownMenuItem<int>(
            value: index,
            child: Text(
              data.sentences[index].english,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _DisplayOptions extends StatelessWidget {
  const _DisplayOptions({required this.data, required this.onChanged});

  final ShareCardData data;
  final void Function({
    bool? showChineseMeaning,
    bool? showPhoneticText,
    bool? showSentence,
    bool? showDate,
    bool? showWatermark,
  })
  onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _OptionSwitch(
            title: '显示中文释义',
            value: data.showChineseMeaning,
            onChanged: (value) => onChanged(showChineseMeaning: value),
          ),
          _OptionSwitch(
            title: '显示音标',
            value: data.showPhoneticText,
            onChanged: (value) => onChanged(showPhoneticText: value),
          ),
          _OptionSwitch(
            title: '显示例句',
            value: data.showSentence,
            onChanged: (value) => onChanged(showSentence: value),
          ),
          _OptionSwitch(
            title: '显示日期',
            value: data.showDate,
            onChanged: (value) => onChanged(showDate: value),
          ),
          _OptionSwitch(
            title: '显示水印',
            value: data.showWatermark,
            onChanged: (value) => onChanged(showWatermark: value),
          ),
        ],
      ),
    );
  }
}

class _OptionSwitch extends StatelessWidget {
  const _OptionSwitch({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
    );
  }
}

enum _ExportAction { save, share }
