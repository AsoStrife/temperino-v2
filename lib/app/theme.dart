import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/profile/domain/partner_profile.dart';

/// Brand palette (pink/red + sky blue, chosen by the owner on 2026-11-12;
/// replaces the blue/orange of the spec). Fills (charts, dots, bars) use
/// these values; colored text uses the darker "ink" variants of [AppColors]
/// for AA contrast.
abstract final class AppPalette {
  static const partnerA = Color(0xFF38B6F2); // celeste
  static const partnerB = Color(0xFFF0569B); // rosa
  static const accent = Color(0xFFE5304D); // rosso lampone, seed del tema
  static const positive = Color(0xFF2EB67D); // verde
  static const warning = Color(0xFFF2C94C); // ambra
  static const neutral = Color(0xFF8E8E93); // grigio
}

/// Corner radii of the design system.
abstract final class AppRadii {
  static const tile = 24.0;
  static const inner = 16.0;
  static const small = 12.0;
}

/// Semantic colors exposed through `context.appColors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.partnerA,
    required this.partnerB,
    required this.partnerAInk,
    required this.partnerBInk,
    required this.accent,
    required this.accentInk,
    required this.onAccent,
    required this.heroStart,
    required this.heroEnd,
    required this.positive,
    required this.warning,
    required this.neutral,
    required this.muted,
    required this.tile,
    required this.tileHigh,
    required this.hairline,
  });

  static const light = AppColors(
    partnerA: AppPalette.partnerA,
    partnerB: AppPalette.partnerB,
    partnerAInk: Color(0xFF0A72B0),
    partnerBInk: Color(0xFFC2185B),
    accent: AppPalette.accent,
    accentInk: Color(0xFFD21E45),
    onAccent: Colors.white,
    heroStart: Color(0xFFE5304D),
    heroEnd: Color(0xFFF0569B),
    positive: AppPalette.positive,
    warning: AppPalette.warning,
    neutral: AppPalette.neutral,
    muted: Color(0xFF6B6B76),
    tile: Colors.white,
    tileHigh: Color(0xFFF1F1F4),
    hairline: Color(0xFFE6E6EC),
  );

  static const dark = AppColors(
    partnerA: Color(0xFF5CC6F7),
    partnerB: Color(0xFFFF6FAE),
    partnerAInk: Color(0xFF7CCBF7),
    partnerBInk: Color(0xFFFF8CC1),
    accent: Color(0xFFFF4D6A),
    accentInk: Color(0xFFFF6B85),
    onAccent: Color(0xFF16161A),
    heroStart: Color(0xFFD9294A),
    heroEnd: Color(0xFFE8508F),
    positive: Color(0xFF4FD19A),
    warning: AppPalette.warning,
    neutral: Color(0xFFA1A1A6),
    muted: Color(0xFF9A9AA5),
    tile: Color(0xFF161619),
    tileHigh: Color(0xFF212126),
    hairline: Color(0xFF2A2A31),
  );

  final Color partnerA;
  final Color partnerB;
  final Color partnerAInk;
  final Color partnerBInk;
  final Color accent;
  final Color accentInk;
  final Color onAccent;
  final Color heroStart;
  final Color heroEnd;
  final Color positive;
  final Color warning;
  final Color neutral;
  final Color muted;
  final Color tile;
  final Color tileHigh;
  final Color hairline;

  /// Fill color of a partner (charts, dots, rings).
  Color partner(Partner p) => p == Partner.a ? partnerA : partnerB;

  /// Text color of a partner (AA on tiles).
  Color partnerInk(Partner p) => p == Partner.a ? partnerAInk : partnerBInk;

  /// Tonal background of a partner.
  Color partnerSoft(Partner p) => partner(p).withValues(alpha: 0.14);

  Color get accentSoft => accent.withValues(alpha: 0.14);

  LinearGradient get heroGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [heroStart, heroEnd],
  );

  @override
  AppColors copyWith({
    Color? partnerA,
    Color? partnerB,
    Color? partnerAInk,
    Color? partnerBInk,
    Color? accent,
    Color? accentInk,
    Color? onAccent,
    Color? heroStart,
    Color? heroEnd,
    Color? positive,
    Color? warning,
    Color? neutral,
    Color? muted,
    Color? tile,
    Color? tileHigh,
    Color? hairline,
  }) => AppColors(
    partnerA: partnerA ?? this.partnerA,
    partnerB: partnerB ?? this.partnerB,
    partnerAInk: partnerAInk ?? this.partnerAInk,
    partnerBInk: partnerBInk ?? this.partnerBInk,
    accent: accent ?? this.accent,
    accentInk: accentInk ?? this.accentInk,
    onAccent: onAccent ?? this.onAccent,
    heroStart: heroStart ?? this.heroStart,
    heroEnd: heroEnd ?? this.heroEnd,
    positive: positive ?? this.positive,
    warning: warning ?? this.warning,
    neutral: neutral ?? this.neutral,
    muted: muted ?? this.muted,
    tile: tile ?? this.tile,
    tileHigh: tileHigh ?? this.tileHigh,
    hairline: hairline ?? this.hairline,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      partnerA: l(partnerA, other.partnerA),
      partnerB: l(partnerB, other.partnerB),
      partnerAInk: l(partnerAInk, other.partnerAInk),
      partnerBInk: l(partnerBInk, other.partnerBInk),
      accent: l(accent, other.accent),
      accentInk: l(accentInk, other.accentInk),
      onAccent: l(onAccent, other.onAccent),
      heroStart: l(heroStart, other.heroStart),
      heroEnd: l(heroEnd, other.heroEnd),
      positive: l(positive, other.positive),
      warning: l(warning, other.warning),
      neutral: l(neutral, other.neutral),
      muted: l(muted, other.muted),
      tile: l(tile, other.tile),
      tileHigh: l(tileHigh, other.tileHigh),
      hairline: l(hairline, other.hairline),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;

  /// Respect the system "reduce motion" setting.
  Duration motion(Duration normal) =>
      MediaQuery.of(this).disableAnimations ? Duration.zero : normal;
}

/// Tabular figures for numbers that change (counters, stats).
const tabularFigures = [FontFeature.tabularFigures()];

/// System bar style for the given brightness: transparent bars (edge-to-edge),
/// dark icons on light theme and light icons on dark theme.
SystemUiOverlayStyle systemOverlayFor(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    statusBarBrightness: brightness,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: dark
        ? Brightness.light
        : Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ColorScheme _scheme(Brightness b, AppColors c) {
    final dark = b == Brightness.dark;
    // fromSeed gives harmonious error/tertiary roles; surfaces and primary
    // are replaced with neutral, high-contrast values.
    return ColorScheme.fromSeed(
      seedColor: AppPalette.accent,
      brightness: b,
    ).copyWith(
      primary: c.accentInk,
      onPrimary: c.onAccent,
      primaryContainer: dark
          ? const Color(0xFF3F1520)
          : const Color(0xFFFFE2E8),
      onPrimaryContainer: dark
          ? const Color(0xFFFFD0DA)
          : const Color(0xFF8A1030),
      secondary: dark ? const Color(0xFFE6E6EB) : const Color(0xFF2B2B33),
      onSecondary: dark ? const Color(0xFF16161A) : Colors.white,
      secondaryContainer: c.tileHigh,
      onSecondaryContainer: dark
          ? const Color(0xFFF2F2F5)
          : const Color(0xFF121214),
      surface: dark ? const Color(0xFF0B0B0D) : const Color(0xFFF4F4F6),
      onSurface: dark ? const Color(0xFFF2F2F5) : const Color(0xFF121214),
      onSurfaceVariant: c.muted,
      surfaceContainerLowest: c.tile,
      surfaceContainerLow: dark
          ? const Color(0xFF131316)
          : const Color(0xFFFAFAFB),
      surfaceContainer: dark
          ? const Color(0xFF1B1B1F)
          : const Color(0xFFEFEFF2),
      surfaceContainerHigh: c.tileHigh,
      surfaceContainerHighest: dark
          ? const Color(0xFF2A2A31)
          : const Color(0xFFE4E4EA),
      outline: dark ? const Color(0xFF4A4A54) : const Color(0xFFC9C9D1),
      outlineVariant: c.hairline,
      inverseSurface: dark ? const Color(0xFFF2F2F5) : const Color(0xFF1C1C21),
      onInverseSurface: dark
          ? const Color(0xFF16161A)
          : const Color(0xFFF2F2F5),
      surfaceTint: Colors.transparent,
    );
  }

  static TextTheme _text(TextTheme t) {
    TextStyle? tight(TextStyle? s, FontWeight w, double spacing) =>
        s?.copyWith(fontWeight: w, letterSpacing: spacing);
    return t.copyWith(
      displayLarge: tight(t.displayLarge, FontWeight.w800, -1.5),
      displayMedium: tight(t.displayMedium, FontWeight.w800, -1.2),
      displaySmall: tight(t.displaySmall, FontWeight.w800, -1),
      headlineLarge: tight(t.headlineLarge, FontWeight.w800, -0.8),
      headlineMedium: tight(t.headlineMedium, FontWeight.w700, -0.6),
      headlineSmall: tight(t.headlineSmall, FontWeight.w700, -0.4),
      titleLarge: tight(t.titleLarge, FontWeight.w700, -0.2),
      titleMedium: tight(t.titleMedium, FontWeight.w600, 0),
      titleSmall: tight(t.titleSmall, FontWeight.w600, 0),
      labelLarge: tight(t.labelLarge, FontWeight.w600, 0),
      labelMedium: tight(t.labelMedium, FontWeight.w600, 0.2),
      labelSmall: tight(t.labelSmall, FontWeight.w600, 0.3),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final colors = brightness == Brightness.dark
        ? AppColors.dark
        : AppColors.light;
    final scheme = _scheme(brightness, colors);
    const stadium = StadiumBorder();
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: scheme.surface,
      extensions: [colors],
    );
    final text = _text(base.textTheme);

    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemOverlayFor(brightness),
      ),
      cardTheme: CardThemeData(
        color: colors.tile,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.tile),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 56),
          shape: stadium,
          textStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: stadium,
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: text.titleSmall,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: stadium, textStyle: text.titleSmall),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      chipTheme: ChipThemeData(
        shape: stadium,
        side: BorderSide.none,
        backgroundColor: colors.tileHigh,
        selectedColor: scheme.primaryContainer,
        labelStyle: text.labelLarge?.copyWith(color: scheme.onSurface),
        secondaryLabelStyle: text.labelLarge?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: stadium,
          side: BorderSide(color: scheme.outlineVariant),
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          foregroundColor: scheme.onSurface,
          textStyle: text.labelLarge,
          minimumSize: const Size(48, 48),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHighest,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? scheme.onPrimary : colors.tile,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.inner),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.tile,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: text.headlineSmall?.copyWith(color: scheme.onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.tile,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(colors.tile),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.inner),
            ),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.tileHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.inner),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.inner),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.inner),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.hairline,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        },
      ),
    );
  }
}
