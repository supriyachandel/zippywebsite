import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(Gender gender) {
    // thStyle Minimalist Light Theme
    const primaryColor = AppColors.textCharcoal;
    const accentColor = AppColors.accentBrown;
    const scaffoldBgColor = AppColors.backgroundBeige;
    const surfaceColor = AppColors.pureWhite; 
    const onSurfaceColor = AppColors.textCharcoal;

    final colorScheme = const ColorScheme.light(
      primary: primaryColor,
      onPrimary: AppColors.pureWhite,
      primaryContainer: AppColors.softGrey, 
      onPrimaryContainer: primaryColor,
      secondary: accentColor,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.accentTan,
      onSecondaryContainer: primaryColor,
      surface: surfaceColor,
      onSurface: onSurfaceColor,
      surfaceContainerHighest: AppColors.softGrey,
      onSurfaceVariant: Colors.black54,
      outline: AppColors.softGrey,
      error: AppColors.errorRed,
    );

    // Montserrat for text theme
    final bodyFont = GoogleFonts.montserratTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffoldBgColor,
      primaryColor: primaryColor,
      colorScheme: colorScheme,
      textTheme: bodyFont.copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: onSurfaceColor,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          fontSize: 32,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: onSurfaceColor,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        bodyLarge: GoogleFonts.montserrat(
          color: onSurfaceColor.withValues(alpha: 0.8),
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.montserrat(
          color: onSurfaceColor.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: onSurfaceColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: onSurfaceColor),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.softGrey, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: AppColors.pureWhite,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.3),
          disabledForegroundColor: Colors.white54,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const BeveledRectangleBorder(), // Matches the sharp button from the website
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: 1.0, fontStyle: FontStyle.italic),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: const BeveledRectangleBorder(),
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.softGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.softGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        prefixIconColor: Colors.black54,
        suffixIconColor: Colors.black54,
        labelStyle: GoogleFonts.montserrat(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        hintStyle: GoogleFonts.montserrat(
          color: Colors.black38,
          fontSize: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: colorScheme.primary,
        disabledColor: AppColors.softGrey,
        labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13, color: onSurfaceColor),
        secondaryLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.pureWhite),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: AppColors.softGrey),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.softGrey,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.black45,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
        selectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.montserrat(fontSize: 11),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.2),
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.1),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: const TextStyle(color: AppColors.pureWhite),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: AppColors.pureWhite,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textCharcoal,
        contentTextStyle: GoogleFonts.montserrat(color: AppColors.pureWhite, fontSize: 14, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
