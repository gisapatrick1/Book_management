import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';

class AddEditBookScreen extends StatefulWidget {
  @override
  _AddEditBookScreenState createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _author = '';
  String _content = '';
  String? _thumbnailPath;
  Book? _editingBook;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final book = ModalRoute.of(context)!.settings.arguments as Book?;
    if (book != null) {
      _editingBook = book;
      _title = book.title;
      _author = book.author;
      _content = book.content ?? '';
      _thumbnailPath = book.thumbnailPath;
    }
  }

  Future<void> _pickThumbnail() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final path = result.files.single.path;
      if (path != null) {
        setState(() {
          _thumbnailPath = path;
        });
      }
    }
  }

  Future<String> _copyFileToLocalDirectory(String filePath) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = filePath.split('/').last;
    final File copiedFile = await File(filePath).copy('${appDir.path}/$fileName');
    return copiedFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingBook == null ? 'Add Book' : 'Edit Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _editingBook == null ? 'Add New Book' : 'Edit Book',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value!;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _author,
                  decoration: InputDecoration(
                    labelText: 'Author',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an author';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _author = value!;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  initialValue: _content,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the content';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _content = value!;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickThumbnail,
                  icon: Icon(Icons.photo),
                  label: Text('Pick a Picture'),
                ),
                if (_thumbnailPath != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(
                      File(_thumbnailPath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final bookProvider = Provider.of<BookProvider>(context, listen: false);
                      String? thumbnailPath;
                      if (_thumbnailPath != null) {
                        thumbnailPath = await _copyFileToLocalDirectory(_thumbnailPath!);
                      }
                      if (_editingBook == null) {
                        bookProvider.addBook(Book(
                          id: DateTime.now().millisecondsSinceEpoch,
                          title: _title,
                          author: _author,
                          rating: 1, // Default rating
                          isRead: false, // Default read status
                          content: _content,
                          thumbnailPath: thumbnailPath,
                        ));
                      } else {
                        bookProvider.updateBook(Book(
                          id: _editingBook!.id,
                          title: _title,
                          author: _author,
                          rating: _editingBook!.rating,
                          isRead: _editingBook!.isRead,
                          content: _content,
                          thumbnailPath: thumbnailPath,
                        ));
                      }
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
