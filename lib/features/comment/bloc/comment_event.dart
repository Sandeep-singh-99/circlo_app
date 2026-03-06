abstract class CommentEvent {}

class CommentAddRequested extends CommentEvent {
  final String postId;
  final String content;
  final String? parentId;

  CommentAddRequested({
    required this.postId,
    required this.content,
    this.parentId,
  });
}

class CommentDeleteRequested extends CommentEvent {
  final String id;

  CommentDeleteRequested({required this.id});
}

class CommentGetRequested extends CommentEvent {
  final String postId;

  CommentGetRequested({required this.postId});
}

class CommentUpdateRequested extends CommentEvent {
  final String id;
  final String content;

  CommentUpdateRequested({required this.id, required this.content});
}

class CommentLikeToggleRequested extends CommentEvent {
  final String commentId;

  CommentLikeToggleRequested({required this.commentId});
}
