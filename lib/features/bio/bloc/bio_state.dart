import 'package:circlo_app/features/bio/models/bio_model.dart';

abstract class BioState {}

class BioStateInitial extends BioState {}

class BioLoading extends BioState {}

class BioSuccess extends BioState {
  final BioModel bio;

  BioSuccess(this.bio);
}

class BioFailure extends BioState {
  final String message;

  BioFailure(this.message);
}
