final class LikeModel {
  final bool liked;
  final String message;

  LikeModel({required this.liked, required this.message});

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      liked: json['liked'] as bool,
      message: json['message'] as String,
    );
  }
}
