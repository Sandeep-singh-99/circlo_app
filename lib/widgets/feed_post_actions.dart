import 'package:circlo_app/core/utils/app_toast.dart';
import 'package:circlo_app/features/bookmark/bloc/bookmark_bloc.dart';
import 'package:circlo_app/features/bookmark/bloc/bookmark_event.dart';
import 'package:circlo_app/features/bookmark/bloc/bookmark_state.dart';
import 'package:circlo_app/features/repost/bloc/repost_bloc.dart';
import 'package:circlo_app/features/repost/bloc/repost_event.dart';
import 'package:circlo_app/features/repost/bloc/repost_state.dart';
import 'package:circlo_app/widgets/animated_icon_widget.dart';
import 'package:circlo_app/widgets/comment_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _kGreen = Color(0xFF00C853);

class FeedPostActions extends StatefulWidget {
  final String postId;
  final bool isLiked;
  final bool isBookmarked;
  final bool isReposted;
  final int repostsCount;
  final VoidCallback onToggleLike;
  final Animation<double> heartScale;
  final ValueChanged<int>? onRepostCountChanged;

  const FeedPostActions({
    super.key,
    required this.postId,
    required this.isLiked,
    required this.isBookmarked,
    required this.isReposted,
    required this.repostsCount,
    required this.onToggleLike,
    required this.heartScale,
    this.onRepostCountChanged,
  });

  @override
  State<FeedPostActions> createState() => _FeedPostActionsState();
}

class _FeedPostActionsState extends State<FeedPostActions> {
  late bool _isBookmarked;
  late bool _isReposted;
  late int _repostsCount;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked;
    _isReposted = widget.isReposted;
    _repostsCount = widget.repostsCount;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          // ── Like ─────────────────────────────────────────────
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

          // ── Comment ───────────────────────────────────────────
          GestureDetector(
            onTap: () => CommentBottomSheet.show(context, widget.postId),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: textPrimary,
              size: 25,
            ),
          ),
          const SizedBox(width: 18),

          // ── Repost ────────────────────────────────────────────
          BlocConsumer<RepostBloc, RepostState>(
            listenWhen: (_, state) =>
                (state is RepostToggled && state.postId == widget.postId) ||
                state is RepostError,
            listener: (context, state) {
              if (state is RepostToggled && state.postId == widget.postId) {
                setState(() {
                  _isReposted = state.reposted;
                  _repostsCount = state.repostCount;
                });
                widget.onRepostCountChanged?.call(_repostsCount);
                AppToast.show(
                  context,
                  icon: Icon(
                    _isReposted ? Icons.repeat_rounded : Icons.repeat_outlined,
                    size: 18,
                    color: isDark ? Colors.black87 : Colors.white,
                  ),
                  message: _isReposted ? 'Reposted!' : 'Repost removed',
                );
              } else if (state is RepostError) {
                // Revert optimistic update
                setState(() {
                  _isReposted = !_isReposted;
                  _repostsCount += _isReposted ? 1 : -1;
                });
                AppToast.show(context, message: state.message, isError: true);
              }
            },
            builder: (context, state) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Optimistic update
                  setState(() {
                    _isReposted = !_isReposted;
                    _repostsCount += _isReposted ? 1 : -1;
                  });
                  context.read<RepostBloc>().add(ToggleRepost(widget.postId));
                },
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _isReposted
                            ? Icons.repeat_rounded
                            : Icons.repeat_outlined,
                        key: ValueKey(_isReposted),
                        color: _isReposted ? _kGreen : textPrimary,
                        size: 26,
                      ),
                    ),
                    if (_repostsCount > 0 || _isReposted) ...[
                      const SizedBox(width: 4),
                      Text(
                        _repostsCount.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isReposted ? _kGreen : textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          // ── Share ─────────────────────────────────────────────
          const SizedBox(width: 18),
          GestureDetector(
            onTap: () {},
            child: Transform.rotate(
              angle: -0.4,
              child: Icon(Icons.send_rounded, color: textPrimary, size: 24),
            ),
          ),

          const Spacer(),

          // ── Bookmark ──────────────────────────────────────────
          BlocConsumer<BookmarkBloc, BookmarkState>(
            listenWhen: (_, state) =>
                (state is BookmarkToggled && state.postId == widget.postId) ||
                state is BookmarkError,
            listener: (context, state) {
              if (state is BookmarkToggled) {
                setState(() => _isBookmarked = state.bookmarked);
                AppToast.show(
                  context,
                  icon: Icon(
                    state.bookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 18,
                    color: isDark ? Colors.black87 : Colors.white,
                  ),
                  message: state.message,
                );
              } else if (state is BookmarkError) {
                AppToast.show(context, message: state.message, isError: true);
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
