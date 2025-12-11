import 'package:flutter/material.dart';

/// Consistent border radius system
abstract final class AppRadius {
  // ==========================================
  // BASE RADIUS VALUES
  // ==========================================
  
  /// No radius - Sharp corners
  static const double none = 0;
  
  /// 4px - Subtle rounding
  static const double xs = 4;
  
  /// 8px - Small radius
  static const double sm = 8;
  
  /// 12px - Medium radius
  static const double md = 12;
  
  /// 16px - Large radius
  static const double lg = 16;
  
  /// 20px - Extra large radius
  static const double xl = 20;
  
  /// 24px - 2x Extra large
  static const double xxl = 24;
  
  /// Full circle
  static const double full = 999;
  
  // ==========================================
  // BORDER RADIUS PRESETS
  // ==========================================
  
  /// No radius
  static const BorderRadius zero = BorderRadius.zero;
  
  /// Extra small radius
  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  
  /// Small radius - Buttons, chips
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  
  /// Medium radius - Cards, inputs
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  
  /// Large radius - Modals, sheets
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  
  /// Extra large radius - Images, hero sections
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  
  /// 2x Extra large radius
  static const BorderRadius borderXxl = BorderRadius.all(Radius.circular(xxl));
  
  /// Fully rounded (pills)
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(full));
  
  // ==========================================
  // SPECIFIC COMPONENT RADIUS
  // ==========================================
  
  /// Card default radius
  static const BorderRadius card = borderMd;
  
  /// Bento card radius
  static const BorderRadius bentoCard = borderLg;
  
  /// Button radius
  static const BorderRadius button = borderSm;
  
  /// Input field radius
  static const BorderRadius input = borderSm;
  
  /// Modal/Dialog radius
  static const BorderRadius modal = borderXl;
  
  /// Bottom sheet top radius
  static const BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
  
  /// Image radius in cards
  static const BorderRadius image = borderMd;
  
  /// Avatar radius (circular)
  static const BorderRadius avatar = borderFull;
  
  /// Chip/Tag radius
  static const BorderRadius chip = borderFull;
  
  /// FAB radius
  static const BorderRadius fab = borderFull;
  
  // ==========================================
  // TOP-ONLY RADIUS
  // ==========================================
  
  static const BorderRadius topMd = BorderRadius.vertical(
    top: Radius.circular(md),
  );
  
  static const BorderRadius topLg = BorderRadius.vertical(
    top: Radius.circular(lg),
  );
  
  static const BorderRadius topXl = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
  
  // ==========================================
  // BOTTOM-ONLY RADIUS
  // ==========================================
  
  static const BorderRadius bottomMd = BorderRadius.vertical(
    bottom: Radius.circular(md),
  );
  
  static const BorderRadius bottomLg = BorderRadius.vertical(
    bottom: Radius.circular(lg),
  );
}
