abstract class LikeState {}

class LikeInitial extends LikeState {}

class LikeLoading extends LikeState {}

class LikeToggled extends LikeState {
  final String postId;
  final bool liked;
  final int totalLikes;

  LikeToggled({
    required this.postId,
    required this.liked,
    required this.totalLikes,
  });
}

class LikeError extends LikeState {
  final String message;

  LikeError(this.message);
}
