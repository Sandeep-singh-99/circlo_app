import 'package:circlo_app/features/bio/bloc/bio_event.dart';
import 'package:circlo_app/features/bio/bloc/bio_state.dart';
import 'package:circlo_app/features/bio/repository/bio_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BioBloc extends Bloc<BioEvent, BioState> {
  final BioRepository _bioRepository;

  BioBloc(this._bioRepository) : super(BioStateInitial()) {
    on<BioCreateRequested>(_onBioCreateRequested);
    on<BioUpdateRequested>(_onBioUpdateRequested);
  }

  Future<void> _onBioCreateRequested(
    BioCreateRequested event,
    Emitter<BioState> emit,
  ) async {
    emit(BioLoading());
    try {
      final bio = await _bioRepository.createBio(
        bio: event.bio,
        location: event.location,
        website: event.website,
      );
      emit(BioSuccess(bio));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to create bio';
      emit(BioFailure(message));
    } catch (e) {
      emit(BioFailure('An unexpected error occurred'));
    }
  }

  Future<void> _onBioUpdateRequested(
    BioUpdateRequested event,
    Emitter<BioState> emit,
  ) async {
    emit(BioLoading());
    try {
      final bio = await _bioRepository.updateBio(
        bio: event.bio,
        location: event.location,
        website: event.website,
      );
      emit(BioSuccess(bio));
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to update bio';
      emit(BioFailure(message));
    } catch (e) {
      emit(BioFailure('An unexpected error occurred'));
    }
  }
}
