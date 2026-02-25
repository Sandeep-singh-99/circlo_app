import 'package:circlo_app/features/post/bloc/post_bloc.dart';
import 'package:circlo_app/features/post/bloc/post_event.dart';
import 'package:circlo_app/features/post/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

const _kPurple = Color(0xFF6C63FF);

/// A 1:1 square cell component used inside the 3-column profile posts grid.
///
/// Renders the [post] thumbnail with:
///  - Press-down opacity animation
///  - Network image with loading placeholder & error fallback
///  - On tap → [ProfilePostDetailSheet] bottom sheet
class ProfileGridPostCard extends StatefulWidget {
  final PostModel post;

  const ProfileGridPostCard({super.key, required this.post});

  @override
  State<ProfileGridPostCard> createState() => _ProfileGridPostCardState();
}

class _ProfileGridPostCardState extends State<ProfileGridPostCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        _openDetail(context);
      },
      child: AnimatedOpacity(
        opacity: _pressed ? 0.70 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.network(
                widget.post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, e, _) => _fallback(),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: const Color(0xFF1A1A1A),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: _kPurple,
                        ),
                      ),
                    ),
                  );
                },
              )
            else
              _fallback(),

            // multi-image indicator (top-right corner icon)
            if (widget.post.videoUrl != null)
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.slow_motion_video_rounded,
                  size: 18,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
    color: const Color(0xFF1C1C1E),
    child: const Icon(Icons.image_outlined, color: Colors.grey, size: 28),
  );

  void _openDetail(BuildContext context) {
    // Capture the outer context so PostBloc is accessible inside the sheet
    final outerContext = context;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ProfilePostDetailSheet(post: widget.post, outerContext: outerContext),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PROFILE POST DETAIL SHEET
// ─────────────────────────────────────────────────────────────

/// A draggable bottom sheet that shows a single post's full image,
/// caption, action row, and date.  Opened when tapping a [ProfileGridPostCard].
class ProfilePostDetailSheet extends StatefulWidget {
  final PostModel post;

  /// The context from the widget tree above so [PostBloc] can be read.
  final BuildContext outerContext;

  const ProfilePostDetailSheet({
    super.key,
    required this.post,
    required this.outerContext,
  });

  @override
  State<ProfilePostDetailSheet> createState() => _ProfilePostDetailSheetState();
}

class _ProfilePostDetailSheetState extends State<ProfilePostDetailSheet> {
  bool _isLiked = false;
  bool _isBookmarked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = (widget.post.id?.hashCode.abs() ?? 0) % 800 + 10;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── Handle ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image ───────────────────────────────────────
                    if (widget.post.imageUrl != null)
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          widget.post.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, _) => Container(
                            color: const Color(0xFF1A1A1A),
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: Colors.grey,
                              size: 48,
                            ),
                          ),
                        ),
                      ),

                    // ── Like count ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                      child: Text(
                        '$_likeCount likes',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),

                    // ── Action row ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          // Like
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _isLiked = !_isLiked;
                                _likeCount += _isLiked ? 1 : -1;
                              });
                            },
                            child: Icon(
                              _isLiked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 26,
                              color: _isLiked
                                  ? const Color(0xFFFF3B5C)
                                  : textPrimary,
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Comment
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 24,
                            color: textPrimary,
                          ),
                          const SizedBox(width: 16),

                          // Share
                          Icon(
                            Icons.send_rounded,
                            size: 23,
                            color: textPrimary,
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
                              size: 26,
                              color: textPrimary,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Delete
                          GestureDetector(
                            onTap: () => _confirmDelete(context),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              size: 25,
                              color: Color(0xFFFF3B5C),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Caption ─────────────────────────────────────
                    if (widget.post.content.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
                        child: _buildCaption(
                          widget.post.content,
                          textPrimary,
                          textSecondary,
                        ),
                      ),

                    // ── Date ────────────────────────────────────────
                    if (widget.post.createdAt != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 2, 14, 24),
                        child: Text(
                          _formatDate(widget.post.createdAt!).toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            letterSpacing: 0.4,
                            color: textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a confirmation dialog; on confirm dispatches [PostDeleteRequested],
  /// closes the sheet, and refreshes the profile grid.
  Future<void> _confirmDelete(BuildContext sheetCtx) async {
    final confirmed = await showDialog<bool>(
      context: sheetCtx,
      builder: (dialogCtx) {
        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Post',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this post? This action cannot be undone.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFFF3B5C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && widget.post.id != null) {
      final bloc = widget.outerContext.read<PostBloc>();
      bloc.add(PostDeleteRequested(id: widget.post.id!));
      if (mounted) Navigator.of(sheetCtx).pop();
    }
  }

  Widget _buildCaption(String content, Color textPrimary, Color textSecondary) {
    return RichText(
      text: TextSpan(
        children: content.split(' ').map((word) {
          final isHashtag = word.startsWith('#');
          return TextSpan(
            text: '$word ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isHashtag ? _kPurple : textPrimary.withValues(alpha: 0.9),
              fontWeight: isHashtag ? FontWeight.w500 : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
      maxLines: 6,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
