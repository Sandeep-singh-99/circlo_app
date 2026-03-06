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
