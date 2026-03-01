final class BookmarkModel {
  final bool bookmarked;
  final String message;

  BookmarkModel({required this.bookmarked, required this.message});

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      bookmarked: json['bookmarked'] as bool,
      message: json['message'] as String,
    );
  }
}
