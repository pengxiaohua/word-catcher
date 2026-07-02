import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:word_catcher/core/theme/theme.dart';
import 'package:word_catcher/core/widgets/widgets.dart';

import '../data/audio_playback_service.dart';
import '../data/shadowing_service.dart';
import '../domain/analyze_result.dart';

class ResultCardWidget extends ConsumerWidget {
  const ResultCardWidget({
    required this.result,
    required this.targetLanguage,
    required this.onGenerateShareCard,
    required this.onSaveToWordbook,
    required this.onTakeAnotherPhoto,
    this.localImagePath,
    super.key,
  });

  final AnalyzeResult result;
  final String targetLanguage;
  final String? localImagePath;
  final VoidCallback onGenerateShareCard;
  final VoidCallback onSaveToWordbook;
  final VoidCallback onTakeAnotherPhoto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ResultHeroCard(
          result: result,
          targetLanguage: targetLanguage,
          localImagePath: localImagePath,
          onPlay: (url) => _play(context, ref, url, label: '单词音频'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PracticeIntro(onStartPractice: () => _showPracticeTip(context)),
        const SizedBox(height: AppSpacing.sm),
        for (var index = 0; index < result.sentences.length; index++) ...[
          _SentencePracticeCard(
            number: index + 1,
            sentence: result.sentences[index],
          ),
          if (index != result.sentences.length - 1)
            const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.lg),
        _ResultActions(
          onGenerateShareCard: onGenerateShareCard,
          onSaveToWordbook: onSaveToWordbook,
          onTakeAnotherPhoto: onTakeAnotherPhoto,
        ),
      ],
    );
  }

  Future<void> _play(
    BuildContext context,
    WidgetRef ref,
    String url, {
    required String label,
  }) async {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label还没有音频，先跟着音标试读吧。')));
      return;
    }

    try {
      await ref.read(audioPlaybackServiceProvider).playUrl(url);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label暂不可用：$error')));
    }
  }

  void _showPracticeTip(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('从任一句例句开始，读完后会看到跟读评分。')));
  }
}

class _ResultHeroCard extends StatelessWidget {
  const _ResultHeroCard({
    required this.result,
    required this.targetLanguage,
    required this.localImagePath,
    required this.onPlay,
  });

  final AnalyzeResult result;
  final String targetLanguage;
  final String? localImagePath;
  final ValueChanged<String> onPlay;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 340;
          final wordPanel = _WordPanel(
            result: result,
            targetLanguage: targetLanguage,
            onPlay: onPlay,
          );
          final photo = _ResultPhoto(
            imageUrl: result.imageUrl,
            localImagePath: localImagePath,
            isNarrow: isNarrow,
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                wordPanel,
                const SizedBox(height: AppSpacing.lg),
                photo,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: wordPanel),
              const SizedBox(width: AppSpacing.md),
              photo,
            ],
          );
        },
      ),
    );
  }
}

class _WordPanel extends StatelessWidget {
  const _WordPanel({
    required this.result,
    required this.targetLanguage,
    required this.onPlay,
  });

  final AnalyzeResult result;
  final String targetLanguage;
  final ValueChanged<String> onPlay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '识别到了这个词',
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            result.sourceWord,
            maxLines: 1,
            style: textTheme.displaySmall?.copyWith(
              color: AppColors.photoInk,
              fontSize: 50,
              fontWeight: FontWeight.w900,
              height: 0.96,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          result.translationFor(targetLanguage),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            PronunciationButton(
              accent: PronunciationAccent.us,
              phonetic: result.phonetics.us,
              onPressed: () => onPlay(result.audioLinks.us),
            ),
            PronunciationButton(
              accent: PronunciationAccent.uk,
              phonetic: result.phonetics.uk,
              onPressed: () => onPlay(result.audioLinks.uk),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultPhoto extends StatelessWidget {
  const _ResultPhoto({
    required this.imageUrl,
    required this.localImagePath,
    required this.isNarrow,
  });

  final String imageUrl;
  final String? localImagePath;
  final bool isNarrow;

  @override
  Widget build(BuildContext context) {
    final photo = _ResultImage(
      imageUrl: imageUrl,
      localImagePath: localImagePath,
    );

    if (isNarrow) {
      return ClipRRect(
        borderRadius: AppRadius.medium,
        child: AspectRatio(aspectRatio: 16 / 9, child: photo),
      );
    }

    return SizedBox(
      width: 104,
      child: ClipRRect(
        borderRadius: AppRadius.medium,
        child: AspectRatio(aspectRatio: 4 / 5, child: photo),
      ),
    );
  }
}

class _ResultImage extends StatelessWidget {
  const _ResultImage({required this.imageUrl, required this.localImagePath});

  final String imageUrl;
  final String? localImagePath;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && localImagePath != null && localImagePath!.isNotEmpty) {
      return Image.file(
        File(localImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const _ImageFallback(),
      );
    }

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const _ImageFallback(),
      );
    }

    return const _ImageFallback();
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.photoFallback,
      child: Center(
        child: Icon(Icons.photo_camera_outlined, color: Colors.white70),
      ),
    );
  }
}

class _PracticeIntro extends StatelessWidget {
  const _PracticeIntro({required this.onStartPractice});

  final VoidCallback onStartPractice;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('跟读练习', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '选一句听一遍，再读出来。系统会给你一个鼓励式评分。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppButton.tonal(
          label: '开始',
          icon: Icons.mic_none_rounded,
          onPressed: onStartPractice,
        ),
      ],
    );
  }
}

class _SentencePracticeCard extends ConsumerStatefulWidget {
  const _SentencePracticeCard({required this.number, required this.sentence});

  final int number;
  final LearningSentence sentence;

  @override
  ConsumerState<_SentencePracticeCard> createState() =>
      _SentencePracticeCardState();
}

class _SentencePracticeCardState extends ConsumerState<_SentencePracticeCard> {
  _PracticeStatus _status = _PracticeStatus.idle;
  ShadowingEvaluation? _evaluation;
  String? _errorMessage;

  bool get _isRecording => _status == _PracticeStatus.recording;
  bool get _isScoring => _status == _PracticeStatus.scoring;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sentence = widget.sentence;

    return AppCard(
      padding: AppSpacing.compactCard,
      shadows: AppShadows.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SentenceNumberBadge(number: widget.number),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sentence.english,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.photoInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      sentence.translation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isRecording || _isScoring) ...[
            const SizedBox(height: AppSpacing.sm),
            _PracticeStatusBanner(status: _status),
          ],
          if (_evaluation != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _ScoreResult(evaluation: _evaluation!),
          ],
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton.tonal(
                  label: '听句子',
                  icon: Icons.volume_up_rounded,
                  onPressed: _isScoring ? null : _playSentence,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton.outline(
                  label: _practiceButtonLabel,
                  icon: _practiceButtonIcon,
                  isLoading: _isScoring,
                  onPressed: _isScoring ? null : _togglePractice,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _practiceButtonLabel {
    return switch (_status) {
      _PracticeStatus.recording => '结束录音',
      _PracticeStatus.scoring => '评分中',
      _PracticeStatus.idle || _PracticeStatus.scored => '读一遍',
    };
  }

  IconData get _practiceButtonIcon {
    return switch (_status) {
      _PracticeStatus.recording => Icons.stop_rounded,
      _PracticeStatus.scoring => Icons.graphic_eq_rounded,
      _PracticeStatus.idle || _PracticeStatus.scored => Icons.mic_none_rounded,
    };
  }

  Future<void> _playSentence() async {
    if (widget.sentence.audioUrl.trim().isEmpty) {
      _showSnack('句子音频还在生成，先试试跟读练习吧。');
      return;
    }

    try {
      await ref
          .read(audioPlaybackServiceProvider)
          .playUrl(widget.sentence.audioUrl);
    } catch (error) {
      _showSnack('句子音频暂不可用：$error');
    }
  }

  Future<void> _togglePractice() async {
    if (_isRecording) {
      await _stopAndScore();
      return;
    }
    await _startRecording();
  }

  Future<void> _startRecording() async {
    try {
      await ref.read(shadowingServiceProvider).startRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _PracticeStatus.recording;
        _evaluation = null;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _PracticeStatus.idle;
        _errorMessage = '录音启动失败，请检查麦克风权限。';
      });
    }
  }

  Future<void> _stopAndScore() async {
    try {
      final audioPath = await ref
          .read(shadowingServiceProvider)
          .stopRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _PracticeStatus.scoring;
        _errorMessage = null;
      });

      if (audioPath == null) {
        setState(() => _status = _PracticeStatus.idle);
        return;
      }

      final evaluation = await ref
          .read(shadowingServiceProvider)
          .evaluateShadowing(
            audioPath: audioPath,
            referenceText: widget.sentence.english,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _PracticeStatus.scored;
        _evaluation = evaluation;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _PracticeStatus.idle;
        _errorMessage = '评分没有完成，再试一次就好。';
      });
    }
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SentenceNumberBadge extends StatelessWidget {
  const _SentenceNumberBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: AppRadius.pill,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          '$number',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _PracticeStatusBanner extends StatelessWidget {
  const _PracticeStatusBanner({required this.status});

  final _PracticeStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRecording = status == _PracticeStatus.recording;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: AppSpacing.compactCard,
      decoration: BoxDecoration(
        color: isRecording
            ? colorScheme.errorContainer
            : colorScheme.secondaryContainer,
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        children: [
          Icon(
            isRecording ? Icons.mic_rounded : Icons.auto_awesome_rounded,
            color: isRecording
                ? colorScheme.onErrorContainer
                : colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isRecording ? '正在录音，读完后点“结束录音”。' : '正在听你的发音，马上给出建议。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isRecording
                    ? colorScheme.onErrorContainer
                    : colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreResult extends StatelessWidget {
  const _ScoreResult({required this.evaluation});

  final ShadowingEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.successContainer,
        borderRadius: AppRadius.medium,
      ),
      child: Padding(
        padding: AppSpacing.compactCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScoreBadge(score: evaluation.score),
            const SizedBox(height: AppSpacing.xs),
            Text(
              evaluation.feedback,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultActions extends StatelessWidget {
  const _ResultActions({
    required this.onGenerateShareCard,
    required this.onSaveToWordbook,
    required this.onTakeAnotherPhoto,
  });

  final VoidCallback onGenerateShareCard;
  final VoidCallback onSaveToWordbook;
  final VoidCallback onTakeAnotherPhoto;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton.primary(
            label: '生成分享卡',
            icon: Icons.ios_share_rounded,
            onPressed: onGenerateShareCard,
            expand: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton.tonal(
                  label: '存入生词本',
                  icon: Icons.bookmark_add_outlined,
                  onPressed: onSaveToWordbook,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton.outline(
                  label: '再拍一张',
                  icon: Icons.photo_camera_rounded,
                  onPressed: onTakeAnotherPhoto,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _PracticeStatus { idle, recording, scoring, scored }
