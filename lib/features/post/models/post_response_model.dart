import 'package:circlo_app/features/post/models/post_model.dart';

/// Flexible wrapper: handles both
///   • createPost  → { "post": { ...single post... } }
///   • getAllPosts  → { "posts": [ ...list... ] }
final class PostResponseModel {
  final PostModel? post;
  final List<PostModel> posts;
  final String? message;

  PostResponseModel({this.post, this.posts = const [], this.message});

  factory PostResponseModel.fromJson(Map<String, dynamic> json) {
    // Single-post response (create / getById)
    PostModel? singlePost;
    if (json['post'] != null && json['post'] is Map<String, dynamic>) {
      singlePost = PostModel.fromJson(json['post'] as Map<String, dynamic>);
    }

    // Multi-post response (getAll)
    List<PostModel> postList = [];
    if (json['posts'] != null && json['posts'] is List) {
      postList = (json['posts'] as List<dynamic>)
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return PostResponseModel(
      post: singlePost,
      posts: postList,
      message: json['message'] as String?,
    );
  }
}
