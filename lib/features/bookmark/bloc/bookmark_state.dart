abstract class BookmarkState {}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}

class BookmarkToggled extends BookmarkState {
  final String postId;
  final bool bookmarked;
  final String message;

  BookmarkToggled({
    required this.postId,
    required this.bookmarked,
    required this.message,
  });
}

class BookmarkError extends BookmarkState {
  final String message;

  BookmarkError(this.message);
}
