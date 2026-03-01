abstract class BookmarkEvent {}

class ToggleBookmark extends BookmarkEvent {
  final String id;

  ToggleBookmark(this.id);
}


