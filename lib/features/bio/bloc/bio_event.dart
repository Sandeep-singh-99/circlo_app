abstract class BioEvent {}

class BioGetRequested extends BioEvent {}

class BioCreateRequested extends BioEvent {
  final String? bio;
  final String? location;
  final String? website;

  BioCreateRequested({this.bio, this.location, this.website});
}

class BioUpdateRequested extends BioEvent {
  final String? bio;
  final String? location;
  final String? website;

  BioUpdateRequested({this.bio, this.location, this.website});
}
