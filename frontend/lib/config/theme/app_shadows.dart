import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Premium shadow system for depth and elevation
abstract final class AppShadows {
  // ==========================================
  // ELEVATION SHADOWS
  // ==========================================
  
  /// No shadow
  static const List<BoxShadow> none = [];
  
  /// Subtle shadow - Cards at rest
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  /// Medium shadow - Elevated cards, dropdowns
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  /// Large shadow - Modals, floating elements
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  
  /// Extra large shadow - Dialogs, popovers
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  // ==========================================
  // GLOW EFFECTS
  // ==========================================
  
  /// Primary color glow - For buttons and interactive elements
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];
  
  /// Subtle primary glow
  static List<BoxShadow> primaryGlowSubtle = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.2),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  /// Success glow
  static List<BoxShadow> successGlow = [
    BoxShadow(
      color: AppColors.success.withOpacity(0.4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  /// Error glow
  static List<BoxShadow> errorGlow = [
    BoxShadow(
      color: AppColors.error.withOpacity(0.4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
  
  // ==========================================
  // INNER SHADOWS (for inset effects)
  // ==========================================
  
  /// Inner shadow for pressed states
  static const List<BoxShadow> innerSm = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      // Note: Flutter doesn't support inset shadows directly
      // This would need to be simulated with Container decoration
    ),
  ];
}
