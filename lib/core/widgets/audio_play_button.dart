import 'package:flutter/material.dart';

import 'app_button.dart';

class AudioPlayButton extends StatelessWidget {
  const AudioPlayButton({
    required this.label,
    required this.onPressed,
    this.tooltip,
    this.isLoading = false,
    this.compact = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool isLoading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Tooltip(
        message: tooltip ?? label,
        child: IconButton.filledTonal(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.volume_up_rounded),
        ),
      );
    }

    return AppButton.tonal(
      label: label,
      icon: Icons.volume_up_rounded,
      onPressed: onPressed,
      isLoading: isLoading,
      tooltip: tooltip,
    );
  }
}
