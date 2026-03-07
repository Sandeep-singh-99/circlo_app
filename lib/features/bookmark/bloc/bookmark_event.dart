abstract class BookmarkEvent {}

class ToggleBookmark extends BookmarkEvent {
  final String id;

  ToggleBookmark(this.id);
}

/// Fired on logout — resets bookmark state so the previous user's
/// bookmarks are not visible after an account switch.
class BookmarkResetRequested extends BookmarkEvent {}
