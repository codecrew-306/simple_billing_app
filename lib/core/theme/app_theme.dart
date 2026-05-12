import 'package:flutter/material.dart';

class AppTheme {
  // ─── Core Palette ────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A1A2E); // Deep dark navy
  static const Color primaryForeground = Color(0xFFFFFFFF);

  /// Warm cream background (matches the mockup's off-white page colour)
  static const Color background = Color(0xFFF5F0E8);

  static const Color foreground = Color(0xFF1A1A1A);
  static const Color card = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFF0EBE0);
  static const Color mutedForeground = Color(0xFF8A8070);
  static const Color border = Color(0xFFE0D8CC);
  static const Color destructive = Color(0xFFD94040);
  static const Color success = Color(0xFF2E8B57);

  /// Golden amber accent — used for selected nav items, highlights, chart bars
  static const Color accent = Color(0xFFC9960C);

  /// Lighter tint of accent for backgrounds / chips
  static const Color accentLight = Color(0xFFFDF3D0);

  // ─── Theme ───────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: primaryForeground,
        secondary: accent,
        onSecondary: primaryForeground,
        surface: card,
        onSurface: foreground,
        error: destructive,
        onError: primaryForeground,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: foreground, fontSize: 16),
        bodyMedium: TextStyle(color: foreground, fontSize: 14),
        bodySmall: TextStyle(color: mutedForeground, fontSize: 12),
        titleLarge: TextStyle(
          color: foreground,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: foreground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryForeground,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accent, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      dividerColor: border,
      extensions: [
        CustomColors(
          success: success,
          muted: muted,
          mutedForeground: mutedForeground,
          accentLight: accentLight,
        ),
      ],
    );
  }
}

// ─── Theme Extension ─────────────────────────────────────────────────────────
class CustomColors extends ThemeExtension<CustomColors> {
  final Color? success;
  final Color? muted;
  final Color? mutedForeground;
  final Color? accentLight;

  const CustomColors({
    required this.success,
    required this.muted,
    required this.mutedForeground,
    required this.accentLight,
  });

  @override
  CustomColors copyWith({
    Color? success,
    Color? muted,
    Color? mutedForeground,
    Color? accentLight,
  }) {
    return CustomColors(
      success: success ?? this.success,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      accentLight: accentLight ?? this.accentLight,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      success: Color.lerp(success, other.success, t),
      muted: Color.lerp(muted, other.muted, t),
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t),
      accentLight: Color.lerp(accentLight, other.accentLight, t),
    );
  }
}
