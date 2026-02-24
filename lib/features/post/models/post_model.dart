import 'package:circlo_app/features/auth/models/auth_model.dart';

final class PostModel {
  final String? id;
  final String content;
  final String? imageUrl;
  final String? imageUrlID;
  final String? videoUrl;
  final String? videoUrlID;
  final String? createdAt;
  final String? updatedAt;
  final String? userId;
  // Embedded author — present in getAllPosts / getById (include: { user: true })
  final AuthModel? user;

  PostModel({
    this.id,
    required this.content,
    this.imageUrl,
    this.imageUrlID,
    this.videoUrl,
    this.videoUrlID,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.user,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String?,
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      imageUrlID: json['imageUrlID'] as String?,
      videoUrl: json['videoUrl'] as String?,
      videoUrlID: json['videoUrlID'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      userId: json['userId'] as String?,
      user: json['user'] != null
          ? AuthModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
