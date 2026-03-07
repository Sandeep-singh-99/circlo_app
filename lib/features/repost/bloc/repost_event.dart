abstract class RepostEvent {}

class ToggleRepost extends RepostEvent {
  final String postId;
  ToggleRepost(this.postId);
}

class GetRepostsRequested extends RepostEvent {}

/// Fired on logout — resets repost state so the previous user's reposts
/// are not visible after an account switch.
class RepostResetRequested extends RepostEvent {}
