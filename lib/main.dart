import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/manage_books_screen.dart';
import 'screens/add_edit_book_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/book_details_screen.dart';
import 'providers/book_provider.dart';
import 'providers/theme_provider.dart';
import 'services/preferences_service.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isDarkMode = await PreferencesService().getThemePreference();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider(DatabaseService(), PreferencesService())),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..toggleTheme(isDarkMode)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/manageBooks': (context) => ManageBooksScreen(),
        '/addEditBook': (context) => AddEditBookScreen(),
        '/settings': (context) => SettingsScreen(),
        '/bookDetails': (context) => BookDetailsScreen(),
      },
    );
  }
}
