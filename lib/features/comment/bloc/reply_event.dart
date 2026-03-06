abstract class ReplyEvent {}

class ReplyGetRequested extends ReplyEvent {
  final String commentId;
  ReplyGetRequested({required this.commentId});
}

class ReplyAddRequested extends ReplyEvent {
  final String postId;
  final String parentId;
  final String content;

  ReplyAddRequested({
    required this.postId,
    required this.parentId,
    required this.content,
  });
}
