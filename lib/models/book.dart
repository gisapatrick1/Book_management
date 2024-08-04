class Book {
  final int id;
  final String title;
  final String author;
  int rating; // Removed final
  bool isRead; // Removed final
  final String? content;
  final String? thumbnailPath;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.rating,
    required this.isRead,
    this.content,
    this.thumbnailPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'rating': rating,
      'isRead': isRead ? 1 : 0,
      'content': content,
      'thumbnailPath': thumbnailPath,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      rating: map['rating'],
      isRead: map['isRead'] == 1,
      content: map['content'],
      thumbnailPath: map['thumbnailPath'],
    );
  }
}
