final class BioModel {
  final String id;
  final String userId;
  final String? bio;
  final String? location;
  final String? website;
  final String? createdAt;
  final String? updatedAt;

  BioModel({
    required this.id,
    required this.userId,
    this.bio,
    this.location,
    this.website,
    this.createdAt,
    this.updatedAt,
  });

  factory BioModel.fromJson(Map<String, dynamic> json) {
    return BioModel(
      id: (json['id'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
