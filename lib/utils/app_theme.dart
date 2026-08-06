import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(Gender gender) {
    // ZippyStyle 2026 Unified Theme (Dark/Professional)
    const primaryColor = AppColors.electricVolt;
    const accentColor = AppColors.sunsetOrange;
    const scaffoldBgColor = AppColors.inkBlack;
    const surfaceColor = AppColors.primaryDark; // Slightly lighter than inkBlack
    const onSurfaceColor = AppColors.pureWhite;

    final colorScheme = const ColorScheme.dark(
      primary: primaryColor,
      onPrimary: AppColors.inkBlack,
      primaryContainer: Color(0xFF2C320A), // Darkened electric volt
      onPrimaryContainer: primaryColor,
      secondary: accentColor,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF331600), // Darkened orange
      onSecondaryContainer: accentColor,
      surface: surfaceColor,
      onSurface: onSurfaceColor,
      surfaceContainerHighest: AppColors.softGrey,
      onSurfaceVariant: Colors.white70,
      outline: AppColors.softGrey,
      error: AppColors.errorRed,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBgColor,
      primaryColor: primaryColor,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(
          color: onSurfaceColor,
          fontWeight: FontWeight.w800,
          fontSize: 32,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: onSurfaceColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: onSurfaceColor),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: AppColors.inkBlack,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.3),
          disabledForegroundColor: Colors.white54,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.softGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.softGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        prefixIconColor: Colors.white54,
        suffixIconColor: Colors.white54,
        labelStyle: GoogleFonts.poppins(
          color: Colors.white54,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        hintStyle: GoogleFonts.poppins(
          color: Colors.white38,
          fontSize: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: colorScheme.primary,
        disabledColor: AppColors.softGrey,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: onSurfaceColor),
        secondaryLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.inkBlack),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: const BorderSide(color: AppColors.softGrey),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.softGrey,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scaffoldBgColor,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.2),
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.1),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: const TextStyle(color: AppColors.inkBlack),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: AppColors.inkBlack,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.pureWhite,
        contentTextStyle: GoogleFonts.poppins(color: AppColors.inkBlack, fontSize: 14, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}

enum Gender { male, female, other }
