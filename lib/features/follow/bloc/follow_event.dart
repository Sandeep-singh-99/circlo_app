abstract class FollowEvent {}

class GetFollowersRequested extends FollowEvent {
  final String userId;
  GetFollowersRequested(this.userId);
}

class GetFollowingRequested extends FollowEvent {
  final String userId;
  GetFollowingRequested(this.userId);
}

class ToggleFollowRequested extends FollowEvent {
  final String targetUserId;
  ToggleFollowRequested(this.targetUserId);
}

/// Fired on logout — resets follow state so the previous user's
/// followers/following are not visible after an account switch.
class FollowResetRequested extends FollowEvent {}
