import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/features/comment/bloc/comment_bloc.dart';
import 'package:circlo_app/features/comment/bloc/comment_event.dart';
import 'package:circlo_app/features/comment/bloc/comment_state.dart';
import 'package:circlo_app/features/comment/bloc/reply_bloc.dart';
import 'package:circlo_app/features/comment/bloc/reply_event.dart';
import 'package:circlo_app/features/comment/bloc/reply_state.dart';
import 'package:circlo_app/features/comment/model/comment_model.dart';
import 'package:circlo_app/features/comment/repository/comment_repository.dart';
import 'package:circlo_app/widgets/comment_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId;

  const CommentBottomSheet({super.key, required this.postId});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => CommentBottomSheet(postId: postId),
    );
  }
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _editingCommentId;
  String? _replyingToCommentId;
  String? _replyingToName;

  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(CommentGetRequested(postId: widget.postId));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startReply(CommentModel comment) {
    setState(() {
      _replyingToCommentId = comment.id;
      _replyingToName = comment.user?.name ?? 'user';
      _editingCommentId = null;
    });
    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToName = null;
    });
    _controller.clear();
    _focusNode.unfocus();
  }

  void _startEdit(CommentModel comment) {
    setState(() {
      _editingCommentId = comment.id;
      _replyingToCommentId = null;
      _replyingToName = null;
    });
    _controller.text = comment.content;
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_editingCommentId != null) {
      context.read<CommentBloc>().add(
        CommentUpdateRequested(id: _editingCommentId!, content: text),
      );
    } else {
      context.read<CommentBloc>().add(
        CommentAddRequested(
          postId: widget.postId,
          content: text,
          parentId: _replyingToCommentId,
        ),
      );
    }

    setState(() {
      _editingCommentId = null;
      _replyingToCommentId = null;
      _replyingToName = null;
    });
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final divider = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          _SheetHandle(isDark: isDark),
          _SheetHeader(isDark: isDark, divider: divider),

          // ── Comments list ─────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<CommentBloc, CommentState>(
              builder: (context, state) {
                if (state is CommentLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0095F6),
                    ),
                  );
                }

                if (state is CommentError) {
                  return Center(
                    child: Text(
                      'Failed to load comments',
                      style: GoogleFonts.inter(
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                if (state is CommentLoaded) {
                  if (state.comments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'No comments yet.',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Start the conversation.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.comments.length,
                    itemBuilder: (context, index) {
                      final comment = state.comments[index];
                      final authState = context.read<AuthBloc>().state;
                      final me = authState is AuthAuthenticated
                          ? authState.user.id
                          : null;
                      final isOwner = me != null && comment.userId == me;

                      return _IGCommentTile(
                        comment: comment,
                        postId: widget.postId,
                        isDark: isDark,
                        isOwner: isOwner,
                        onReply: _startReply,
                        onEdit: _startEdit,
                        onDelete: (id) => context.read<CommentBloc>().add(
                          CommentDeleteRequested(id: id),
                        ),
                        onLike: (id) => context.read<CommentBloc>().add(
                          CommentLikeToggleRequested(commentId: id),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // ── Input ─────────────────────────────────────────────────────
          CommentInputField(
            controller: _controller,
            focusNode: _focusNode,
            onSubmit: _submitComment,
            replyingToName: _editingCommentId != null ? null : _replyingToName,
            onCancelReply: _cancelReply,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Small composable header widgets
// ──────────────────────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  final bool isDark;
  const _SheetHandle({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF48484A) : const Color(0xFFC7C7CC),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final bool isDark;
  final Color divider;
  const _SheetHeader({required this.isDark, required this.divider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            'Comments',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        Divider(height: 1, thickness: 0.5, color: divider),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Instagram-style comment tile
// ──────────────────────────────────────────────────────────────────────────────

class _IGCommentTile extends StatefulWidget {
  final CommentModel comment;
  final String postId;
  final bool isDark;
  final bool isOwner;
  final void Function(CommentModel) onReply;
  final void Function(CommentModel) onEdit;
  final void Function(String) onDelete;
  final void Function(String) onLike;

  const _IGCommentTile({
    required this.comment,
    required this.postId,
    required this.isDark,
    required this.isOwner,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
  });

  @override
  State<_IGCommentTile> createState() => _IGCommentTileState();
}

class _IGCommentTileState extends State<_IGCommentTile> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.comment;
    final author = c.user;
    final name = author?.name ?? 'Unknown';
    final imgUrl = author?.imageUrl;
    final hasImg = imgUrl != null && imgUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main comment row ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              GestureDetector(
                onTap: widget.isOwner ? () => _showOptions(context) : null,
                child: _Avatar(
                  name: name,
                  imgUrl: imgUrl,
                  hasImg: hasImg,
                  radius: 16,
                ),
              ),
              const SizedBox(width: 12),

              // Content column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username + comment on same line (Instagram style)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$name ',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: c.content,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: widget.isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),

                    // time · like count? · Reply · (owner: Edit · Delete)
                    Row(
                      children: [
                        Text(
                          _timeAgo(c.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: widget.isDark
                                ? Colors.grey[500]
                                : Colors.grey[500],
                          ),
                        ),
                        if (c.likeCount > 0) ...[
                          const SizedBox(width: 12),
                          Text(
                            '${c.likeCount} ${c.likeCount == 1 ? 'like' : 'likes'}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                        const SizedBox(width: 12),
                        _InlineBtn(
                          label: 'Reply',
                          isDark: widget.isDark,
                          onTap: () => widget.onReply(c),
                        ),
                        if (widget.isOwner) ...[
                          const SizedBox(width: 12),
                          _InlineBtn(
                            label: 'Edit',
                            isDark: widget.isDark,
                            onTap: () => widget.onEdit(c),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _confirmDelete(context),
                            child: Text(
                              'Delete',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // "View X replies" button
                    if (c.replyCount > 0) ...[
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showReplies = !_showReplies),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 1,
                              color: widget.isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _showReplies
                                  ? 'Hide replies'
                                  : 'View ${c.replyCount} ${c.replyCount == 1 ? 'reply' : 'replies'}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Inline replies
                    if (_showReplies)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _IGRepliesSection(
                          commentId: c.id,
                          isDark: widget.isDark,
                        ),
                      ),
                  ],
                ),
              ),

              // Like button — far right
              const SizedBox(width: 8),
              _HeartBtn(
                liked: c.isLikedByCurrentUser,
                isDark: widget.isDark,
                onTap: () => widget.onLike(c.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final isDark = widget.isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF48484A)
                    : const Color(0xFFC7C7CC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.edit_outlined,
                color: isDark ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Edit',
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit(widget.comment);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              title: Text(
                'Delete',
                style: GoogleFonts.inter(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete(widget.comment.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final isDark = widget.isDark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete comment?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'This cannot be undone.',
          style: GoogleFonts.inter(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF0095F6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete(widget.comment.id);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Replies section
// ──────────────────────────────────────────────────────────────────────────────

class _IGRepliesSection extends StatelessWidget {
  final String commentId;
  final bool isDark;

  const _IGRepliesSection({required this.commentId, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ReplyBloc(CommentRepository())
            ..add(ReplyGetRequested(commentId: commentId)),
      child: BlocBuilder<ReplyBloc, ReplyState>(
        builder: (context, state) {
          if (state is ReplyLoading) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            );
          }

          if (state is ReplyError) {
            return Text(
              'Could not load replies',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.redAccent),
            );
          }

          if (state is ReplyLoaded) {
            if (state.replies.isEmpty) {
              return Text(
                'No replies yet',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              );
            }

            return Column(
              children: state.replies
                  .map((r) => _IGReplyTile(reply: r, isDark: isDark))
                  .toList(),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Single reply tile (same style as comment, slightly smaller)
// ──────────────────────────────────────────────────────────────────────────────

class _IGReplyTile extends StatelessWidget {
  final CommentModel reply;
  final bool isDark;

  const _IGReplyTile({required this.reply, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final author = reply.user;
    final name = author?.name ?? 'Unknown';
    final imgUrl = author?.imageUrl;
    final hasImg = imgUrl != null && imgUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(name: name, imgUrl: imgUrl, hasImg: hasImg, radius: 13),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$name ',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: reply.content,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeAgo(reply.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _HeartBtn(
            liked: reply.isLikedByCurrentUser,
            isDark: isDark,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return '${diff.inSeconds}s';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Reusable micro-widgets
// ──────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String? imgUrl;
  final bool hasImg;
  final double radius;

  const _Avatar({
    required this.name,
    required this.imgUrl,
    required this.hasImg,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF3A3A3C),
      backgroundImage: hasImg ? NetworkImage(imgUrl!) : null,
      child: !hasImg
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.75,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}

class _HeartBtn extends StatelessWidget {
  final bool liked;
  final bool isDark;
  final VoidCallback onTap;

  const _HeartBtn({
    required this.liked,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: Tween<double>(begin: 0.6, end: 1.0).animate(animation),
            child: child,
          ),
          child: Icon(
            liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(liked),
            size: 15,
            color: liked
                ? Colors.redAccent
                : (isDark ? Colors.grey[500] : Colors.grey[500]),
          ),
        ),
      ),
    );
  }
}

class _InlineBtn extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _InlineBtn({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
      ),
    );
  }
}
