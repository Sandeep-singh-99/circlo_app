import 'package:circlo_app/features/post/models/post_model.dart';
import 'package:circlo_app/features/post/models/post_response_model.dart';

abstract class PostState {}

class PostStateInitial extends PostState {}

class PostLoading extends PostState {}

class PostSuccess extends PostState {
  final PostResponseModel postResponseModel;

  PostSuccess(this.postResponseModel);
}

class PostFailure extends PostState {
  final String message;

  PostFailure(this.message);
}

// ── Detail states (single post) ──────────────────────────────────────────────

class PostDetailLoading extends PostState {}

class PostDetailSuccess extends PostState {
  final PostModel post;

  PostDetailSuccess(this.post);
}

class PostDetailFailure extends PostState {
  final String message;

  PostDetailFailure(this.message);
}
