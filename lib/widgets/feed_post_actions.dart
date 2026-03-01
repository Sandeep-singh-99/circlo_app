import 'package:circlo_app/features/bookmark/bloc/bookmark_bloc.dart';
import 'package:circlo_app/features/bookmark/bloc/bookmark_event.dart';
import 'package:circlo_app/features/bookmark/bloc/bookmark_state.dart';
import 'package:circlo_app/widgets/animated_icon_widget.dart';
import 'package:circlo_app/widgets/comment_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPostActions extends StatefulWidget {
  final String postId;
  final bool isLiked;
  final VoidCallback onToggleLike;
  final Animation<double> heartScale;

  const FeedPostActions({
    super.key,
    required this.postId,
    required this.isLiked,
    required this.onToggleLike,
    required this.heartScale,
  });

  @override
  State<FeedPostActions> createState() => _FeedPostActionsState();
}

class _FeedPostActionsState extends State<FeedPostActions> {
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          // Like
          AnimatedIconWidget(
            animation: widget.heartScale,
            child: GestureDetector(
              onTap: widget.onToggleLike,
              child: Icon(
                widget.isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: widget.isLiked ? const Color(0xFFFF3B5C) : textPrimary,
                size: 27,
              ),
            ),
          ),
          const SizedBox(width: 18),

          // Comment
          GestureDetector(
            onTap: () => CommentBottomSheet.show(context, widget.postId),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: textPrimary,
              size: 25,
            ),
          ),
          const SizedBox(width: 18),

          // Share
          GestureDetector(
            onTap: () {},
            child: Transform.rotate(
              angle: -0.4,
              child: Icon(Icons.send_rounded, color: textPrimary, size: 24),
            ),
          ),

          const Spacer(),

          // Bookmark
          BlocConsumer<BookmarkBloc, BookmarkState>(
            listenWhen: (_, state) =>
                (state is BookmarkToggled && state.postId == widget.postId) ||
                state is BookmarkError,
            listener: (context, state) {
              final bgColor = isDark ? Colors.white : Colors.black87;
              final textColor = isDark ? Colors.black87 : Colors.white;

              if (state is BookmarkToggled) {
                setState(() => _isBookmarked = state.bookmarked);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: GoogleFonts.poppins(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    backgroundColor: bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              } else if (state is BookmarkError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            builder: (context, state) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<BookmarkBloc>().add(
                    ToggleBookmark(widget.postId),
                  );
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    key: ValueKey(_isBookmarked),
                    color: textPrimary,
                    size: 27,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
