abstract class CommentEvent {}

class CommentAddRequested extends CommentEvent {
  final String postId;
  final String content;

  CommentAddRequested({required this.postId, required this.content});
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
