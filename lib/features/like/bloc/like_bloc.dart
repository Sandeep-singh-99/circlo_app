import 'package:circlo_app/features/like/bloc/like_event.dart';
import 'package:circlo_app/features/like/bloc/like_state.dart';
import 'package:circlo_app/features/like/repository/like_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LikeBloc extends Bloc<LikeEvent, LikeState>{
  final LikeRepository _likeRepository;

  LikeBloc(this._likeRepository) : super(LikeInitial()){
    on<ToggleLike>(_onToggleLike);
  }

  Future<void> _onToggleLike(
    ToggleLike event,
    Emitter<LikeState> emit,
  ) async {
    emit(LikeLoading());
    try {
      final response = await _likeRepository.toggleLike(event.postId);
      emit(
        LikeToggled(
          postId: event.postId,
          liked: response.liked,
          message: response.message,
        ),
      );
    } catch (e) {
      emit(LikeError(e.toString()));
    }
  }
}