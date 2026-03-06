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
import 'package:flutter_slidable/flutter_slidable.dart';
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
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToName = null;
    });
    _controller.clear();
    _focusNode.unfocus();
  }

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_editingCommentId != null) {
      context.read<CommentBloc>().add(
        CommentUpdateRequested(id: _editingCommentId!, content: text),
      );
      setState(() {
        _editingCommentId = null;
        _replyingToCommentId = null;
        _replyingToName = null;
      });
    } else {
      context.read<CommentBloc>().add(
        CommentAddRequested(
          postId: widget.postId,
          content: text,
          parentId: _replyingToCommentId,
        ),
      );
      setState(() {
        _replyingToCommentId = null;
        _replyingToName = null;
      });
    }
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Comments',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          Divider(color: Colors.grey.withOpacity(0.2)),

          // Comments List
          Expanded(
            child: BlocBuilder<CommentBloc, CommentState>(
              builder: (context, state) {
                if (state is CommentLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CommentError) {
                  return Center(
                    child: Text(
                      'Failed to load comments',
                      style: TextStyle(color: textSecondary),
                    ),
                  );
                } else if (state is CommentLoaded) {
                  final comments = state.comments;
                  if (comments.isEmpty) {
                    return Center(
                      child: Text(
                        'No comments yet. Be the first!',
                        style: GoogleFonts.poppins(color: textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return _CommentTile(
                        comment: comments[index],
                        postId: widget.postId,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onReply: _startReply,
                        onEdit: (comment) {
                          setState(() {
                            _editingCommentId = comment.id;
                            _replyingToCommentId = null;
                            _replyingToName = null;
                          });
                          _controller.text = comment.content;
                          _focusNode.requestFocus();
                        },
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // Input Field
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
// CommentTile — a single comment row with likes, replies, and edit/delete
// ──────────────────────────────────────────────────────────────────────────────
class _CommentTile extends StatefulWidget {
  final CommentModel comment;
  final String postId;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final void Function(CommentModel) onReply;
  final void Function(CommentModel) onEdit;

  const _CommentTile({
    required this.comment,
    required this.postId,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.onReply,
    required this.onEdit,
  });

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final author = comment.user;
    final hasAvatar =
        author?.imageUrl != null && (author?.imageUrl ?? '').isNotEmpty;
    final authorName = author?.name ?? 'Unknown';

    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : null;
    final isOwner = currentUserId != null && comment.userId == currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Comment row ──────────────────────────────────────────────────
          Slidable(
            key: ValueKey(comment.id),
            enabled: isOwner,
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.45,
              children: [
                SlidableAction(
                  onPressed: (_) => widget.onEdit(comment),
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                ),
                SlidableAction(
                  onPressed: (_) {
                    context.read<CommentBloc>().add(
                      CommentDeleteRequested(id: comment.id),
                    );
                  },
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: hasAvatar
                        ? NetworkImage(author!.imageUrl ?? '')
                        : null,
                    child: !hasAvatar
                        ? Text(
                            authorName.isNotEmpty
                                ? authorName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // Content + actions
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + time
                        Row(
                          children: [
                            Text(
                              authorName,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: widget.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _timeAgo(comment.createdAt),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: widget.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        // Comment text
                        Text(
                          comment.content,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: widget.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Action row: Like · Reply
                        Row(
                          children: [
                            // Like button
                            _LikeButton(
                              comment: comment,
                              isDark: widget.isDark,
                            ),
                            const SizedBox(width: 16),

                            // Reply button
                            GestureDetector(
                              onTap: () => widget.onReply(comment),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.reply_rounded,
                                    size: 14,
                                    color: widget.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Reply',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: widget.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // View replies chip
                            if (comment.replyCount > 0) ...[
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () => setState(
                                  () => _showReplies = !_showReplies,
                                ),
                                child: Text(
                                  _showReplies
                                      ? 'Hide replies'
                                      : '${comment.replyCount} ${comment.replyCount == 1 ? 'reply' : 'replies'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF6C63FF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Inline replies ────────────────────────────────────────────────
          if (_showReplies)
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: _RepliesSection(
                commentId: comment.id,
                postId: widget.postId,
                isDark: widget.isDark,
                textPrimary: widget.textPrimary,
                textSecondary: widget.textSecondary,
              ),
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'now';
      if (diff.inHours < 1) return '${diff.inMinutes}m';
      if (diff.inDays < 1) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Like button with optimistic animation
// ──────────────────────────────────────────────────────────────────────────────
class _LikeButton extends StatelessWidget {
  final CommentModel comment;
  final bool isDark;

  const _LikeButton({required this.comment, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final liked = comment.isLikedByCurrentUser;
    final count = comment.likeCount;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<CommentBloc>().add(
          CommentLikeToggleRequested(commentId: comment.id),
        );
      },
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(liked),
              size: 16,
              color: liked
                  ? Colors.redAccent
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: liked
                    ? Colors.redAccent
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Replies section — shown inline below a comment
// ──────────────────────────────────────────────────────────────────────────────
class _RepliesSection extends StatelessWidget {
  final String commentId;
  final String postId;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _RepliesSection({
    required this.commentId,
    required this.postId,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

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
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            );
          }

          if (state is ReplyError) {
            return Text(
              'Failed to load replies',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.redAccent),
            );
          }

          if (state is ReplyLoaded) {
            if (state.replies.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'No replies yet',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              );
            }

            return Column(
              children: state.replies.map((reply) {
                final author = reply.user;
                final hasAvatar =
                    author?.imageUrl != null &&
                    (author?.imageUrl ?? '').isNotEmpty;
                final authorName = author?.name ?? 'Unknown';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: hasAvatar
                            ? NetworkImage(author!.imageUrl ?? '')
                            : null,
                        child: !hasAvatar
                            ? Text(
                                authorName.isNotEmpty
                                    ? authorName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  authorName,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _timeAgo(reply.createdAt),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reply.content,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _timeAgo(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'now';
      if (diff.inHours < 1) return '${diff.inMinutes}m';
      if (diff.inDays < 1) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
