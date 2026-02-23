import 'package:flutter/material.dart';
import 'package:studio_pair/src/theme/app_colors.dart';
import 'package:studio_pair/src/theme/app_spacing.dart';
import 'package:studio_pair/src/theme/app_typography.dart';

/// Material 3 theme configuration for the Studio Pair application.
class AppTheme {
  AppTheme._();

  // ── Light Theme ──────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: Color(0xFFDDE1FF),
      onPrimaryContainer: Color(0xFF001452),
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: Color(0xFFA7F3EC),
      onSecondaryContainer: Color(0xFF00201D),
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: Color(0xFFFFDBCF),
      onTertiaryContainer: Color(0xFF3B0900),
      error: AppColors.error,
      errorContainer: AppColors.errorLight,
      onErrorContainer: Color(0xFF410002),
      surface: AppColors.surfaceLight,
      onSurface: AppColors.grey900,
      surfaceContainerHighest: AppColors.grey100,
      onSurfaceVariant: AppColors.grey700,
      outline: AppColors.grey400,
      outlineVariant: AppColors.grey200,
      shadow: Colors.black26,
    ),
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.grey900,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.grey900,
      ),
      iconTheme: IconThemeData(color: AppColors.grey800),
    ),
    cardTheme: CardThemeData(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      color: AppColors.surfaceLight,
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        side: const BorderSide(color: AppColors.primary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: AppColors.grey300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: AppColors.grey300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.grey600),
      hintStyle: const TextStyle(color: AppColors.grey400),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey500,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.grey100,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.grey200,
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXxl),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.grey500,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
    ),
    extensions: const [ModuleColors.light],
  );

  // ── Dark Theme ───────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFB9C3FF),
      onPrimary: Color(0xFF002482),
      primaryContainer: Color(0xFF0039B5),
      onPrimaryContainer: Color(0xFFDDE1FF),
      secondary: Color(0xFF80D8CF),
      onSecondary: Color(0xFF003733),
      secondaryContainer: Color(0xFF005049),
      onSecondaryContainer: Color(0xFFA7F3EC),
      tertiary: Color(0xFFFFB59C),
      onTertiary: Color(0xFF5F1600),
      tertiaryContainer: Color(0xFF862200),
      onTertiaryContainer: Color(0xFFFFDBCF),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: AppColors.surfaceDark,
      onSurface: Color(0xFFE6E1E5),
      surfaceContainerHighest: Color(0xFF2B2B2F),
      onSurfaceVariant: Color(0xFFC9C5CA),
      outline: Color(0xFF938F94),
      outlineVariant: Color(0xFF49454F),
      shadow: Colors.black54,
    ),
    textTheme: AppTypography.textTheme.apply(
      bodyColor: const Color(0xFFE6E1E5),
      displayColor: const Color(0xFFE6E1E5),
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: Color(0xFFE6E1E5),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE6E1E5),
      ),
      iconTheme: IconThemeData(color: Color(0xFFE6E1E5)),
    ),
    cardTheme: CardThemeData(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFF2B2B2F),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        backgroundColor: const Color(0xFFB9C3FF),
        foregroundColor: const Color(0xFF002482),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        side: const BorderSide(color: Color(0xFFB9C3FF)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2B2B2F),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: Color(0xFF49454F)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: Color(0xFF49454F)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: Color(0xFFB9C3FF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFFC9C5CA)),
      hintStyle: const TextStyle(color: Color(0xFF938F94)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: Color(0xFFB9C3FF),
      unselectedItemColor: Color(0xFF938F94),
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: const Color(0xFFB9C3FF),
      foregroundColor: const Color(0xFF002482),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2B2B2F),
      selectedColor: const Color(0xFFB9C3FF).withValues(alpha: 0.15),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
      ),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF49454F),
      thickness: 1,
      space: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXxl),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Color(0xFFB9C3FF),
      unselectedLabelColor: Color(0xFF938F94),
      indicatorColor: Color(0xFFB9C3FF),
      indicatorSize: TabBarIndicatorSize.label,
    ),
    extensions: const [ModuleColors.dark],
  );
}

/// Theme extension to provide module-specific colors.
@immutable
class ModuleColors extends ThemeExtension<ModuleColors> {
  const ModuleColors({
    required this.dashboard,
    required this.activities,
    required this.calendar,
    required this.messaging,
    required this.tasks,
    required this.finances,
    required this.cards,
    required this.vault,
    required this.health,
    required this.reminders,
    required this.files,
    required this.memories,
    required this.charter,
    required this.grocery,
    required this.polls,
    required this.location,
  });

  final Color dashboard;
  final Color activities;
  final Color calendar;
  final Color messaging;
  final Color tasks;
  final Color finances;
  final Color cards;
  final Color vault;
  final Color health;
  final Color reminders;
  final Color files;
  final Color memories;
  final Color charter;
  final Color grocery;
  final Color polls;
  final Color location;

  static const ModuleColors light = ModuleColors(
    dashboard: AppColors.moduleDashboard,
    activities: AppColors.moduleActivities,
    calendar: AppColors.moduleCalendar,
    messaging: AppColors.moduleMessaging,
    tasks: AppColors.moduleTasks,
    finances: AppColors.moduleFinances,
    cards: AppColors.moduleCards,
    vault: AppColors.moduleVault,
    health: AppColors.moduleHealth,
    reminders: AppColors.moduleReminders,
    files: AppColors.moduleFiles,
    memories: AppColors.moduleMemories,
    charter: AppColors.moduleCharter,
    grocery: AppColors.moduleGrocery,
    polls: AppColors.modulePolls,
    location: AppColors.moduleLocation,
  );

  static const ModuleColors dark = ModuleColors(
    dashboard: Color(0xFF9FA8DA),
    activities: Color(0xFFCE93D8),
    calendar: Color(0xFF90CAF9),
    messaging: Color(0xFF80CBC4),
    tasks: Color(0xFFFFAB91),
    finances: Color(0xFFA5D6A7),
    cards: Color(0xFF9FA8DA),
    vault: Color(0xFFB0BEC5),
    health: Color(0xFFEF9A9A),
    reminders: Color(0xFFFFCC80),
    files: Color(0xFFBCAAA4),
    memories: Color(0xFFF48FB1),
    charter: Color(0xFFB39DDB),
    grocery: Color(0xFFC5E1A5),
    polls: Color(0xFF81D4FA),
    location: Color(0xFF80DEEA),
  );

  @override
  ModuleColors copyWith({
    Color? dashboard,
    Color? activities,
    Color? calendar,
    Color? messaging,
    Color? tasks,
    Color? finances,
    Color? cards,
    Color? vault,
    Color? health,
    Color? reminders,
    Color? files,
    Color? memories,
    Color? charter,
    Color? grocery,
    Color? polls,
    Color? location,
  }) {
    return ModuleColors(
      dashboard: dashboard ?? this.dashboard,
      activities: activities ?? this.activities,
      calendar: calendar ?? this.calendar,
      messaging: messaging ?? this.messaging,
      tasks: tasks ?? this.tasks,
      finances: finances ?? this.finances,
      cards: cards ?? this.cards,
      vault: vault ?? this.vault,
      health: health ?? this.health,
      reminders: reminders ?? this.reminders,
      files: files ?? this.files,
      memories: memories ?? this.memories,
      charter: charter ?? this.charter,
      grocery: grocery ?? this.grocery,
      polls: polls ?? this.polls,
      location: location ?? this.location,
    );
  }

  @override
  ModuleColors lerp(ThemeExtension<ModuleColors>? other, double t) {
    if (other is! ModuleColors) return this;
    return ModuleColors(
      dashboard: Color.lerp(dashboard, other.dashboard, t)!,
      activities: Color.lerp(activities, other.activities, t)!,
      calendar: Color.lerp(calendar, other.calendar, t)!,
      messaging: Color.lerp(messaging, other.messaging, t)!,
      tasks: Color.lerp(tasks, other.tasks, t)!,
      finances: Color.lerp(finances, other.finances, t)!,
      cards: Color.lerp(cards, other.cards, t)!,
      vault: Color.lerp(vault, other.vault, t)!,
      health: Color.lerp(health, other.health, t)!,
      reminders: Color.lerp(reminders, other.reminders, t)!,
      files: Color.lerp(files, other.files, t)!,
      memories: Color.lerp(memories, other.memories, t)!,
      charter: Color.lerp(charter, other.charter, t)!,
      grocery: Color.lerp(grocery, other.grocery, t)!,
      polls: Color.lerp(polls, other.polls, t)!,
      location: Color.lerp(location, other.location, t)!,
    );
  }
}
