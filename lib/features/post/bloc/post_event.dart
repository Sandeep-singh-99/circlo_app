import 'dart:io';

abstract class PostEvent {}

class PostCreateRequested extends PostEvent {
  final String content;
  final File? image;

  PostCreateRequested({required this.content, this.image});
}

class PostGetAllRequested extends PostEvent {}

class PostDeleteRequested extends PostEvent {
  final String id;

  PostDeleteRequested({required this.id});
}

class PostGetByIdRequested extends PostEvent {
  final String id;

  PostGetByIdRequested({required this.id});
}

class PostGetOwnRequested extends PostEvent {}

/// Fired on logout — resets the bloc back to its initial state so a
/// different user's posts are never shown after an account switch.
class PostResetRequested extends PostEvent {}
