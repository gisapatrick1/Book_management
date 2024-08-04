import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/book_provider.dart';
import '../providers/theme_provider.dart';
import '../models/book.dart';
import '../services/preferences_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _sortBy = 'title';
  final PreferencesService _preferencesService = PreferencesService();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    String savedSortBy = await _preferencesService.getSortPreference();
    setState(() {
      _sortBy = savedSortBy;
    });
  }

  Future<void> _saveSortPreference(String sortBy) async {
    await _preferencesService.saveSortPreference(sortBy);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Search'),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(hintText: 'Enter search query'),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sort By'),
          content: DropdownButtonFormField<String>(
            value: _sortBy,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            ),
            items: [
              DropdownMenuItem(value: 'title', child: Text('Title')),
              DropdownMenuItem(value: 'author', child: Text('Author')),
              DropdownMenuItem(value: 'rating', child: Text('Rating')),
            ],
            onChanged: (value) {
              setState(() {
                _sortBy = value!;
                _saveSortPreference(_sortBy);
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Library', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for books...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                List<Book> filteredBooks = bookProvider.books.where((book) {
                  return book.title.contains(_searchQuery) || book.author.contains(_searchQuery);
                }).toList();

                switch (_sortBy) {
                  case 'title':
                    filteredBooks.sort((a, b) => a.title.compareTo(b.title));
                    break;
                  case 'author':
                    filteredBooks.sort((a, b) => a.author.compareTo(b.author));
                    break;
                  case 'rating':
                    filteredBooks.sort((a, b) => b.rating.compareTo(a.rating));
                    break;
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/bookDetails', arguments: book);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: book.thumbnailPath != null
                                    ? Image.file(
                                        File(book.thumbnailPath!),
                                        width: 100,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 100,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(Icons.book, size: 60, color: Colors.grey[400]),
                                      ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      book.author,
                                      style: TextStyle(color: Colors.grey[600]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < book.rating ? Icons.star : Icons.star_border,
                                          color: Colors.yellow[700],
                                          size: 20,
                                        );
                                      }),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          book.isRead ? Icons.check_box : Icons.check_box_outline_blank,
                                          color: book.isRead ? Colors.green : Colors.grey,
                                        ),
                                        SizedBox(width: 8),
                                        Text(book.isRead ? 'Read' : 'Unread'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/manageBooks');
        },
      ),
    );
  }

  void _toggleReadStatus(BuildContext context, Book book) {
    Provider.of<BookProvider>(context, listen: false).toggleReadStatus(book.id, !book.isRead);
  }

  void _showRatingDialog(BuildContext context, Book book) {
    int newRating = book.rating;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rate ${book.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return RadioListTile<int>(
                title: Row(
                  children: List.generate(5, (starIndex) {
                    return Icon(
                      starIndex < index + 1 ? Icons.star : Icons.star_border,
                      color: Colors.yellow[700],
                    );
                  }),
                ),
                value: index + 1,
                groupValue: newRating,
                onChanged: (value) {
                  newRating = value!;
                  Provider.of<BookProvider>(context, listen: false).updateRating(book.id, newRating);
                  Navigator.of(context).pop();
                },
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          SwitchListTile(
            title: Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
        ],
      ),
    );
  }
}
