import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'books.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE books(id INTEGER PRIMARY KEY, title TEXT, author TEXT, rating INTEGER, isRead INTEGER, content TEXT, thumbnailPath TEXT)",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _onUpgrade(db, oldVersion, newVersion);
      },
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("DROP TABLE IF EXISTS books");
      await db.execute(
        "CREATE TABLE books(id INTEGER PRIMARY KEY, title TEXT, author TEXT, rating INTEGER, isRead INTEGER, content TEXT, thumbnailPath TEXT)",
      );
    }
  }

  Future<void> deleteAndRecreateTable() async {
    final db = await database;
    await db.execute("DROP TABLE IF EXISTS books");
    await db.execute(
      "CREATE TABLE books(id INTEGER PRIMARY KEY, title TEXT, author TEXT, rating INTEGER, isRead INTEGER, content TEXT, thumbnailPath TEXT)",
    );
  }

  Future<void> insertBook(Book book) async {
    final db = await database;
    await db.insert('books', book.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Book>> books() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<void> updateBook(Book book) async {
    final db = await database;
    await db.update('books', book.toMap(), where: "id = ?", whereArgs: [book.id]);
  }

  Future<void> deleteBook(int id) async {
    final db = await database;
    await db.delete('books', where: "id = ?", whereArgs: [id]);
  }

  Future<void> toggleReadStatus(int id, bool isRead) async {
    final db = await database;
    await db.update(
      'books',
      {'isRead': isRead ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
