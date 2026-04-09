import 'package:flutter/material.dart';

class AppTheme {
  // Tokens
  static const Color primary = Color(0xFF2563EB); // Blue 600
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF0F172A);
  static const Color card = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFF1F5F9);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color destructive = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color accent = Color(0xFF8B5CF6); // Violet

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: primaryForeground,
        secondary: accent,
        surface: background,
        onSurface: foreground,
        error: destructive,
        onError: primaryForeground,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: foreground, fontSize: 16),
        bodyMedium: TextStyle(color: foreground, fontSize: 14),
        bodySmall: TextStyle(color: mutedForeground, fontSize: 12),
        titleLarge: TextStyle(color: foreground, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryForeground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardTheme(
        color: card,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x0D000000), // Colors.black.withOpacity(0.05)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
      extensions: [
        CustomColors(
          success: success,
          muted: muted,
          mutedForeground: mutedForeground,
        ),
      ],
    );
  }
}

class CustomColors extends ThemeExtension<CustomColors> {
  final Color? success;
  final Color? muted;
  final Color? mutedForeground;

  const CustomColors({
    required this.success,
    required this.muted,
    required this.mutedForeground,
  });

  @override
  CustomColors copyWith({
    Color? success,
    Color? muted,
    Color? mutedForeground,
  }) {
    return CustomColors(
      success: success ?? this.success,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      success: Color.lerp(success, other.success, t),
      muted: Color.lerp(muted, other.muted, t),
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t),
    );
  }
}
