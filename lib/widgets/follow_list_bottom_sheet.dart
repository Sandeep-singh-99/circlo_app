import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/features/follow/bloc/follow_bloc.dart';
import 'package:circlo_app/features/follow/bloc/follow_event.dart';
import 'package:circlo_app/features/follow/bloc/follow_state.dart';
import 'package:circlo_app/features/follow/model/follow_user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

enum FollowListType { followers, following }

class FollowListBottomSheet extends StatelessWidget {
  final FollowListType type;

  const FollowListBottomSheet({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final divider = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5EA);

    final title = type == FollowListType.followers ? 'Followers' : 'Following';

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF555555) : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: divider),

          // List
          Expanded(
            child: BlocBuilder<FollowBloc, FollowState>(
              builder: (context, state) {
                if (state is FollowLoading || state is FollowInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0095F6),
                    ),
                  );
                }

                if (state is FollowError) {
                  return Center(
                    child: Text(
                      'Failed to load $title',
                      style: GoogleFonts.inter(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  );
                }

                if (state is FollowLoaded) {
                  final list = type == FollowListType.followers
                      ? state.followers
                      : state.following;

                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'No $title yet.',
                        style: GoogleFonts.inter(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final user = list[index];
                      // Check if the current user is in the "following" list
                      // to determine if we should show "Following" or "Follow"
                      // Since FollowLoaded has state.following, we can check if it contains this user's ID
                      final isFollowing = state.following.any(
                        (f) => f.id == user.id,
                      );

                      final authState = context.read<AuthBloc>().state;
                      final isMe =
                          authState is AuthAuthenticated &&
                          authState.user.id == user.id;

                      return _UserListTile(
                        user: user,
                        isFollowing: isFollowing,
                        isMe: isMe,
                        isDark: isDark,
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  final FollowUserModel user;
  final bool isFollowing;
  final bool isMe;
  final bool isDark;

  const _UserListTile({
    required this.user,
    required this.isFollowing,
    required this.isMe,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400] : Colors.grey[600];
    final hasImg = user.imageUrl != null && user.imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF3A3A3C),
            backgroundImage: hasImg ? NetworkImage(user.imageUrl!) : null,
            child: !hasImg
                ? Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.email,
                  style: GoogleFonts.inter(fontSize: 13, color: textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isMe)
            GestureDetector(
              onTap: () {
                context.read<FollowBloc>().add(ToggleFollowRequested(user.id));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isFollowing
                      ? (isDark
                            ? const Color(0xFF363636)
                            : const Color(0xFFEFEFEF))
                      : const Color(0xFF0095F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isFollowing
                        ? (isDark ? Colors.white : Colors.black87)
                        : Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
