import 'package:circlo_app/features/comment/bloc/reply_event.dart';
import 'package:circlo_app/features/comment/bloc/reply_state.dart';
import 'package:circlo_app/features/comment/model/comment_model.dart';
import 'package:circlo_app/features/comment/repository/comment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReplyBloc extends Bloc<ReplyEvent, ReplyState> {
  final CommentRepository _repository;

  ReplyBloc(this._repository) : super(ReplyInitial()) {
    on<ReplyGetRequested>(_onReplyGetRequested);
    on<ReplyAddRequested>(_onReplyAddRequested);
  }

  Future<void> _onReplyGetRequested(
    ReplyGetRequested event,
    Emitter<ReplyState> emit,
  ) async {
    emit(ReplyLoading());
    try {
      final replies = await _repository.getReplies(event.commentId);
      emit(ReplyLoaded(replies: replies));
    } catch (e) {
      emit(ReplyError(message: e.toString()));
    }
  }

  Future<void> _onReplyAddRequested(
    ReplyAddRequested event,
    Emitter<ReplyState> emit,
  ) async {
    final currentState = state;
    List<CommentModel> currentReplies = [];
    if (currentState is ReplyLoaded) {
      currentReplies = currentState.replies;
    }

    try {
      final newReply = await _repository.addComment(
        event.postId,
        event.content,
        parentId: event.parentId,
      );
      emit(ReplyLoaded(replies: [...currentReplies, newReply]));
    } catch (e) {
      emit(ReplyError(message: e.toString()));
    }
  }
}
