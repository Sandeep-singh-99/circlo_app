import 'package:circlo_app/features/auth/models/auth_model.dart';

final class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String? createdAt;
  final String? updatedAt;
  final AuthModel? user;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      user: json['user'] != null
          ? AuthModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
