import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Premium typography system with editorial hierarchy
/// Uses Playfair Display for headlines (Serif) and Lato for body (Sans-serif)
abstract final class AppTypography {
  // ==========================================
  // BASE FONT FAMILIES
  // ==========================================
  
  /// Serif font for headlines and editorial content
  static String get serifFamily => GoogleFonts.playfairDisplay().fontFamily!;
  
  /// Sans-serif font for body text and UI elements
  static String get sansFamily => GoogleFonts.lato().fontFamily!;
  
  // ==========================================
  // DISPLAY STYLES (Large Headlines)
  // ==========================================
  
  /// Display Large - Hero headlines
  static TextStyle displayLarge = GoogleFonts.playfairDisplay(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -0.5,
  );
  
  /// Display Medium - Section headers
  static TextStyle displayMedium = GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.25,
  );
  
  /// Display Small - Card headlines
  static TextStyle displaySmall = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  // ==========================================
  // HEADLINE STYLES
  // ==========================================
  
  /// Headline Large
  static TextStyle headlineLarge = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );
  
  /// Headline Medium
  static TextStyle headlineMedium = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  /// Headline Small
  static TextStyle headlineSmall = GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );
  
  // ==========================================
  // TITLE STYLES (UI Elements)
  // ==========================================
  
  /// Title Large - Page titles
  static TextStyle titleLarge = GoogleFonts.lato(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  /// Title Medium - Section titles
  static TextStyle titleMedium = GoogleFonts.lato(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );
  
  /// Title Small - Card titles, list items
  static TextStyle titleSmall = GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  // ==========================================
  // BODY STYLES
  // ==========================================
  
  /// Body Large - Main article content
  static TextStyle bodyLarge = GoogleFonts.lato(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.6,
    letterSpacing: 0.15,
  );
  
  /// Body Medium - Default body text
  static TextStyle bodyMedium = GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.25,
  );
  
  /// Body Small - Secondary content
  static TextStyle bodySmall = GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.45,
    letterSpacing: 0.25,
  );
  
  // ==========================================
  // LABEL STYLES
  // ==========================================
  
  /// Label Large - Buttons, prominent labels
  static TextStyle labelLarge = GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0.5,
  );
  
  /// Label Medium - Form labels, tags
  static TextStyle labelMedium = GoogleFonts.lato(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.5,
  );
  
  /// Label Small - Captions, metadata
  static TextStyle labelSmall = GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.35,
    letterSpacing: 0.5,
  );
  
  // ==========================================
  // SPECIAL STYLES
  // ==========================================
  
  /// Caption for timestamps and metadata
  static TextStyle caption = GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
    height: 1.3,
    letterSpacing: 0.4,
  );
  
  /// Overline for categories and tags
  static TextStyle overline = GoogleFonts.lato(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.2,
    letterSpacing: 1.5,
  );
  
  /// Button text
  static TextStyle button = GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    height: 1.4,
    letterSpacing: 0.75,
  );
  
  /// Article body optimized for reading
  static TextStyle articleBody = GoogleFonts.lato(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.8,
    letterSpacing: 0.2,
  );
  
  /// Quote/Highlight text
  static TextStyle quote = GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  // ==========================================
  // HELPER: Get TextTheme for ThemeData
  // ==========================================
  
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
