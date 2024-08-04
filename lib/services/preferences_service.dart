import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themePreferenceKey = 'isDarkMode';
  static const String _readStatusPrefix = 'readStatus_';
  static const String _ratingPrefix = 'rating_';

  Future<bool> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themePreferenceKey) ?? false;
  }

  Future<void> setThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePreferenceKey, isDarkMode);
  }

  Future<void> saveReadStatus(int bookId, bool isRead) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_readStatusPrefix$bookId', isRead);
  }

  Future<bool?> getReadStatus(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_readStatusPrefix$bookId');
  }

  Future<void> saveRating(int bookId, int rating) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_ratingPrefix$bookId', rating);
  }

  Future<int?> getRating(int bookId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_ratingPrefix$bookId');
  }

  Future<void> saveSortPreference(String sortBy) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('sortBy', sortBy);
  }

  Future<String> getSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('sortBy') ?? 'title';
  }
}
