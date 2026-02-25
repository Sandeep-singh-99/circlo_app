import 'package:circlo_app/features/post/bloc/post_event.dart';
import 'package:circlo_app/features/post/bloc/post_state.dart';
import 'package:circlo_app/features/post/repository/post_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository _postRepository;

  PostBloc(this._postRepository) : super(PostStateInitial()) {
    on<PostCreateRequested>(_onPostCreateRequested);
    on<PostGetAllRequested>(_onPostGetAllRequested);
    on<PostDeleteRequested>(_onPostDeleteRequested);
    on<PostGetByIdRequested>(_onPostGetByIdRequested);
    on<PostGetOwnRequested>(_onPostGetOwnRequested);
  }

  Future<void> _onPostCreateRequested(
    PostCreateRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    try {
      await _postRepository.createPost(event.content, event.image);
      // Refresh the feed after successful creation
      final allPosts = await _postRepository.getPost();
      emit(PostSuccess(allPosts));
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
    } catch (e, st) {
      debugPrint('PostGetAllRequested error: $e\n$st');
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
    emit(PostDetailLoading());
    try {
      final response = await _postRepository.getPostById(event.id);
      final post = response.post;
      if (post == null) {
        emit(PostDetailFailure('Post not found'));
      } else {
        emit(PostDetailSuccess(post));
      }
    } catch (e) {
      emit(PostDetailFailure(e.toString()));
    }
  }

  Future<void> _onPostGetOwnRequested(
    PostGetOwnRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(PostLoading());
    try {
      final response = await _postRepository.getOwnPosts();
      emit(PostSuccess(response));
    } catch (e) {
      emit(PostFailure(e.toString()));
    }
  }
}
