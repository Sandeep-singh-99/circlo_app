import 'package:circlo_app/features/auth/models/auth_model.dart';
import 'package:circlo_app/features/post/models/post_hashtag_model.dart';

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
  final AuthModel? user;
  final List<PostHashtag> hashtags;
  final bool likedByMe;
  final int totalLikes;

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
    this.hashtags = const [],
    this.likedByMe = false,
    this.totalLikes = 0,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String?,
      content: (json['content'] as String?) ?? '',
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
      hashtags: json['hashtags'] != null
          ? (json['hashtags'] as List<dynamic>)
                .map((e) => PostHashtag.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      likedByMe: json['likedByMe'] as bool? ?? false,
      totalLikes: json['totalLikes'] as int? ?? 0,
    );
  }
}
