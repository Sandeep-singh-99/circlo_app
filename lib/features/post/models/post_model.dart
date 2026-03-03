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
  final bool isLiked;
  final bool isBookmarked;
  final bool isReposted;
  final int likesCount;
  final int commentsCount;
  final int bookmarksCount;
  final int repostsCount;

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
    this.isLiked = false,
    this.isBookmarked = false,
    this.isReposted = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.bookmarksCount = 0,
    this.repostsCount = 0,
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
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      isReposted: json['isReposted'] as bool? ?? false,
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      bookmarksCount: json['bookmarksCount'] as int? ?? 0,
      repostsCount: () {
        // json['_count']?['rePosts'] is unreliable on dynamic in Dart
        // Use explicit type check instead
        final count = json['_count'];
        if (count is Map) {
          final v = count['rePosts'];
          if (v is int) return v;
        }
        // Backend may also send repostsCount as a top-level field
        return json['repostsCount'] as int? ?? 0;
      }(),
    );
  }
}
