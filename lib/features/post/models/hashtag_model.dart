class Hashtag {
  final String id;
  final String name;
  final int usageCount;
  final String? createdAt;

  Hashtag({
    required this.id,
    required this.name,
    required this.usageCount,
    this.createdAt,
  });

  factory Hashtag.fromJson(Map<String, dynamic> json) {
    return Hashtag(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      usageCount: (json['usageCount'] as int?) ?? 0,
      createdAt: json['createdAt'] as String?,
    );
  }
}
