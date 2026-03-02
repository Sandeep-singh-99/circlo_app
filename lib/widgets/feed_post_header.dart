import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/features/post/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPostHeader extends StatelessWidget {
  final PostModel post;
  final String timeAgo;
  final VoidCallback onMoreTap;

  const FeedPostHeader({
    super.key,
    required this.post,
    required this.timeAgo,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    final author = post.user;
    final authorImageUrl = author?.imageUrl;
    final hasAvatar = authorImageUrl != null && authorImageUrl.isNotEmpty;
    final authorName = author?.name ?? 'Unknown';

    // Hide Follow button on own posts
    // The backend formatted response embeds userId inside the `user` object,
    // not as a top-level `userId` field, so compare via post.user?.id.
    final authState = context.read<AuthBloc>().state;
    final loggedInUserId = authState is AuthAuthenticated
        ? authState.user.id
        : null;
    final isOwnPost = loggedInUserId != null && loggedInUserId == post.user?.id;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        children: [
          // Avatar with gradient ring
          _buildAvatar(context, hasAvatar, authorImageUrl, authorName),
          const SizedBox(width: 10),

          // Name + timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authorName,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                if (timeAgo.isNotEmpty)
                  Text(
                    timeAgo,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: textSecondary.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),

          // Follow pill — hidden for your own posts
          if (!isOwnPost) ...[
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF6C63FF),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Follow',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6C63FF),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          // More button
          GestureDetector(
            onTap: onMoreTap,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.more_horiz_rounded,
                color: textPrimary,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    bool hasAvatar,
    String? url,
    String name,
  ) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFFBB86FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: 17,
          backgroundColor: const Color(0xFF2C2C2E),
          backgroundImage: hasAvatar ? NetworkImage(url!) : null,
          child: !hasAvatar
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
