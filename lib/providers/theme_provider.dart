import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  indigo,
  ocean,
  forest,
  sunset,
  lavender,
  charcoal,
  midnight,
}

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.indigo;
  bool _isDarkMode = false;
  SharedPreferences? _prefs;

  AppTheme get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  static const String _themeKey = 'app_theme';
  static const String _darkModeKey = 'dark_mode';

  Future<void> loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex = _prefs?.getInt(_themeKey) ?? 0;
    final darkMode = _prefs?.getBool(_darkModeKey) ?? false;
    
    _currentTheme = AppTheme.values[themeIndex];
    _isDarkMode = darkMode;
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    await _prefs?.setInt(_themeKey, theme.index);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs?.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  ThemeData get lightTheme {
    switch (_currentTheme) {
      case AppTheme.indigo:
        return _createTheme(
          primary: const Color(0xFF3F51B5),
          secondary: const Color(0xFF9C27B0),
          surface: const Color(0xFFFAFAFA),
          brightness: Brightness.light,
        );
      case AppTheme.ocean:
        return _createTheme(
          primary: const Color(0xFF0277BD),
          secondary: const Color(0xFF00ACC1),
          surface: const Color(0xFFF0F8FF),
          brightness: Brightness.light,
        );
      case AppTheme.forest:
        return _createTheme(
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF66BB6A),
          surface: const Color(0xFFF1F8E9),
          brightness: Brightness.light,
        );
      case AppTheme.sunset:
        return _createTheme(
          primary: const Color(0xFFD84315),
          secondary: const Color(0xFFFF9800),
          surface: const Color(0xFFFFF8F0),
          brightness: Brightness.light,
        );
      case AppTheme.lavender:
        return _createTheme(
          primary: const Color(0xFF7B1FA2),
          secondary: const Color(0xFFBA68C8),
          surface: const Color(0xFFFCF4FF),
          brightness: Brightness.light,
        );
      case AppTheme.charcoal:
        return _createTheme(
          primary: const Color(0xFF455A64),
          secondary: const Color(0xFF78909C),
          surface: const Color(0xFFF5F5F5),
          brightness: Brightness.light,
        );
      case AppTheme.midnight:
        return _createTheme(
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFF303F9F),
          surface: const Color(0xFFF8F9FA),
          brightness: Brightness.light,
        );
    }
  }

  ThemeData get darkTheme {
    switch (_currentTheme) {
      case AppTheme.indigo:
        return _createTheme(
          primary: const Color(0xFF5C6BC0),
          secondary: const Color(0xFFBA68C8),
          surface: const Color(0xFF121212),
          brightness: Brightness.dark,
        );
      case AppTheme.ocean:
        return _createTheme(
          primary: const Color(0xFF29B6F6),
          secondary: const Color(0xFF26C6DA),
          surface: const Color(0xFF0A1929),
          brightness: Brightness.dark,
        );
      case AppTheme.forest:
        return _createTheme(
          primary: const Color(0xFF66BB6A),
          secondary: const Color(0xFF81C784),
          surface: const Color(0xFF0D1B0F),
          brightness: Brightness.dark,
        );
      case AppTheme.sunset:
        return _createTheme(
          primary: const Color(0xFFFF5722),
          secondary: const Color(0xFFFFAB40),
          surface: const Color(0xFF1A0E0A),
          brightness: Brightness.dark,
        );
      case AppTheme.lavender:
        return _createTheme(
          primary: const Color(0xFFBA68C8),
          secondary: const Color(0xFFCE93D8),
          surface: const Color(0xFF1A0D1F),
          brightness: Brightness.dark,
        );
      case AppTheme.charcoal:
        return _createTheme(
          primary: const Color(0xFF78909C),
          secondary: const Color(0xFF90A4AE),
          surface: const Color(0xFF0F1419),
          brightness: Brightness.dark,
        );
      case AppTheme.midnight:
        return _createTheme(
          primary: const Color(0xFF3F51B5),
          secondary: const Color(0xFF5C6BC0),
          surface: const Color(0xFF0A0E1A),
          brightness: Brightness.dark,
        );
    }
  }

  ThemeData _createTheme({
    required Color primary,
    required Color secondary,
    required Color surface,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      secondary: secondary,
      surface: surface,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.indigo:
        return 'Indigo';
      case AppTheme.ocean:
        return 'Ocean';
      case AppTheme.forest:
        return 'Forest';
      case AppTheme.sunset:
        return 'Sunset';
      case AppTheme.lavender:
        return 'Lavender';
      case AppTheme.charcoal:
        return 'Charcoal';
      case AppTheme.midnight:
        return 'Midnight';
    }
  }
}