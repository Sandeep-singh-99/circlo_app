import 'package:circlo_app/features/auth/models/auth_model.dart';

final class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String? parentId;
  final int likeCount;
  final int replyCount;
  final bool isLikedByCurrentUser;
  final String? createdAt;
  final String? updatedAt;
  final AuthModel? user;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentId,
    this.likeCount = 0,
    this.replyCount = 0,
    this.isLikedByCurrentUser = false,
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
      parentId: json['parentId'] as String?,
      likeCount: (json['likeCount'] as int?) ?? 0,
      replyCount: (json['replyCount'] as int?) ?? 0,
      isLikedByCurrentUser: (json['isLikedByCurrentUser'] as bool?) ?? false,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      user: json['user'] != null
          ? AuthModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    String? parentId,
    int? likeCount,
    int? replyCount,
    bool? isLikedByCurrentUser,
    String? createdAt,
    String? updatedAt,
    AuthModel? user,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}
