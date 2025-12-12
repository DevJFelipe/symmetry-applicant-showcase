import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// Premium Dark Theme for the News App
/// Editorial design with immersive dark mode
class AppTheme {
  AppTheme._();

  /// Dark theme - Primary theme for the app
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ========================================
      // COLOR SCHEME
      // ========================================
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primarySoft,
        onPrimaryContainer: AppColors.primaryLight,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.textOnPrimary,
        secondaryContainer: AppColors.primarySoft,
        onSecondaryContainer: AppColors.primaryLight,
        tertiary: AppColors.info,
        onTertiary: AppColors.textOnPrimary,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
        errorContainer: AppColors.errorSoft,
        onErrorContainer: AppColors.errorLight,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.borderStrong,
        shadow: Colors.black,
        scrim: AppColors.scrim,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.background,
        inversePrimary: AppColors.primaryDark,
      ),

      // ========================================
      // SCAFFOLD
      // ========================================
      scaffoldBackgroundColor: AppColors.background,

      // ========================================
      // TYPOGRAPHY
      // ========================================
      textTheme: AppTypography.textTheme,
      fontFamily: AppTypography.sansFamily,

      // ========================================
      // APP BAR
      // ========================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // ========================================
      // CARD
      // ========================================
      cardTheme: CardTheme(
        color: AppColors.surface,
        shadowColor: Colors.black26,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: const BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ========================================
      // ELEVATED BUTTON
      // ========================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.surfaceVariant,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // ========================================
      // TEXT BUTTON
      // ========================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ========================================
      // OUTLINED BUTTON
      // ========================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.button.copyWith(color: AppColors.primary),
        ),
      ),

      // ========================================
      // ICON BUTTON
      // ========================================
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          hoverColor: AppColors.primary.withValues(alpha: 0.1),
          focusColor: AppColors.primary.withValues(alpha: 0.1),
          highlightColor: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),

      // ========================================
      // FLOATING ACTION BUTTON
      // ========================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.fab,
        ),
      ),

      // ========================================
      // INPUT DECORATION
      // ========================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hoverColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        labelStyle: AppTypography.labelMedium,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        errorStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.error,
        ),
        prefixIconColor: AppColors.textTertiary,
        suffixIconColor: AppColors.textTertiary,
      ),

      // ========================================
      // BOTTOM NAVIGATION BAR
      // ========================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),

      // ========================================
      // NAVIGATION BAR (Material 3)
      // ========================================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: AppSpacing.bottomNavHeight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(color: AppColors.primary);
          }
          return AppTypography.labelSmall
              .copyWith(color: AppColors.textTertiary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textTertiary, size: 24);
        }),
      ),

      // ========================================
      // BOTTOM SHEET
      // ========================================
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheet,
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.textTertiary,
        dragHandleSize: Size(40, 4),
      ),

      // ========================================
      // DIALOG
      // ========================================
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.modal,
        ),
        titleTextStyle: AppTypography.titleLarge,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // ========================================
      // SNACKBAR
      // ========================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: AppTypography.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ========================================
      // CHIP
      // ========================================
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primarySoft,
        disabledColor: AppColors.surfaceVariant,
        labelStyle: AppTypography.labelMedium,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chip,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // ========================================
      // DIVIDER
      // ========================================
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ========================================
      // PROGRESS INDICATOR
      // ========================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.surfaceVariant,
        linearTrackColor: AppColors.surfaceVariant,
      ),

      // ========================================
      // REFRESH INDICATOR
      // ========================================
      // refreshIndicatorTheme: const RefreshIndicatorThemeData(
      //   backgroundColor: AppColors.surface,
      //   color: AppColors.primary,
      // ),

      // ========================================
      // LIST TILE
      // ========================================
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primarySoft,
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),

      // ========================================
      // SWITCH
      // ========================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySoft;
          }
          return AppColors.surfaceVariant;
        }),
      ),

      // ========================================
      // TAB BAR
      // ========================================
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: AppTypography.labelLarge,
        unselectedLabelStyle: AppTypography.labelMedium,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),

      // ========================================
      // TOOLTIP
      // ========================================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.borderSm,
        ),
        textStyle: AppTypography.labelSmall,
      ),

      // ========================================
      // SCROLLBAR
      // ========================================
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.textTertiary),
        trackColor: WidgetStateProperty.all(AppColors.surfaceVariant),
        radius: const Radius.circular(AppRadius.full),
        thickness: WidgetStateProperty.all(4),
      ),

      // ========================================
      // MISC
      // ========================================
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      highlightColor: AppColors.primary.withValues(alpha: 0.05),
      hoverColor: AppColors.primary.withValues(alpha: 0.04),
      focusColor: AppColors.primary.withValues(alpha: 0.12),
    );
  }

  /// Light theme - Alternative clean theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ========================================
      // COLOR SCHEME
      // ========================================
      colorScheme: const ColorScheme.light(
        primary: AppColorsLight.primary,
        onPrimary: AppColorsLight.textOnPrimary,
        primaryContainer: AppColorsLight.primarySoft,
        onPrimaryContainer: AppColorsLight.primaryDark,
        secondary: AppColorsLight.primaryLight,
        onSecondary: AppColorsLight.textOnPrimary,
        secondaryContainer: AppColorsLight.primarySoft,
        onSecondaryContainer: AppColorsLight.primaryDark,
        tertiary: AppColorsLight.info,
        onTertiary: AppColorsLight.textOnPrimary,
        error: AppColorsLight.error,
        onError: AppColorsLight.textOnPrimary,
        errorContainer: AppColorsLight.errorSoft,
        onErrorContainer: AppColorsLight.error,
        surface: AppColorsLight.surface,
        onSurface: AppColorsLight.textPrimary,
        surfaceContainerHighest: AppColorsLight.surfaceVariant,
        onSurfaceVariant: AppColorsLight.textSecondary,
        outline: AppColorsLight.border,
        outlineVariant: AppColorsLight.borderStrong,
        shadow: Colors.black,
        scrim: AppColorsLight.scrim,
        inverseSurface: AppColorsLight.textPrimary,
        onInverseSurface: AppColorsLight.background,
        inversePrimary: AppColorsLight.primaryLight,
      ),

      // ========================================
      // SCAFFOLD
      // ========================================
      scaffoldBackgroundColor: AppColorsLight.background,

      // ========================================
      // TYPOGRAPHY
      // ========================================
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColorsLight.textPrimary,
        displayColor: AppColorsLight.textPrimary,
      ),
      fontFamily: AppTypography.sansFamily,

      // ========================================
      // APP BAR
      // ========================================
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsLight.background,
        foregroundColor: AppColorsLight.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColorsLight.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColorsLight.textPrimary,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColorsLight.textSecondary,
          size: 24,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColorsLight.background,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      // ========================================
      // CARD
      // ========================================
      cardTheme: CardTheme(
        color: AppColorsLight.surface,
        shadowColor: AppColorsLight.shadowLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: const BorderSide(
            color: AppColorsLight.border,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ========================================
      // ELEVATED BUTTON
      // ========================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsLight.primary,
          foregroundColor: AppColorsLight.textOnPrimary,
          disabledBackgroundColor: AppColorsLight.surfaceVariant,
          disabledForegroundColor: AppColorsLight.textDisabled,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // ========================================
      // TEXT BUTTON
      // ========================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsLight.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ========================================
      // OUTLINED BUTTON
      // ========================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsLight.primary,
          side: const BorderSide(color: AppColorsLight.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle:
              AppTypography.button.copyWith(color: AppColorsLight.primary),
        ),
      ),

      // ========================================
      // ICON BUTTON
      // ========================================
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColorsLight.textSecondary,
          hoverColor: AppColorsLight.primary.withValues(alpha: 0.1),
          focusColor: AppColorsLight.primary.withValues(alpha: 0.1),
          highlightColor: AppColorsLight.primary.withValues(alpha: 0.15),
        ),
      ),

      // ========================================
      // FLOATING ACTION BUTTON
      // ========================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColorsLight.primary,
        foregroundColor: AppColorsLight.textOnPrimary,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.fab,
        ),
      ),

      // ========================================
      // INPUT DECORATION
      // ========================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.surface,
        hoverColor: AppColorsLight.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColorsLight.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColorsLight.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColorsLight.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColorsLight.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColorsLight.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColorsLight.border),
        ),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColorsLight.textSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColorsLight.textTertiary,
        ),
        errorStyle: AppTypography.labelSmall.copyWith(
          color: AppColorsLight.error,
        ),
        prefixIconColor: AppColorsLight.textTertiary,
        suffixIconColor: AppColorsLight.textTertiary,
      ),

      // ========================================
      // BOTTOM NAVIGATION BAR
      // ========================================
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColorsLight.surface,
        selectedItemColor: AppColorsLight.primary,
        unselectedItemColor: AppColorsLight.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),

      // ========================================
      // NAVIGATION BAR (Material 3)
      // ========================================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColorsLight.surface,
        indicatorColor: AppColorsLight.primarySoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: AppSpacing.bottomNavHeight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall
                .copyWith(color: AppColorsLight.primary);
          }
          return AppTypography.labelSmall
              .copyWith(color: AppColorsLight.textTertiary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColorsLight.primary, size: 24);
          }
          return const IconThemeData(
              color: AppColorsLight.textTertiary, size: 24);
        }),
      ),

      // ========================================
      // BOTTOM SHEET
      // ========================================
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColorsLight.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheet,
        ),
        showDragHandle: true,
        dragHandleColor: AppColorsLight.textTertiary,
        dragHandleSize: Size(40, 4),
      ),

      // ========================================
      // DIALOG
      // ========================================
      dialogTheme: DialogTheme(
        backgroundColor: AppColorsLight.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.modal,
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColorsLight.textPrimary,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColorsLight.textSecondary,
        ),
      ),

      // ========================================
      // SNACKBAR
      // ========================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorsLight.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColorsLight.surface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMd,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ========================================
      // CHIP
      // ========================================
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsLight.surface,
        selectedColor: AppColorsLight.primarySoft,
        disabledColor: AppColorsLight.surfaceVariant,
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColorsLight.textPrimary,
        ),
        side: const BorderSide(color: AppColorsLight.border),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chip,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),

      // ========================================
      // DIVIDER
      // ========================================
      dividerTheme: const DividerThemeData(
        color: AppColorsLight.divider,
        thickness: 1,
        space: 1,
      ),

      // ========================================
      // PROGRESS INDICATOR
      // ========================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColorsLight.primary,
        circularTrackColor: AppColorsLight.surfaceVariant,
        linearTrackColor: AppColorsLight.surfaceVariant,
      ),

      // ========================================
      // LIST TILE
      // ========================================
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColorsLight.primarySoft,
        iconColor: AppColorsLight.textSecondary,
        textColor: AppColorsLight.textPrimary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),

      // ========================================
      // SWITCH
      // ========================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsLight.primary;
          }
          return AppColorsLight.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorsLight.primarySoft;
          }
          return AppColorsLight.surfaceVariant;
        }),
      ),

      // ========================================
      // TAB BAR
      // ========================================
      tabBarTheme: TabBarTheme(
        labelColor: AppColorsLight.primary,
        unselectedLabelColor: AppColorsLight.textTertiary,
        labelStyle: AppTypography.labelLarge,
        unselectedLabelStyle: AppTypography.labelMedium,
        indicatorColor: AppColorsLight.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),

      // ========================================
      // TOOLTIP
      // ========================================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColorsLight.textPrimary,
          borderRadius: AppRadius.borderSm,
        ),
        textStyle: AppTypography.labelSmall.copyWith(
          color: AppColorsLight.surface,
        ),
      ),

      // ========================================
      // SCROLLBAR
      // ========================================
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColorsLight.textTertiary),
        trackColor: WidgetStateProperty.all(AppColorsLight.surfaceVariant),
        radius: const Radius.circular(AppRadius.full),
        thickness: WidgetStateProperty.all(4),
      ),

      // ========================================
      // MISC
      // ========================================
      splashColor: AppColorsLight.primary.withValues(alpha: 0.1),
      highlightColor: AppColorsLight.primary.withValues(alpha: 0.05),
      hoverColor: AppColorsLight.primary.withValues(alpha: 0.04),
      focusColor: AppColorsLight.primary.withValues(alpha: 0.12),
    );
  }
}
