import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool isOn) {
    _isDarkMode = isOn;
    PreferencesService().setThemePreference(_isDarkMode); // Corrected method name
    notifyListeners();
  }

  void loadThemePreference() async {
    _isDarkMode = await PreferencesService().getThemePreference();
    notifyListeners();
  }
}
