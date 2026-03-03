abstract class RepostEvent {}

class ToggleRepost extends RepostEvent {
  final String postId;
  ToggleRepost(this.postId);
}

class GetRepostsRequested extends RepostEvent {}
