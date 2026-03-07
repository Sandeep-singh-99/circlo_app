import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/follow_repository.dart';
import '../model/follow_user_model.dart';
import 'follow_event.dart';
import 'follow_state.dart';

class FollowBloc extends Bloc<FollowEvent, FollowState> {
  final FollowRepository _repository;
  String? _lastRequestedUserId;

  FollowBloc(this._repository) : super(FollowInitial()) {
    on<GetFollowersRequested>(_onGetFollowersRequested);
    on<GetFollowingRequested>(_onGetFollowingRequested);
    on<ToggleFollowRequested>(_onToggleFollowRequested);
    on<FollowResetRequested>((_, emit) {
      _lastRequestedUserId = null;
      emit(FollowInitial());
    });
  }

  Future<void> _onGetFollowersRequested(
    GetFollowersRequested event,
    Emitter<FollowState> emit,
  ) async {
    _lastRequestedUserId = event.userId;
    try {
      final currentState = state;
      int followingCount = 0;
      List<FollowUserModel> following = [];

      if (currentState is FollowLoaded) {
        followingCount = currentState.followingCount;
        following = currentState.following;
      } else {
        emit(FollowLoading());
      }

      final response = await _repository.getFollowers(event.userId);

      emit(
        FollowLoaded(
          followersCount: response.count,
          followingCount: followingCount,
          followers: response.users,
          following: following,
        ),
      );
    } catch (e) {
      emit(FollowError(e.toString()));
    }
  }

  Future<void> _onGetFollowingRequested(
    GetFollowingRequested event,
    Emitter<FollowState> emit,
  ) async {
    _lastRequestedUserId = event.userId;
    try {
      final currentState = state;
      int followersCount = 0;
      List<FollowUserModel> followers = [];

      if (currentState is FollowLoaded) {
        followersCount = currentState.followersCount;
        followers = currentState.followers;
      } else {
        emit(FollowLoading());
      }

      final response = await _repository.getFollowing(event.userId);

      emit(
        FollowLoaded(
          followersCount: followersCount,
          followingCount: response.count,
          followers: followers,
          following: response.users,
        ),
      );
    } catch (e) {
      emit(FollowError(e.toString()));
    }
  }

  Future<void> _onToggleFollowRequested(
    ToggleFollowRequested event,
    Emitter<FollowState> emit,
  ) async {
    try {
      await _repository.followUnfollowUser(event.targetUserId);

      if (_lastRequestedUserId != null) {
        add(GetFollowersRequested(_lastRequestedUserId!));
        add(GetFollowingRequested(_lastRequestedUserId!));
      }
    } catch (e) {
      emit(FollowError(e.toString()));
    }
  }
}
