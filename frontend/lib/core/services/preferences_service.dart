import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local app preferences.
///
/// Handles user settings like notifications, haptic feedback,
/// data saver mode, etc. Uses SharedPreferences for persistence.
class PreferencesService {
  static const String _keyHapticEnabled = 'haptic_enabled';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyDataSaverEnabled = 'data_saver_enabled';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // ============================================
  // HAPTIC FEEDBACK
  // ============================================

  /// Whether haptic feedback is enabled. Defaults to true.
  bool get hapticEnabled => _prefs.getBool(_keyHapticEnabled) ?? true;

  /// Sets the haptic feedback preference.
  Future<void> setHapticEnabled(bool value) =>
      _prefs.setBool(_keyHapticEnabled, value);

  // ============================================
  // NOTIFICATIONS
  // ============================================

  /// Whether push notifications are enabled. Defaults to true.
  bool get notificationsEnabled =>
      _prefs.getBool(_keyNotificationsEnabled) ?? true;

  /// Sets the notifications preference.
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_keyNotificationsEnabled, value);

  // ============================================
  // DATA SAVER
  // ============================================

  /// Whether data saver mode is enabled. Defaults to false.
  bool get dataSaverEnabled => _prefs.getBool(_keyDataSaverEnabled) ?? false;

  /// Sets the data saver preference.
  Future<void> setDataSaverEnabled(bool value) =>
      _prefs.setBool(_keyDataSaverEnabled, value);
}
