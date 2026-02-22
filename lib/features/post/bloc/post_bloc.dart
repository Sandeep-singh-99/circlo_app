import 'package:circlo_app/features/post/bloc/post_event.dart';
import 'package:circlo_app/features/post/bloc/post_state.dart';
import 'package:circlo_app/features/post/repository/post_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository _postRepository;

  PostBloc(this._postRepository): super(PostStateInitial()) {
    on<PostCreateRequested>(_onPostCreateRequested);
    on<PostGetAllRequested>(_onPostGetAllRequested);
    on<PostDeleteRequested>(_onPostDeleteRequested);
    on<PostGetByIdRequested>(_onPostGetByIdRequested);
  }

  Future<void> _onPostCreateRequested(
    PostCreateRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    try {
      final response = await _postRepository.createPost(event.content, event.image);
      emit(PostSuccess(response));
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }

  Future<void> _onPostGetAllRequested(
    PostGetAllRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    try {
      final response = await _postRepository.getPost();
      emit(PostSuccess(response));
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }

  Future<void> _onPostDeleteRequested(
    PostDeleteRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    try {
      final response = await _postRepository.deletePost(event.id);
      emit(PostSuccess(response));
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }

  Future<void> _onPostGetByIdRequested(
    PostGetByIdRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    try {
      final response = await _postRepository.getPostById(event.id);
      emit(PostSuccess(response));
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }
}
