import 'package:circlo_app/features/bookmark/bloc/bookmark_event.dart';
import 'package:circlo_app/features/bookmark/bloc/bookmark_state.dart';
import 'package:circlo_app/features/bookmark/repository/bookmark_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final BookmarkRepository _bookmarkRepository;

  BookmarkBloc(this._bookmarkRepository) : super(BookmarkInitial()) {
    on<ToggleBookmark>(_onToggleBookmark);
    on<BookmarkResetRequested>((_, emit) => emit(BookmarkInitial()));
  }

  Future<void> _onToggleBookmark(
    ToggleBookmark event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(BookmarkLoading());
    try {
      final response = await _bookmarkRepository.toggleBookmark(event.id);
      emit(
        BookmarkToggled(
          postId: event.id,
          bookmarked: response.bookmarked,
          message: response.message,
        ),
      );
    } catch (e) {
      emit(BookmarkError(e.toString()));
    }
  }
}
