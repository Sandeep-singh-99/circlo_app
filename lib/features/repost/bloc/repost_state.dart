import 'package:circlo_app/features/post/models/post_model.dart';

abstract class RepostState {}

class RepostInitial extends RepostState {}

class RepostLoading extends RepostState {}

class RepostToggled extends RepostState {
  final String postId;
  final bool reposted;
  final int repostCount;

  RepostToggled({
    required this.postId,
    required this.reposted,
    required this.repostCount,
  });
}

class RepostError extends RepostState {
  final String message;
  RepostError(this.message);
}

class RepostsLoaded extends RepostState {
  final List<PostModel> posts;
  RepostsLoaded(this.posts);
}
