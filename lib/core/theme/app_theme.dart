import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.seed,
          secondary: AppColors.secondarySeed,
          tertiary: AppColors.tertiarySeed,
          surface: AppColors.paper,
        ).copyWith(
          primary: AppColors.seed,
          onPrimary: AppColors.paper,
          primaryContainer: AppColors.macaronMintSoft,
          onPrimaryContainer: AppColors.ink,
          secondary: AppColors.macaronPink,
          onSecondary: AppColors.photoInk,
          secondaryContainer: AppColors.macaronPinkSoft,
          onSecondaryContainer: AppColors.ink,
          tertiary: AppColors.macaronButter,
          onTertiary: AppColors.ink,
          tertiaryContainer: AppColors.macaronButterSoft,
          onTertiaryContainer: AppColors.ink,
          error: AppColors.error,
          onError: AppColors.paper,
          errorContainer: AppColors.errorContainer,
          onErrorContainer: AppColors.error,
          surface: AppColors.paper,
          onSurface: AppColors.ink,
          onSurfaceVariant: AppColors.mutedInk,
          surfaceContainerLowest: AppColors.paper,
          surfaceContainerLow: AppColors.macaronCream,
          surfaceContainer: AppColors.macaronSkySoft,
          surfaceContainerHigh: AppColors.macaronLavenderSoft,
          surfaceContainerHighest: AppColors.macaronMintSoft,
          outline: AppColors.macaronBorder,
          outlineVariant: AppColors.macaronBorder,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.pageBackground,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.pageBackground,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: const BorderSide(color: AppColors.macaronBorder),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: AppSpacing.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          textStyle: base.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: AppSpacing.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          foregroundColor: colorScheme.primary,
          side: const BorderSide(color: AppColors.macaronBorder),
          textStyle: base.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
          foregroundColor: colorScheme.primary,
          textStyle: base.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: AppColors.macaronSkySoft,
        circularTrackColor: AppColors.macaronSkySoft,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return AppColors.mutedInk;
        }),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: AppColors.paper,
        indicatorColor: AppColors.macaronButterSoft,
        surfaceTintColor: AppColors.paper,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return base.textTheme.labelMedium?.copyWith(
            color: selected ? colorScheme.primary : AppColors.mutedInk,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colorScheme.primary : AppColors.mutedInk,
            size: selected ? 28 : 25,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.photoInk,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
    );
  }
}
