import 'package:flutter/material.dart';

/// Consistent spacing system based on 4px grid
/// Ensures visual rhythm and alignment across the app
abstract final class AppSpacing {
  // ==========================================
  // BASE UNIT
  // ==========================================
  
  /// Base spacing unit (4px)
  static const double unit = 4.0;
  
  // ==========================================
  // SPACING SCALE
  // ==========================================
  
  /// 2px - Micro spacing
  static const double xxs = unit * 0.5;  // 2
  
  /// 4px - Extra small
  static const double xs = unit;          // 4
  
  /// 8px - Small
  static const double sm = unit * 2;      // 8
  
  /// 12px - Medium-small
  static const double md = unit * 3;      // 12
  
  /// 16px - Medium
  static const double lg = unit * 4;      // 16
  
  /// 20px - Medium-large
  static const double xl = unit * 5;      // 20
  
  /// 24px - Large
  static const double xxl = unit * 6;     // 24
  
  /// 32px - Extra large
  static const double xxxl = unit * 8;    // 32
  
  /// 40px - 2x Extra large
  static const double xxxxl = unit * 10;  // 40
  
  /// 48px - Huge
  static const double huge = unit * 12;   // 48
  
  /// 64px - Massive
  static const double massive = unit * 16; // 64
  
  // ==========================================
  // SEMANTIC SPACING
  // ==========================================
  
  /// Page horizontal padding
  static const double pagePadding = lg;
  
  /// Screen horizontal padding
  static const double screenPaddingH = lg;
  
  /// Screen vertical padding
  static const double screenPaddingV = lg;
  
  /// Card internal padding
  static const double cardPadding = lg;
  
  /// Item spacing in lists
  static const double listItemSpacing = md;
  
  /// Section spacing
  static const double sectionSpacing = xxxl;
  
  /// Form field spacing
  static const double formFieldSpacing = lg;
  
  /// Icon to text spacing
  static const double iconTextSpacing = sm;
  
  /// App bar height
  static const double appBarHeight = 56.0;
  
  /// Bottom navigation height
  static const double bottomNavHeight = 80.0;
  
  /// FAB size
  static const double fabSize = 56.0;
  
  // ==========================================
  // EDGE INSETS HELPERS
  // ==========================================
  
  /// No padding
  static const EdgeInsets zero = EdgeInsets.zero;
  
  /// Horizontal page padding
  static const EdgeInsets horizontalPage = EdgeInsets.symmetric(
    horizontal: pagePadding,
  );
  
  /// Vertical section padding
  static const EdgeInsets verticalSection = EdgeInsets.symmetric(
    vertical: sectionSpacing,
  );
  
  /// All-around card padding
  static const EdgeInsets card = EdgeInsets.all(cardPadding);
  
  /// All-around page padding
  static const EdgeInsets page = EdgeInsets.all(pagePadding);
  
  /// Small all-around padding
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  
  /// Medium all-around padding
  static const EdgeInsets allMd = EdgeInsets.all(md);
  
  /// Large all-around padding
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  
  /// Extra large all-around padding
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  
  // ==========================================
  // BENTO GRID SPECIFIC
  // ==========================================
  
  /// Gap between bento grid items
  static const double bentoGap = md;
  
  /// Bento card large height (featured)
  static const double bentoLargeHeight = 280.0;
  
  /// Bento card medium height
  static const double bentoMediumHeight = 200.0;
  
  /// Bento card small height
  static const double bentoSmallHeight = 160.0;
}
