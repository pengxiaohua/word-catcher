import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum AppButtonVariant { primary, tonal, successTonal, outline, text }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.expand = false,
    this.tooltip,
    super.key,
  });

  const AppButton.primary({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.tooltip,
    super.key,
  }) : variant = AppButtonVariant.primary;

  const AppButton.tonal({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.tooltip,
    super.key,
  }) : variant = AppButtonVariant.tonal;

  const AppButton.successTonal({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.tooltip,
    super.key,
  }) : variant = AppButtonVariant.successTonal;

  const AppButton.outline({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.tooltip,
    super.key,
  }) : variant = AppButtonVariant.outline;

  const AppButton.text({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = false,
    this.tooltip,
    super.key,
  }) : variant = AppButtonVariant.text;

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool expand;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    Widget button = _buildButton(context);

    if (expand) {
      button = SizedBox(width: double.infinity, child: button);
    }

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }

  Widget _buildButton(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final leading = isLoading ? _spinner(context) : _icon();
    final labelWidget = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    return switch (variant) {
      AppButtonVariant.primary =>
        leading == null
            ? FilledButton(onPressed: effectiveOnPressed, child: labelWidget)
            : FilledButton.icon(
                onPressed: effectiveOnPressed,
                icon: leading,
                label: labelWidget,
              ),
      AppButtonVariant.tonal =>
        leading == null
            ? FilledButton.tonal(
                onPressed: effectiveOnPressed,
                child: labelWidget,
              )
            : FilledButton.tonalIcon(
                onPressed: effectiveOnPressed,
                icon: leading,
                label: labelWidget,
              ),
      AppButtonVariant.successTonal =>
        leading == null
            ? FilledButton.tonal(
                onPressed: effectiveOnPressed,
                style: _successTonalStyle(),
                child: labelWidget,
              )
            : FilledButton.tonalIcon(
                onPressed: effectiveOnPressed,
                style: _successTonalStyle(),
                icon: leading,
                label: labelWidget,
              ),
      AppButtonVariant.outline =>
        leading == null
            ? OutlinedButton(onPressed: effectiveOnPressed, child: labelWidget)
            : OutlinedButton.icon(
                onPressed: effectiveOnPressed,
                icon: leading,
                label: labelWidget,
              ),
      AppButtonVariant.text =>
        leading == null
            ? TextButton(onPressed: effectiveOnPressed, child: labelWidget)
            : TextButton.icon(
                onPressed: effectiveOnPressed,
                icon: leading,
                label: labelWidget,
              ),
    };
  }

  Widget? _icon() {
    final iconData = icon;
    if (iconData == null) {
      return null;
    }
    return Icon(iconData);
  }

  Widget _spinner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = switch (variant) {
      AppButtonVariant.primary => colorScheme.onPrimary,
      AppButtonVariant.tonal => colorScheme.onSecondaryContainer,
      AppButtonVariant.successTonal => AppColors.success,
      AppButtonVariant.outline || AppButtonVariant.text => colorScheme.primary,
    };

    return SizedBox.square(
      dimension: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }

  ButtonStyle _successTonalStyle() {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.successContainer,
      foregroundColor: AppColors.success,
      disabledBackgroundColor: AppColors.successContainer,
      disabledForegroundColor: AppColors.success,
    );
  }
}
