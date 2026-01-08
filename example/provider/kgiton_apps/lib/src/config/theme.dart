/// ============================================================================
/// KGiTON Theme Configuration
/// ============================================================================
/// 
/// File: src/config/theme.dart
/// Deskripsi: Konfigurasi tema aplikasi dengan branding KGiTON
/// 
/// Warna Utama KGiTON:
/// - Primary: Green (#2E7D32) - Merepresentasikan akurasi dan kepercayaan
/// - Secondary: Light Green (#66BB6A) - Aksen dan highlight
/// - Background: White/Dark Grey - Clean & professional look
/// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Konstanta warna KGiTON
class KGiTONColors {
  KGiTONColors._();
  
  // Primary Colors
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF66BB6A);
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color secondaryDark = Color(0xFF43A047);
  
  // Accent Colors
  static const Color accent = Color(0xFF00BCD4);
  static const Color accentLight = Color(0xFF4DD0E1);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Surface Colors
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // BLE Status Colors
  static const Color connected = Color(0xFF4CAF50);
  static const Color connecting = Color(0xFFFFC107);
  static const Color disconnected = Color(0xFF9E9E9E);
  static const Color scanning = Color(0xFF2196F3);
}

/// Konfigurasi tema aplikasi
class KGiTONTheme {
  KGiTONTheme._();
  
  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: KGiTONColors.primary,
        secondary: KGiTONColors.secondary,
        surface: KGiTONColors.surfaceLight,
        error: KGiTONColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: KGiTONColors.textPrimaryLight,
        onError: Colors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: KGiTONColors.backgroundLight,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: KGiTONColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: KGiTONColors.surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KGiTONColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KGiTONColors.primary,
          side: const BorderSide(color: KGiTONColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // TextField
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KGiTONColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KGiTONColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.poppins(
          color: KGiTONColors.textSecondaryLight,
        ),
      ),
      
      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: KGiTONColors.textPrimaryLight,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: KGiTONColors.textPrimaryLight,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: KGiTONColors.textPrimaryLight,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: KGiTONColors.textPrimaryLight,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: KGiTONColors.textPrimaryLight,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: KGiTONColors.textPrimaryLight,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: KGiTONColors.textSecondaryLight,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: KGiTONColors.primary,
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: KGiTONColors.primary,
        foregroundColor: Colors.white,
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KGiTONColors.surfaceLight,
        selectedItemColor: KGiTONColors.primary,
        unselectedItemColor: KGiTONColors.textSecondaryLight,
      ),
    );
  }
  
  /// Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: KGiTONColors.primaryLight,
        secondary: KGiTONColors.secondaryLight,
        surface: KGiTONColors.surfaceDark,
        error: KGiTONColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: KGiTONColors.textPrimaryDark,
        onError: Colors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: KGiTONColors.backgroundDark,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: KGiTONColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: KGiTONColors.surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KGiTONColors.primaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // TextField
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: KGiTONColors.primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // Text Theme
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KGiTONColors.surfaceDark,
        selectedItemColor: KGiTONColors.primaryLight,
        unselectedItemColor: KGiTONColors.textSecondaryDark,
      ),
    );
  }
}
