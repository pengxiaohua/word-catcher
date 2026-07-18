import 'package:flutter/material.dart';

import 'app_spacing.dart';

class AppBottomNavigationLayout {
  const AppBottomNavigationLayout._();

  static const double height = 60;

  static double bottomOffset(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return bottomInset > AppSpacing.sm
        ? bottomInset - AppSpacing.sm
        : AppSpacing.xxs;
  }

  static EdgeInsets pageScrollPadding(BuildContext context) {
    return EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.md,
      AppSpacing.md,
      height + bottomOffset(context) + AppSpacing.md,
    );
  }
}
