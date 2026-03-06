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
import 'package:circlo_app/features/post/bloc/post_bloc.dart';
import 'package:circlo_app/features/post/bloc/post_event.dart';
import 'package:circlo_app/features/post/bloc/post_state.dart';
import 'package:circlo_app/features/post/models/post_model.dart';
import 'package:circlo_app/widgets/comment_input_field.dart';
import 'package:circlo_app/widgets/feed_post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _editingCommentId;
  String? _replyingToCommentId;
  String? _replyingToName;

  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(PostGetByIdRequested(id: widget.postId));
    context.read<CommentBloc>().add(CommentGetRequested(postId: widget.postId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startReply(CommentModel comment) {
    setState(() {
      _replyingToCommentId = comment.id;
      _replyingToName = comment.user?.name ?? 'user';
      _editingCommentId = null;
    });
    _commentController.clear();
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToName = null;
    });
    _commentController.clear();
    _focusNode.unfocus();
  }

  void _submitComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty) {
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
      _commentController.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Post',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<PostBloc, PostState>(
              buildWhen: (prev, curr) =>
                  curr is PostDetailLoading ||
                  curr is PostDetailSuccess ||
                  curr is PostDetailFailure,
              builder: (context, state) {
                if (state is PostDetailLoading) {
                  return _buildLoading(isDark);
                }

                if (state is PostDetailSuccess) {
                  return _buildContent(state.post, isDark);
                }

                if (state is PostDetailFailure) {
                  return _buildError(state.message, isDark);
                }

                return _buildLoading(isDark);
              },
            ),
          ),
          CommentInputField(
            controller: _commentController,
            focusNode: _focusNode,
            onSubmit: _submitComment,
            replyingToName: _editingCommentId != null ? null : _replyingToName,
            onCancelReply: _cancelReply,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(PostModel post, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reuse FeedPostCard for consistent look
          FeedPostCard(post: post),

          // ── Comments section ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Comments',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              if (state is CommentLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is CommentError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Failed to load comments: ${state.message}',
                      style: TextStyle(
                        color: isDark ? Colors.red[300] : Colors.red,
                      ),
                    ),
                  ),
                );
              } else if (state is CommentLoaded) {
                final comments = state.comments;
                if (comments.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Text(
                      'No comments yet. Be the first to comment!',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return _DetailCommentTile(
                      comment: comments[index],
                      postId: widget.postId,
                      isDark: isDark,
                      onReply: _startReply,
                      onEdit: (comment) {
                        setState(() {
                          _editingCommentId = comment.id;
                          _replyingToCommentId = null;
                          _replyingToName = null;
                        });
                        _commentController.text = comment.content;
                        _focusNode.requestFocus();
                      },
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF6C63FF),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading post...',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.redAccent.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load post',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<PostBloc>().add(
                PostGetByIdRequested(id: widget.postId),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DetailCommentTile — used in the PostDetailPage inline comment list
// ─────────────────────────────────────────────────────────────────────────────
class _DetailCommentTile extends StatefulWidget {
  final CommentModel comment;
  final String postId;
  final bool isDark;
  final void Function(CommentModel) onReply;
  final void Function(CommentModel) onEdit;

  const _DetailCommentTile({
    required this.comment,
    required this.postId,
    required this.isDark,
    required this.onReply,
    required this.onEdit,
  });

  @override
  State<_DetailCommentTile> createState() => _DetailCommentTileState();
}

class _DetailCommentTileState extends State<_DetailCommentTile> {
  bool _showReplies = false;

  Color get _textPrimary => widget.isDark ? Colors.white : Colors.black87;
  Color get _textSecondary =>
      widget.isDark ? Colors.grey[400]! : Colors.grey[600]!;

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
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: hasAvatar
                        ? NetworkImage(author?.imageUrl ?? '')
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
                                fontSize: 13,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _timeAgo(comment.createdAt),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          comment.content,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Action row
                        Row(
                          children: [
                            _DetailLikeButton(
                              comment: comment,
                              isDark: widget.isDark,
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => widget.onReply(comment),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.reply_rounded,
                                    size: 14,
                                    color: _textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Reply',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

          // Inline replies
          if (_showReplies)
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: _DetailRepliesSection(
                commentId: comment.id,
                isDark: widget.isDark,
                textPrimary: _textPrimary,
                textSecondary: _textSecondary,
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

class _DetailLikeButton extends StatelessWidget {
  final CommentModel comment;
  final bool isDark;

  const _DetailLikeButton({required this.comment, required this.isDark});

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

class _DetailRepliesSection extends StatelessWidget {
  final String commentId;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _DetailRepliesSection({
    required this.commentId,
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
                height: 18,
                width: 18,
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
                            ? NetworkImage(author?.imageUrl ?? '')
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
