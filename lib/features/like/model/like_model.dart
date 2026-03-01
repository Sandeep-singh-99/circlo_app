final class LikeModel {
  final bool liked;
  final int totalLikes;

  LikeModel({required this.liked, required this.totalLikes});

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      liked: json['liked'] as bool,
      totalLikes: json['totalLikes'] as int,
    );
  }
}
