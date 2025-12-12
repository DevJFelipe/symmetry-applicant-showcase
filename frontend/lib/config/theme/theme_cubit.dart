import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/services/preferences_service.dart';

/// Theme mode options for the app
enum AppThemeMode {
  light,
  dark,
}

/// Cubit for managing theme state throughout the app.
class ThemeCubit extends Cubit<AppThemeMode> {
  final PreferencesService _preferencesService;

  ThemeCubit(this._preferencesService) : super(AppThemeMode.dark) {
    _loadTheme();
  }

  /// Loads the saved theme preference from storage.
  void _loadTheme() {
    final isDarkMode = _preferencesService.isDarkMode;
    emit(isDarkMode ? AppThemeMode.dark : AppThemeMode.light);
  }

  /// Toggles between light and dark theme.
  void toggleTheme() {
    final newMode =
        state == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark;
    emit(newMode);
    _preferencesService.setDarkMode(newMode == AppThemeMode.dark);
  }

  /// Sets a specific theme mode.
  void setTheme(AppThemeMode mode) {
    emit(mode);
    _preferencesService.setDarkMode(mode == AppThemeMode.dark);
  }

  /// Returns true if current theme is dark.
  bool get isDarkMode => state == AppThemeMode.dark;
}
