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
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      imageUrlID: json['imageUrlID'],
      videoUrl: json['videoUrl'],
      videoUrlID: json['videoUrlID'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      userId: json['userId'],
    );
  }
}
