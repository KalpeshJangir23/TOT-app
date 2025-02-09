import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6D4C41); // Warm Brown
  static const Color secondaryColor = Color(0xFFFFAB91); // Soft Orange
  static const Color accentColor = Color(0xFF80CBC4); // Soft Teal
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color textPrimaryColor = Color(0xFF3E2723); // Dark Brown
  static const Color textSecondaryColor = Color(0xFF757575);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimaryColor,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: textPrimaryColor,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondaryColor,
            height: 1.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
