import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/features/bookmark/bloc/bookmark_bloc.dart';
import 'package:circlo_app/features/bookmark/bloc/bookmark_event.dart';
import 'package:circlo_app/features/bookmark/bloc/bookmark_state.dart';
import 'package:circlo_app/features/post/models/post_model.dart';
import 'package:circlo_app/router/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _isLiked = false;
  bool _isBookmarked = false;
  int _likeCount = 0;

  late AnimationController _heartController;
  late Animation<double> _heartScale;
  late AnimationController _heartOverlayController;
  late Animation<double> _heartOverlayScale;
  late Animation<double> _heartOverlayOpacity;

  @override
  void initState() {
    super.initState();
    _likeCount = (widget.post.id?.hashCode.abs() ?? 0) % 800 + 10;

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
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    _heartController.forward(from: 0);
  }

  void _onDoubleTap() {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _likeCount++;
      });
      _heartController.forward(from: 0);
    }
    _heartOverlayController.forward(from: 0);
    HapticFeedback.mediumImpact();
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
    final commentCount = (_likeCount * 0.3).round();

    return GestureDetector(
      onTap: _navigateToDetail,
      child: Container(
        color: bg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            _buildHeader(textPrimary, textSecondary, isDark),

            // ── Image ───────────────────────────────────────────────
            if (widget.post.imageUrl != null) _buildImage(isDark),

            // ── Actions ─────────────────────────────────────────────
            _buildActions(textPrimary),

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
              _buildCaption(textPrimary, textSecondary),

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
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(Color textPrimary, Color textSecondary, bool isDark) {
    final author = widget.post.user;
    final authorImageUrl = author?.imageUrl;
    final hasAvatar = authorImageUrl != null && authorImageUrl.isNotEmpty;
    final authorName = author?.name ?? 'Unknown';

    // Hide Follow button on own posts
    final authState = context.read<AuthBloc>().state;
    final loggedInUserId = authState is AuthAuthenticated
        ? authState.user.id
        : null;
    final isOwnPost =
        loggedInUserId != null && loggedInUserId == widget.post.userId;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        children: [
          // Avatar with gradient ring
          _buildAvatar(hasAvatar, authorImageUrl, authorName),
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
                if (_timeAgo(widget.post.createdAt).isNotEmpty)
                  Text(
                    _timeAgo(widget.post.createdAt),
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
            onTap: () => _showMoreOptions(context),
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

  Widget _buildAvatar(bool hasAvatar, String? url, String name) {
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

  // ── Image ───────────────────────────────────────────────────────────────

  Widget _buildImage(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image fills screen width, height auto from actual image dimensions
          SizedBox(
            width: screenWidth,
            child: Image.network(
              widget.post.imageUrl!,
              width: screenWidth,
              // Let the image render at its natural aspect ratio (up to 4:5 portrait max)
              fit: BoxFit.fitWidth,
              frameBuilder: (ctx, child, frame, wasSynchronous) {
                if (wasSynchronous || frame != null) return child;
                // Show shimmer placeholder while loading
                return _ImageShimmer(isDark: isDark, width: screenWidth);
              },
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return _ImageShimmer(isDark: isDark, width: screenWidth);
              },
              errorBuilder: (_, __, ___) => Container(
                width: screenWidth,
                height: 280,
                color: isDark
                    ? const Color(0xFF1C1C1E)
                    : const Color(0xFFF5F5F5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      color: Colors.grey[600],
                      size: 44,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Image unavailable',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Double-tap heart overlay
          AnimatedBuilder(
            animation: _heartOverlayController,
            builder: (_, __) => Opacity(
              opacity: _heartOverlayOpacity.value,
              child: Transform.scale(
                scale: _heartOverlayScale.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 90,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 24)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Widget _buildActions(Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          // Like
          _AnimatedIcon(
            animation: _heartScale,
            child: GestureDetector(
              onTap: _toggleLike,
              child: Icon(
                _isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _isLiked ? const Color(0xFFFF3B5C) : textPrimary,
                size: 27,
              ),
            ),
          ),
          const SizedBox(width: 18),

          // Comment
          GestureDetector(
            onTap: () {},
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
                (state is BookmarkToggled && state.postId == widget.post.id) ||
                state is BookmarkError,
            listener: (context, state) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  final postId = widget.post.id;
                  if (postId != null) {
                    context.read<BookmarkBloc>().add(ToggleBookmark(postId));
                  }
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

  // ── Caption ─────────────────────────────────────────────────────────────

  Widget _buildCaption(Color textPrimary, Color textSecondary) {
    final words = widget.post.content.trim().split(' ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: RichText(
        text: TextSpan(
          children: [
            // Bold author name
            TextSpan(
              text: '${widget.post.user?.name ?? ''} ',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            // Caption with hashtag highlights
            ...words.map((word) {
              final isHashtag = word.startsWith('#');
              return TextSpan(
                text: '$word ',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isHashtag
                      ? textPrimary
                      : textPrimary.withOpacity(0.88),
                  fontWeight: isHashtag ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }),
          ],
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── More options ─────────────────────────────────────────────────────────

  void _showMoreOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _optionTile(Icons.person_add_outlined, 'Follow', isDark),
            _optionTile(Icons.link_rounded, 'Copy link', isDark),
            _optionTile(Icons.share_outlined, 'Share to...', isDark),
            _optionTile(Icons.flag_outlined, 'Report', isDark, danger: true),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(
    IconData icon,
    String label,
    bool isDark, {
    bool danger = false,
  }) {
    final color = danger
        ? Colors.redAccent
        : (isDark ? Colors.white : Colors.black87);
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _AnimatedIcon extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _AnimatedIcon({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Transform.scale(scale: animation.value, child: child),
    );
  }
}

class _ImageShimmer extends StatefulWidget {
  final bool isDark;
  final double width;

  const _ImageShimmer({required this.isDark, required this.width});

  @override
  State<_ImageShimmer> createState() => _ImageShimmerState();
}

class _ImageShimmerState extends State<_ImageShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFEEEEEE);
    final highlight = widget.isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE0E0E0);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.width, // square shimmer until image loads
        color: Color.lerp(base, highlight, _anim.value),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 48,
            color: widget.isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
    );
  }
}
