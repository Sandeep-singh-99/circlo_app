import 'package:circlo_app/features/comment/bloc/comment_event.dart';
import 'package:circlo_app/features/comment/bloc/comment_state.dart';
import 'package:circlo_app/features/comment/model/comment_model.dart';
import 'package:circlo_app/features/comment/repository/comment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final CommentRepository _commentRepository;

  CommentBloc(this._commentRepository) : super(CommentInitial()) {
    on<CommentAddRequested>(_onCommentAddRequested);
    on<CommentDeleteRequested>(_onCommentDeleteRequested);
    on<CommentGetRequested>(_onCommentGetRequested);
    on<CommentUpdateRequested>(_onCommentUpdateRequested);
    on<CommentLikeToggleRequested>(_onCommentLikeToggleRequested);
  }

  Future<void> _onCommentAddRequested(
    CommentAddRequested event,
    Emitter<CommentState> emit,
  ) async {
    final currentState = state;
    List<CommentModel> currentComments = [];
    if (currentState is CommentLoaded) {
      currentComments = currentState.comments;
    }

    emit(CommentLoading());
    try {
      final response = await _commentRepository.addComment(
        event.postId,
        event.content,
        parentId: event.parentId,
      );
      // New comment appears at the top (only top-level; replies handled by ReplyBloc)
      emit(CommentLoaded(comments: [response, ...currentComments]));
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> _onCommentDeleteRequested(
    CommentDeleteRequested event,
    Emitter<CommentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CommentLoaded) return;

    final currentComments = currentState.comments;
    emit(CommentLoading());
    try {
      await _commentRepository.deleteComment(event.id);
      final updatedComments = currentComments
          .where((c) => c.id != event.id)
          .toList();
      emit(CommentLoaded(comments: updatedComments));
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> _onCommentGetRequested(
    CommentGetRequested event,
    Emitter<CommentState> emit,
  ) async {
    emit(CommentLoading());
    try {
      final response = await _commentRepository.getComments(event.postId);
      emit(CommentLoaded(comments: response));
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> _onCommentUpdateRequested(
    CommentUpdateRequested event,
    Emitter<CommentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CommentLoaded) return;

    final currentComments = currentState.comments;
    emit(CommentLoading());
    try {
      final response = await _commentRepository.updateComment(
        event.id,
        event.content,
      );
      final updatedComments = currentComments.map((c) {
        return c.id == event.id ? response : c;
      }).toList();
      emit(CommentLoaded(comments: updatedComments));
    } catch (e) {
      emit(CommentError(message: e.toString()));
    }
  }

  Future<void> _onCommentLikeToggleRequested(
    CommentLikeToggleRequested event,
    Emitter<CommentState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CommentLoaded) return;

    // Optimistic update
    final optimisticComments = currentState.comments.map((c) {
      if (c.id == event.commentId) {
        final liked = !c.isLikedByCurrentUser;
        return c.copyWith(
          isLikedByCurrentUser: liked,
          likeCount: liked ? c.likeCount + 1 : c.likeCount - 1,
        );
      }
      return c;
    }).toList();
    emit(CommentLoaded(comments: optimisticComments));

    try {
      await _commentRepository.toggleCommentLike(event.commentId);
    } catch (e) {
      // Revert on failure
      emit(CommentLoaded(comments: currentState.comments));
    }
  }
}
