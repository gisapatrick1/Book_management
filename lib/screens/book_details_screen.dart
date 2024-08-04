import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import 'dart:io';

class BookDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as Book;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (book.thumbnailPath != null)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: FileImage(File(book.thumbnailPath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.book, size: 100, color: Colors.grey[400]),
              ),
            SizedBox(height: 20),
            Text(
              book.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Author: ${book.author}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.yellow[700], size: 30),
                  SizedBox(width: 8),
                  Text(book.rating.toString(), style: TextStyle(fontSize: 24)),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue, size: 24),
                    onPressed: () {
                      _showRatingDialog(context, book);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              'Content',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              book.content ?? '',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/editBook', arguments: book);
        },
        icon: Icon(Icons.edit),
        label: Text('Edit Book'),
      ),
    );
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
}
