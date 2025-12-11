import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Service for haptic feedback throughout the app.
/// Provides consistent tactile feedback for user interactions.
abstract final class HapticService {
  static bool _hasVibrator = true;
  
  /// Initialize the haptic service
  /// Call this during app initialization
  static Future<void> initialize() async {
    _hasVibrator = await Vibration.hasVibrator() ?? false;
  }
  
  /// Light impact - for subtle interactions (taps, selections)
  static Future<void> lightImpact() async {
    if (_hasVibrator) {
      await HapticFeedback.lightImpact();
    }
  }
  
  /// Medium impact - for standard interactions (buttons, toggles)
  static Future<void> mediumImpact() async {
    if (_hasVibrator) {
      await HapticFeedback.mediumImpact();
    }
  }
  
  /// Heavy impact - for significant actions (delete, submit)
  static Future<void> heavyImpact() async {
    if (_hasVibrator) {
      await HapticFeedback.heavyImpact();
    }
  }
  
  /// Selection click - for discrete selections
  static Future<void> selectionClick() async {
    if (_hasVibrator) {
      await HapticFeedback.selectionClick();
    }
  }
  
  /// Success pattern - for successful operations
  static Future<void> success() async {
    if (_hasVibrator) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    }
  }
  
  /// Error pattern - for error feedback
  static Future<void> error() async {
    if (_hasVibrator) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    }
  }
  
  /// Warning pattern - for warnings/confirmations
  static Future<void> warning() async {
    if (_hasVibrator) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.mediumImpact();
    }
  }
  
  /// Custom vibration pattern
  /// [durations] - alternating wait and vibrate times in milliseconds
  static Future<void> custom(List<int> pattern) async {
    if (_hasVibrator) {
      final hasCustom = await Vibration.hasCustomVibrationsSupport() ?? false;
      if (hasCustom) {
        await Vibration.vibrate(pattern: pattern);
      } else {
        await HapticFeedback.mediumImpact();
      }
    }
  }
  
  /// Reaction feedback - celebratory pattern for reactions
  static Future<void> reaction() async {
    if (_hasVibrator) {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.mediumImpact();
    }
  }
  
  /// Long press feedback
  static Future<void> longPress() async {
    if (_hasVibrator) {
      await HapticFeedback.mediumImpact();
    }
  }
}
