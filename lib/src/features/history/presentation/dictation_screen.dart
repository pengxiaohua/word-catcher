import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_catcher/core/theme/theme.dart';
import 'package:word_catcher/core/widgets/widgets.dart';

import '../../scan/data/audio_playback_service.dart';
import '../domain/scan_history_item.dart';

class DictationScreen extends ConsumerStatefulWidget {
  const DictationScreen({required this.items, super.key});

  final List<ScanHistoryItem> items;

  @override
  ConsumerState<DictationScreen> createState() => _DictationScreenState();
}

class _DictationScreenState extends ConsumerState<DictationScreen> {
  late final TextEditingController _answerController;

  int _index = 0;
  int _correctCount = 0;
  bool _checked = false;
  bool _isCorrect = false;

  ScanHistoryItem get _current => widget.items[_index];

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playCurrent());
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.items.length;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('听写测试')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_index + 1) / total,
                borderRadius: AppRadius.pill,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('第 ${_index + 1} / $total 题'),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton.tonal(
                        icon: Icons.volume_up_rounded,
                        label: '播放单词音频',
                        onPressed: _playCurrent,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: _answerController,
                        enabled: !_checked,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: '拼写你听到的英文单词',
                        ),
                        onSubmitted: (_) => _checkAnswer(),
                      ),
                      if (_checked) ...[
                        const SizedBox(height: AppSpacing.md),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: _isCorrect
                                ? colorScheme.primaryContainer
                                : colorScheme.errorContainer,
                            borderRadius: AppRadius.medium,
                          ),
                          child: Padding(
                            padding: AppSpacing.compactCard,
                            child: Text(
                              _isCorrect
                                  ? '拼写正确，很稳！'
                                  : '正确答案：${_current.sourceWord}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _isCorrect
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onErrorContainer,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              AppButton.primary(
                onPressed: _checked ? _next : _checkAnswer,
                label: _checked ? '下一题' : '提交答案',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playCurrent() async {
    try {
      await ref
          .read(audioPlaybackServiceProvider)
          .playUrl(_current.audioLinks.preferred);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('音频暂不可用：$error')));
    }
  }

  void _checkAnswer() {
    final answer = _answerController.text.trim().toLowerCase();
    final expected = _current.sourceWord.trim().toLowerCase();
    setState(() {
      _checked = true;
      _isCorrect = answer == expected;
      if (_isCorrect) {
        _correctCount++;
      }
    });
  }

  void _next() {
    if (_index == widget.items.length - 1) {
      _showSummary();
      return;
    }

    setState(() {
      _index++;
      _checked = false;
      _isCorrect = false;
      _answerController.clear();
    });
    _playCurrent();
  }

  void _showSummary() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('测试完成'),
          content: Text(
            '本次答对 $_correctCount / ${widget.items.length} 个单词。继续练会更熟。',
          ),
          actions: [
            AppButton.text(
              label: '返回词库',
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            AppButton.primary(
              label: '再来一次',
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _index = 0;
                  _correctCount = 0;
                  _checked = false;
                  _isCorrect = false;
                  _answerController.clear();
                });
                _playCurrent();
              },
            ),
          ],
        );
      },
    );
  }
}
