import 'package:circlo_app/features/auth/models/auth_model.dart';
import 'package:circlo_app/features/post/models/post_model.dart';

final class PostResponseModel {
  final AuthModel user;
  final List<PostModel> posts;

  PostResponseModel({required this.user, required this.posts});

  factory PostResponseModel.fromJson(Map<String, dynamic> json) {
    return PostResponseModel(
      user: AuthModel.fromJson(json['user']),
      posts: (json['posts'] as List<dynamic>)
          .map((e) => PostModel.fromJson(e))
          .toList(),
    );
  }
}
