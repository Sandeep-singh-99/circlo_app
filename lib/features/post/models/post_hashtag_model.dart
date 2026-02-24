import 'package:circlo_app/features/post/models/hashtag_model.dart';

class PostHashtag {
  final String postId;
  final String hashtagId;
  final Hashtag hashtag;

  PostHashtag({
    required this.postId,
    required this.hashtagId,
    required this.hashtag,
  });

  factory PostHashtag.fromJson(Map<String, dynamic> json) {
    return PostHashtag(
      postId: (json['postId'] as String?) ?? '',
      hashtagId: (json['hashtagId'] as String?) ?? '',
      hashtag: Hashtag.fromJson(json['hashtag'] as Map<String, dynamic>),
    );
  }
}
