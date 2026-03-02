import 'package:circlo_app/core/utils/app_toast.dart';
import 'package:circlo_app/features/like/bloc/like_bloc.dart';
import 'package:circlo_app/features/like/bloc/like_event.dart';
import 'package:circlo_app/features/like/bloc/like_state.dart';
import 'package:circlo_app/features/post/models/post_model.dart';
import 'package:circlo_app/router/route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:circlo_app/widgets/feed_post_actions.dart';
import 'package:circlo_app/widgets/feed_post_caption.dart';
import 'package:circlo_app/widgets/feed_post_header.dart';
import 'package:circlo_app/widgets/feed_post_image.dart';
import 'package:circlo_app/widgets/feed_post_options_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPostCard extends StatefulWidget {
  final PostModel post;

  const FeedPostCard({super.key, required this.post});

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard>
    with TickerProviderStateMixin {
  late bool _isLiked;
  late int _likeCount;

  late AnimationController _heartController;
  late Animation<double> _heartScale;
  late AnimationController _heartOverlayController;
  late Animation<double> _heartOverlayScale;
  late Animation<double> _heartOverlayOpacity;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likesCount;

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _heartScale = TweenSequence(
      [
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
      ],
    ).animate(CurvedAnimation(parent: _heartController, curve: Curves.easeOut));

    _heartOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartOverlayScale =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 40),
          TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
        ]).animate(
          CurvedAnimation(
            parent: _heartOverlayController,
            curve: Curves.easeOut,
          ),
        );

    _heartOverlayOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_heartOverlayController);
  }

  @override
  void dispose() {
    _heartController.dispose();
    _heartOverlayController.dispose();
    super.dispose();
  }

  void _navigateToDetail() {
    final id = widget.post.id;
    if (id != null && id.isNotEmpty) {
      context.push('$postDetail/$id');
    }
  }

  void _toggleLike() {
    HapticFeedback.lightImpact();
    // Optimistic update
    final wasLiked = _isLiked;
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    _heartController.forward(from: 0);

    final postId = widget.post.id;
    if (postId != null) {
      context.read<LikeBloc>().add(ToggleLike(postId));
    } else {
      // Revert if no postId
      setState(() {
        _isLiked = wasLiked;
        _likeCount += wasLiked ? 1 : -1;
      });
    }
  }

  void _onDoubleTap() {
    _heartOverlayController.forward(from: 0);
    HapticFeedback.mediumImpact();
    if (!_isLiked) {
      // Optimistic update
      setState(() {
        _isLiked = true;
        _likeCount++;
      });
      _heartController.forward(from: 0);

      final postId = widget.post.id;
      if (postId != null) {
        context.read<LikeBloc>().add(ToggleLike(postId));
      }
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final divider = isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF0F0F0);
    final commentCount = widget.post.commentsCount;

    return BlocListener<LikeBloc, LikeState>(
      listenWhen: (_, state) =>
          (state is LikeToggled && state.postId == widget.post.id) ||
          state is LikeError,
      listener: (context, state) {
        if (state is LikeToggled && state.postId == widget.post.id) {
          // Sync with server truth
          if (mounted) {
            setState(() {
              _isLiked = state.liked;
              _likeCount = state.totalLikes;
            });
            AppToast.show(
              context,
              icon: Icon(
                state.liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 18,
                color: state.liked
                    ? const Color(0xFFFF3B5C)
                    : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.black87
                          : Colors.white),
              ),
              message: state.liked ? 'Liked!' : 'Unliked',
              duration: const Duration(milliseconds: 1500),
            );
          }
        } else if (state is LikeError) {
          // Revert optimistic update on failure
          if (mounted) {
            setState(() {
              _isLiked = !_isLiked;
              _likeCount += _isLiked ? 1 : -1;
            });
            AppToast.show(context, message: state.message, isError: true);
          }
        }
      },
      child: GestureDetector(
        onTap: _navigateToDetail,
        child: Container(
          color: bg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
              FeedPostHeader(
                post: widget.post,
                timeAgo: _timeAgo(widget.post.createdAt),
                onMoreTap: () => showFeedPostOptions(context),
              ),

              // ── Image ───────────────────────────────────────────────
              if (widget.post.imageUrl != null)
                FeedPostImage(
                  imageUrl: widget.post.imageUrl!,
                  onDoubleTap: _onDoubleTap,
                  heartOverlayController: _heartOverlayController,
                  heartOverlayScale: _heartOverlayScale,
                  heartOverlayOpacity: _heartOverlayOpacity,
                ),

              // ── Actions ─────────────────────────────────────────────
              if (widget.post.id != null)
                FeedPostActions(
                  postId: widget.post.id!,
                  isLiked: _isLiked,
                  isBookmarked: widget.post.isBookmarked,
                  onToggleLike: _toggleLike,
                  heartScale: _heartScale,
                ),

              // ── Like count ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '${_formatCount(_likeCount)} likes',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // ── Caption ─────────────────────────────────────────────
              if (widget.post.content.isNotEmpty)
                FeedPostCaption(
                  authorName: widget.post.user?.name ?? 'Unknown',
                  content: widget.post.content,
                ),

              // ── Comment hint ────────────────────────────────────────
              if (commentCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 2,
                  ),
                  child: Text(
                    'View all $commentCount comments',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: textSecondary,
                    ),
                  ),
                ),

              // ── Time ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(
                  left: 14,
                  right: 14,
                  top: 4,
                  bottom: 10,
                ),
                child: Text(
                  _timeAgo(widget.post.createdAt).toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    letterSpacing: 0.5,
                    color: textSecondary.withOpacity(0.55),
                  ),
                ),
              ),

              Divider(height: 1, thickness: 0.5, color: divider),
            ],
          ),
        ),
      ),
    );
  }
}
