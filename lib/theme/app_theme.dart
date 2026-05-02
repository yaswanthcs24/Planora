import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand colors ──────────────────────────────────────────
  static const Color primary      = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFFEDE9FF);
  static const Color primaryDark  = Color(0xFF4A42C8);
  static const Color accent       = Color(0xFFFF6584);
  static const Color success      = Color(0xFF43E97B);
  static const Color warning      = Color(0xFFF7971E);
  static const Color bgPage       = Color(0xFFF8F7FF);
  static const Color cardBg       = Color(0xFFFFFFFF);
  static const Color textDark     = Color(0xFF2D2A5E);
  static const Color textMuted    = Color(0xFF9E9BB8);
  static const Color borderColor  = Color(0xFFEDE9FF);

  // ── Subject colors ────────────────────────────────────────
  static const Color subjectMath    = Color(0xFF6C63FF);
  static const Color subjectPhysics = Color(0xFFFF6584);
  static const Color subjectChem    = Color(0xFFF7971E);
  static const Color subjectBio     = Color(0xFF43E97B);
  static const Color subjectEng     = Color(0xFF00C9FF);

  // ── Text styles ───────────────────────────────────────────
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textDark,
  );
  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textDark,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textDark,
  );
  static const TextStyle muted = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textMuted,
  );

  // ── ThemeData ─────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    // fontFamily: 'Poppins' — removed, add back after adding to pubspec.yaml
    scaffoldBackgroundColor: bgPage,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: cardBg,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgPage,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      iconTheme: IconThemeData(color: textDark),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderColor, width: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardBg,
      selectedItemColor: primary,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),
  );

  // ── Alias so nothing breaks if any file still says lightTheme ─
  static ThemeData get lightTheme => theme;
}