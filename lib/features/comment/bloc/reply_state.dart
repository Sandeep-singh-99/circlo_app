import 'package:circlo_app/features/comment/model/comment_model.dart';

abstract class ReplyState {}

class ReplyInitial extends ReplyState {}

class ReplyLoading extends ReplyState {}

class ReplyLoaded extends ReplyState {
  final List<CommentModel> replies;
  ReplyLoaded({required this.replies});
}

class ReplyError extends ReplyState {
  final String message;
  ReplyError({required this.message});
}
