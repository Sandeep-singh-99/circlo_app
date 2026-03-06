import '../model/follow_user_model.dart';

abstract class FollowState {}

class FollowInitial extends FollowState {}

class FollowLoading extends FollowState {}

class FollowLoaded extends FollowState {
  final int followersCount;
  final int followingCount;
  final List<FollowUserModel> followers;
  final List<FollowUserModel> following;

  FollowLoaded({
    required this.followersCount,
    required this.followingCount,
    required this.followers,
    required this.following,
  });

  FollowLoaded copyWith({
    int? followersCount,
    int? followingCount,
    List<FollowUserModel>? followers,
    List<FollowUserModel>? following,
  }) {
    return FollowLoaded(
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}

class FollowError extends FollowState {
  final String message;
  FollowError(this.message);
}
