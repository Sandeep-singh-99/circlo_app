abstract class LikeEvent {}

class ToggleLike extends LikeEvent {
  final String postId;

  ToggleLike(this.postId);
}
