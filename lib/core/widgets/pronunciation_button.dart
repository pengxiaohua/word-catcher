import 'package:flutter/material.dart';

import 'audio_play_button.dart';

enum PronunciationAccent {
  uk('UK', '播放英音'),
  us('US', '播放美音');

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

    return AudioPlayButton(
      label: label,
      tooltip: accent.tooltip,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }
}
