import 'package:flutter/material.dart';

/// Premium Dark Editorial color palette
/// Designed for a modern, immersive news reading experience
abstract final class AppColors {
  // ==========================================
  // PRIMARY COLORS - Electric Violet Accent
  // ==========================================
  
  /// Primary accent color - Electric Violet
  static const Color primary = Color(0xFF8B5CF6);
  
  /// Lighter variant for hover states and highlights
  static const Color primaryLight = Color(0xFFA78BFA);
  
  /// Darker variant for pressed states
  static const Color primaryDark = Color(0xFF7C3AED);
  
  /// Very light variant for subtle backgrounds
  static const Color primarySoft = Color(0xFF2D1B69);
  
  // ==========================================
  // BACKGROUND COLORS - Deep Dark Editorial
  // ==========================================
  
  /// Main background - Deep charcoal (not pure black for eye comfort)
  static const Color background = Color(0xFF0F0F13);
  
  /// Secondary background for cards and elevated surfaces
  static const Color surface = Color(0xFF1A1A23);
  
  /// Tertiary surface for nested elements
  static const Color surfaceVariant = Color(0xFF242430);
  
  /// Lighter surface variant
  static const Color surfaceLight = Color(0xFF2A2A38);
  
  /// Elevated surface for modals and dialogs
  static const Color surfaceElevated = Color(0xFF2A2A38);
  
  // ==========================================
  // TEXT COLORS
  // ==========================================
  
  /// Primary text - High emphasis
  static const Color textPrimary = Color(0xFFFAFAFA);
  
  /// Secondary text - Medium emphasis
  static const Color textSecondary = Color(0xFFB0B0B8);
  
  /// Tertiary text - Low emphasis (metadata, captions)
  static const Color textTertiary = Color(0xFF6B6B78);
  
  /// Muted text - Very low emphasis
  static const Color textMuted = Color(0xFF6B6B78);
  
  /// Disabled text
  static const Color textDisabled = Color(0xFF4A4A58);
  
  /// Text on primary color background
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // ==========================================
  // SEMANTIC COLORS
  // ==========================================
  
  /// Success - Emerald green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successSoft = Color(0xFF064E3B);
  
  /// Error - Rose red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorSoft = Color(0xFF7F1D1D);
  
  /// Warning - Amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningSoft = Color(0xFF78350F);
  
  /// Info - Cyan
  static const Color info = Color(0xFF06B6D4);
  static const Color infoLight = Color(0xFF22D3EE);
  static const Color infoSoft = Color(0xFF164E63);
  
  // ==========================================
  // BORDERS & DIVIDERS
  // ==========================================
  
  /// Subtle border for cards
  static const Color border = Color(0xFF2A2A38);
  
  /// More visible border for inputs
  static const Color borderStrong = Color(0xFF3A3A48);
  
  /// Divider lines
  static const Color divider = Color(0xFF1F1F28);
  
  // ==========================================
  // OVERLAY & EFFECTS
  // ==========================================
  
  /// Scrim for modals and dialogs
  static const Color scrim = Color(0xCC000000);
  
  /// Shimmer base color
  static const Color shimmerBase = Color(0xFF1A1A23);
  
  /// Shimmer highlight color
  static const Color shimmerHighlight = Color(0xFF2A2A38);
  
  // ==========================================
  // GRADIENT PRESETS
  // ==========================================
  
  /// Image overlay gradient (bottom to top)
  static const LinearGradient imageOverlay = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xE6000000), // 90% opacity
      Color(0x80000000), // 50% opacity
      Color(0x00000000), // Transparent
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  /// Subtle image overlay for smaller cards
  static const LinearGradient imageOverlaySubtle = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xCC000000), // 80% opacity
      Color(0x00000000), // Transparent
    ],
    stops: [0.0, 0.6],
  );
  
  /// Primary gradient for buttons and accents
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFA78BFA),
      Color(0xFF8B5CF6),
      Color(0xFF7C3AED),
    ],
  );
  
  /// Glass effect gradient
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
  );
  
  // ==========================================
  // REACTION COLORS (for article reactions)
  // ==========================================
  
  static const Color reactionLike = Color(0xFF3B82F6);
  static const Color reactionFire = Color(0xFFFF6B35);
  static const Color reactionLove = Color(0xFFFF4D6D);
  static const Color reactionMindBlown = Color(0xFFFFD166);
  static const Color reactionThinking = Color(0xFFFFD166); // Thinking face (same as mindblown)
  static const Color reactionSad = Color(0xFF5E7CE2);
  static const Color reactionAngry = Color(0xFFEF4444);
  static const Color reactionClap = Color(0xFF06D6A0);
  
  // ==========================================
  // SHADOW COLORS
  // ==========================================
  
  /// Dark shadow for elevation
  static const Color shadowDark = Color(0x40000000);
  
  /// Subtle shadow
  static const Color shadowLight = Color(0x20000000);
  
  // ==========================================
  // ACCENT ALIASES
  // ==========================================
  
  /// Accent color alias for primary
  static const Color accent = primary;
  
  /// Accent gradient
  static const LinearGradient accentGradient = primaryGradient;
}
