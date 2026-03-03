import 'package:circlo_app/features/repost/bloc/repost_event.dart';
import 'package:circlo_app/features/repost/bloc/repost_state.dart';
import 'package:circlo_app/features/repost/repository/repost_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RepostBloc extends Bloc<RepostEvent, RepostState> {
  final RepostRepository _repostRepository;

  RepostBloc(this._repostRepository) : super(RepostInitial()) {
    on<ToggleRepost>(_onToggleRepost);
    on<GetRepostsRequested>(_onGetReposts);
  }

  Future<void> _onToggleRepost(
    ToggleRepost event,
    Emitter<RepostState> emit,
  ) async {
    try {
      final result = await _repostRepository.toggleRepost(event.postId);
      emit(
        RepostToggled(
          postId: event.postId,
          reposted: result.reposted,
          repostCount: result.repostCount,
        ),
      );
    } catch (e) {
      emit(RepostError(e.toString()));
    }
  }

  Future<void> _onGetReposts(
    GetRepostsRequested event,
    Emitter<RepostState> emit,
  ) async {
    emit(RepostLoading());
    try {
      final posts = await _repostRepository.getReposts();
      emit(RepostsLoaded(posts));
    } catch (e) {
      emit(RepostError(e.toString()));
    }
  }
}
