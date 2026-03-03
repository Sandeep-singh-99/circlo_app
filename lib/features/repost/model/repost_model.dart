final class RepostModel {
  final bool reposted;
  final int repostCount;

  RepostModel({required this.reposted, required this.repostCount});

  factory RepostModel.fromJson(Map<String, dynamic> json) {
    // Backend returns { message: "Post reposted" | "Repost removed", repostCount: N }
    // Use case-insensitive check and also look for a direct 'reposted' bool field
    final msg = (json['message'] as String? ?? '').toLowerCase();
    final reposted =
        json['reposted'] as bool? ??
        msg.contains('repost') && !msg.contains('removed');
    return RepostModel(
      reposted: reposted,
      repostCount: json['repostCount'] as int? ?? 0,
    );
  }
}
