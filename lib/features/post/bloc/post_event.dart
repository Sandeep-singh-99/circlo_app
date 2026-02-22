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
