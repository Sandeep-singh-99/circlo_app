class FollowUserModel {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;

  FollowUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
  });

  factory FollowUserModel.fromJson(Map<String, dynamic> json) {
    return FollowUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class FollowResponseModel {
  final int count;
  final List<FollowUserModel> users;

  FollowResponseModel({required this.count, required this.users});

  factory FollowResponseModel.fromJson(
    Map<String, dynamic> json,
    String listKey,
  ) {
    return FollowResponseModel(
      count: json['count'] as int? ?? 0,
      users:
          (json[listKey] as List<dynamic>?)
              ?.map((e) => FollowUserModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
