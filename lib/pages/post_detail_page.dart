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
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToName = null;
    });
    _commentController.clear();
    _focusNode.unfocus();
  }

  void _startEdit(CommentModel comment) {
    setState(() {
      _editingCommentId = comment.id;
      _replyingToCommentId = null;
      _replyingToName = null;
    });
    _commentController.text = comment.content;
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  void _submitComment() {
    final text = _commentController.text.trim();
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
    _commentController.clear();
    _focusNode.unfocus();
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
          style: GoogleFonts.inter(
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
                if (state is PostDetailLoading) return _buildLoading(isDark);
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
    final divider = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5EA);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeedPostCard(post: post, isDetail: true),

          Divider(height: 1, thickness: 0.5, color: divider),

          // Comments header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              'Comments',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          BlocBuilder<CommentBloc, CommentState>(
            builder: (context, state) {
              if (state is CommentLoading) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0095F6),
                    ),
                  ),
                );
              }

              if (state is CommentError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Failed to load comments',
                    style: GoogleFonts.inter(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                );
              }

              if (state is CommentLoaded) {
                if (state.comments.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 28,
                    ),
                    child: Text(
                      'No comments yet. Be the first!',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    final comment = state.comments[index];
                    final authState = context.read<AuthBloc>().state;
                    final me = authState is AuthAuthenticated
                        ? authState.user.id
                        : null;
                    final isOwner = me != null && comment.userId == me;

                    return _IGDetailCommentTile(
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

              return const SizedBox();
            },
          ),
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
            color: Color(0xFF0095F6),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading post...',
            style: GoogleFonts.inter(
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
              color: Colors.redAccent.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load post',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
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
                backgroundColor: const Color(0xFF0095F6),
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

// ──────────────────────────────────────────────────────────────────────────────
// Instagram-style comment tile for the post detail page
// ──────────────────────────────────────────────────────────────────────────────

class _IGDetailCommentTile extends StatefulWidget {
  final CommentModel comment;
  final String postId;
  final bool isDark;
  final bool isOwner;
  final void Function(CommentModel) onReply;
  final void Function(CommentModel) onEdit;
  final void Function(String) onDelete;
  final void Function(String) onLike;

  const _IGDetailCommentTile({
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
  State<_IGDetailCommentTile> createState() => _IGDetailCommentTileState();
}

class _IGDetailCommentTileState extends State<_IGDetailCommentTile> {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF3A3A3C),
            backgroundImage: hasImg ? NetworkImage(imgUrl) : null,
            child: !hasImg
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username + comment text on the same line
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$name ',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: c.content,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          color: widget.isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                // Meta row: time · likes · Reply · Edit · Delete
                Row(
                  children: [
                    Text(
                      _timeAgo(c.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    if (c.likeCount > 0) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${c.likeCount} ${c.likeCount == 1 ? 'like' : 'likes'}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    _TextBtn(
                      'Reply',
                      onTap: () => widget.onReply(c),
                      isDark: widget.isDark,
                    ),
                    if (widget.isOwner) ...[
                      const SizedBox(width: 12),
                      _TextBtn(
                        'Edit',
                        onTap: () => widget.onEdit(c),
                        isDark: widget.isDark,
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

                // "View X replies" expandable
                if (c.replyCount > 0) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _showReplies = !_showReplies),
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
                    padding: const EdgeInsets.only(top: 10),
                    child: _IGDetailReplies(
                      commentId: c.id,
                      isDark: widget.isDark,
                    ),
                  ),
              ],
            ),
          ),

          // Heart on far right
          const SizedBox(width: 8),
          _HeartButton(
            liked: c.isLikedByCurrentUser,
            isDark: widget.isDark,
            onTap: () => widget.onLike(c.id),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: widget.isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete comment?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: widget.isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'This cannot be undone.',
          style: GoogleFonts.inter(color: Colors.grey[500]),
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
// Inline replies section
// ──────────────────────────────────────────────────────────────────────────────

class _IGDetailReplies extends StatelessWidget {
  final String commentId;
  final bool isDark;

  const _IGDetailReplies({required this.commentId, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ReplyBloc(CommentRepository())
            ..add(ReplyGetRequested(commentId: commentId)),
      child: BlocBuilder<ReplyBloc, ReplyState>(
        builder: (context, state) {
          if (state is ReplyLoading) {
            return SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
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
              children: state.replies.map((r) {
                final author = r.user;
                final name = author?.name ?? 'Unknown';
                final imgUrl = author?.imageUrl;
                final hasImg = imgUrl != null && imgUrl.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: const Color(0xFF3A3A3C),
                        backgroundImage: hasImg ? NetworkImage(imgUrl) : null,
                        child: !hasImg
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
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
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: r.content,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _timeAgo(r.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey[500],
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
// Shared micro-widgets
// ──────────────────────────────────────────────────────────────────────────────

class _HeartButton extends StatelessWidget {
  final bool liked;
  final bool isDark;
  final VoidCallback onTap;

  const _HeartButton({
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
            color: liked ? Colors.redAccent : Colors.grey[500],
          ),
        ),
      ),
    );
  }
}

class _TextBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _TextBtn(this.label, {required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[isDark ? 500 : 600],
        ),
      ),
    );
  }
}
