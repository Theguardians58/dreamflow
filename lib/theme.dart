import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuraColors {
  static const dustyRose = Color(0xFFD8A7B1);
  static const offWhite = Color(0xFFFDFDFD);
  static const gold = Color(0xFFBFA181);
  static const charcoal = Color(0xFF343434);
  static const lightGrey = Color(0xFFF5F5F5);
  static const mediumGrey = Color(0xFFAAAAAA);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE57373);
}


class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 24.0;
  static const double headlineSmall = 22.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 18.0;
  static const double titleSmall = 16.0;
  static const double labelLarge = 16.0;
  static const double labelMedium = 14.0;
  static const double labelSmall = 12.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AuraColors.dustyRose,
    onPrimary: AuraColors.offWhite,
    secondary: AuraColors.gold,
    onSecondary: AuraColors.offWhite,
    surface: AuraColors.offWhite,
    onSurface: AuraColors.charcoal,
    error: AuraColors.error,
  ),
  scaffoldBackgroundColor: AuraColors.offWhite,
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: AuraColors.offWhite,
    foregroundColor: AuraColors.charcoal,
    elevation: 0,
    centerTitle: false,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(fontSize: FontSizes.displayLarge, fontWeight: FontWeight.bold, color: AuraColors.charcoal),
    displayMedium: GoogleFonts.playfairDisplay(fontSize: FontSizes.displayMedium, fontWeight: FontWeight.bold, color: AuraColors.charcoal),
    displaySmall: GoogleFonts.playfairDisplay(fontSize: FontSizes.displaySmall, fontWeight: FontWeight.w600, color: AuraColors.charcoal),
    headlineLarge: GoogleFonts.playfairDisplay(fontSize: FontSizes.headlineLarge, fontWeight: FontWeight.w600, color: AuraColors.charcoal),
    headlineMedium: GoogleFonts.playfairDisplay(fontSize: FontSizes.headlineMedium, fontWeight: FontWeight.w600, color: AuraColors.charcoal),
    headlineSmall: GoogleFonts.playfairDisplay(fontSize: FontSizes.headlineSmall, fontWeight: FontWeight.w600, color: AuraColors.charcoal),
    titleLarge: GoogleFonts.inter(fontSize: FontSizes.titleLarge, fontWeight: FontWeight.w500, color: AuraColors.charcoal),
    titleMedium: GoogleFonts.inter(fontSize: FontSizes.titleMedium, fontWeight: FontWeight.w500, color: AuraColors.charcoal),
    titleSmall: GoogleFonts.inter(fontSize: FontSizes.titleSmall, fontWeight: FontWeight.w500, color: AuraColors.charcoal),
    labelLarge: GoogleFonts.inter(fontSize: FontSizes.labelLarge, fontWeight: FontWeight.w500, color: AuraColors.charcoal),
    labelMedium: GoogleFonts.inter(fontSize: FontSizes.labelMedium, fontWeight: FontWeight.w500, color: AuraColors.charcoal),
    labelSmall: GoogleFonts.inter(fontSize: FontSizes.labelSmall, fontWeight: FontWeight.w500, color: AuraColors.charcoal),
    bodyLarge: GoogleFonts.inter(fontSize: FontSizes.bodyLarge, fontWeight: FontWeight.normal, color: AuraColors.charcoal),
    bodyMedium: GoogleFonts.inter(fontSize: FontSizes.bodyMedium, fontWeight: FontWeight.normal, color: AuraColors.charcoal),
    bodySmall: GoogleFonts.inter(fontSize: FontSizes.bodySmall, fontWeight: FontWeight.normal, color: AuraColors.mediumGrey),
  ),
);

ThemeData get darkTheme => lightTheme;
