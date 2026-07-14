import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum PronunciationAccent {
  uk('英', '播放英音'),
  us('美', '播放美音');

  const PronunciationAccent(this.label, this.tooltip);

  final String label;
  final String tooltip;
}

class PronunciationButton extends StatelessWidget {
  const PronunciationButton({
    required this.accent,
    required this.onPressed,
    this.phonetic,
    this.isLoading = false,
    super.key,
  });

  final PronunciationAccent accent;
  final String? phonetic;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cleanPhonetic = phonetic?.trim();
    final label = cleanPhonetic == null || cleanPhonetic.isEmpty
        ? accent.label
        : '${accent.label} $cleanPhonetic';
    final colorScheme = Theme.of(context).colorScheme;
    final labelWidget = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final icon = isLoading
        ? SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.onSecondaryContainer,
            ),
          )
        : const Icon(Icons.volume_up_rounded, size: 18);

    return Tooltip(
      message: accent.tooltip,
      child: FilledButton.tonalIcon(
        onPressed: isLoading ? null : onPressed,
        icon: icon,
        label: labelWidget,
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 40),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
