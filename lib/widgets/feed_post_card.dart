import 'package:circlo_app/features/post/models/post_model.dart';
import 'package:circlo_app/features/auth/models/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPostCard extends StatefulWidget {
  final PostModel post;
  final AuthModel user;

  const FeedPostCard({super.key, required this.post, required this.user});

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
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = TweenSequence(
      [
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
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
    final divider = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0F0);
    final commentCount = (_likeCount * 0.3).round();

    return Container(
      color: bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          _buildHeader(textPrimary, textSecondary),

          // ── Image ───────────────────────────────────────────────
          if (widget.post.imageUrl != null) _buildImage(),

          // ── Actions ─────────────────────────────────────────────
          _buildActions(textPrimary, textSecondary),

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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  'View all $commentCount comments',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: textSecondary,
                  ),
                ),
              ),
            ),

          // ── Time ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Text(
              _timeAgo(widget.post.createdAt).toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 10,
                letterSpacing: 0.4,
                color: textSecondary.withOpacity(0.6),
              ),
            ),
          ),

          const SizedBox(height: 4),
          Divider(height: 1, thickness: 1, color: divider),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textPrimary, Color textSecondary) {
    final hasAvatar =
        widget.user.imageUrl != null && widget.user.imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Avatar with story-style gradient ring
          Container(
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
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF2A2A2A),
                backgroundImage: hasAvatar
                    ? NetworkImage(widget.user.imageUrl!)
                    : null,
                child: !hasAvatar
                    ? Text(
                        widget.user.name.isNotEmpty
                            ? widget.user.name[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Username + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // More (⋮) button
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

  Widget _buildImage() {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              widget.post.imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: const Color(0xFF1A1A1A),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Container(
                height: 300,
                color: const Color(0xFF1A1A1A),
                child: Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    color: Colors.grey[700],
                    size: 48,
                  ),
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
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 90,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 20)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(Color textPrimary, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Row(
        children: [
          // Like
          AnimatedBuilder(
            animation: _heartScale,
            builder: (_, __) => Transform.scale(
              scale: _heartScale.value,
              child: GestureDetector(
                onTap: _toggleLike,
                child: Icon(
                  _isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isLiked ? const Color(0xFFFF3B5C) : textPrimary,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Comment
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Share
          GestureDetector(
            onTap: () {},
            child: Icon(Icons.send_rounded, color: textPrimary, size: 23),
          ),

          const Spacer(),

          // Bookmark
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isBookmarked = !_isBookmarked);
            },
            child: Icon(
              _isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: textPrimary,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaption(Color textPrimary, Color textSecondary) {
    final words = widget.post.content.split(' ');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: RichText(
        text: TextSpan(
          children: [
            // username bold
            TextSpan(
              text: '${widget.user.name} ',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            // caption with hashtag highlights
            ...words.map((word) {
              final isHashtag = word.startsWith('#');
              return TextSpan(
                text: '$word ',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isHashtag
                      ? const Color(0xFF6C63FF)
                      : textPrimary.withOpacity(0.9),
                  fontWeight: isHashtag ? FontWeight.w500 : FontWeight.normal,
                ),
              );
            }),
          ],
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

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
            _optionTile(Icons.person_add_outlined, 'Follow', Colors.white),
            _optionTile(Icons.link_rounded, 'Copy link', Colors.white),
            _optionTile(Icons.share_outlined, 'Share to...', Colors.white),
            _optionTile(Icons.block_rounded, 'Report', Colors.redAccent),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(IconData icon, String label, Color color) {
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
