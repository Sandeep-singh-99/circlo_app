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
