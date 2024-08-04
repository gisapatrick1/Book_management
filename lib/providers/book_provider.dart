import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];
  final DatabaseService _databaseService;
  final PreferencesService _preferencesService;

  BookProvider(this._databaseService, this._preferencesService) {
    _loadBooks();
  }

  List<Book> get books => _books;

  Future<void> _loadBooks() async {
    _books = await _databaseService.books();
    // Load read statuses and ratings from preferences
    for (var book in _books) {
      final readStatus = await _preferencesService.getReadStatus(book.id);
      if (readStatus != null) {
        book.isRead = readStatus;
      }
      final rating = await _preferencesService.getRating(book.id);
      if (rating != null) {
        book.rating = rating;
      }
    }
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    await _databaseService.insertBook(book);
    _loadBooks();
  }

  Future<void> updateBook(Book book) async {
    await _databaseService.updateBook(book);
    _loadBooks();
  }

  Future<void> deleteBook(int id) async {
    await _databaseService.deleteBook(id);
    _loadBooks();
  }

  Future<void> toggleReadStatus(int id, bool isRead) async {
    await _databaseService.toggleReadStatus(id, isRead);
    await _preferencesService.saveReadStatus(id, isRead);
    _loadBooks();
  }

  Future<void> updateRating(int id, int rating) async {
    final book = _books.firstWhere((book) => book.id == id);
    book.rating = rating;
    await _databaseService.updateBook(book);
    await _preferencesService.saveRating(id, rating);
    notifyListeners();
  }
}
