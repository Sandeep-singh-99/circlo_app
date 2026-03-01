import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/features/comment/bloc/comment_bloc.dart';
import 'package:circlo_app/features/comment/bloc/comment_event.dart';
import 'package:circlo_app/features/comment/bloc/comment_state.dart';
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
  String? _editingCommentId;

  @override
  void initState() {
    super.initState();
    context.read<CommentBloc>().add(CommentGetRequested(postId: widget.postId));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitComment() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      if (_editingCommentId != null) {
        context.read<CommentBloc>().add(
          CommentUpdateRequested(id: _editingCommentId!, content: text),
        );
        setState(() {
          _editingCommentId = null;
        });
      } else {
        context.read<CommentBloc>().add(
          CommentAddRequested(postId: widget.postId, content: text),
        );
      }
      _controller.clear();
      // Optimistically hide keyboard
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // 75% of screen height
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
                      final comment = comments[index];
                      final author = comment.user;
                      final hasAvatar =
                          author?.imageUrl != null &&
                          author!.imageUrl!.isNotEmpty;
                      final authorName = author?.name ?? 'Unknown';

                      // Check if current user owns this comment
                      final authState = context.read<AuthBloc>().state;
                      final currentUserId = authState is AuthAuthenticated
                          ? authState.user.id
                          : null;
                      final isOwner =
                          currentUserId != null &&
                          comment.userId == currentUserId;

                      return Slidable(
                        key: ValueKey(comment.id),
                        enabled: isOwner,
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.45,
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                setState(() {
                                  _editingCommentId = comment.id;
                                });
                                _controller.text = comment.content;
                                FocusScope.of(context).requestFocus();
                              },
                              backgroundColor: Colors.blueGrey.shade700,
                              foregroundColor: Colors.white,
                              icon: Icons.edit_rounded,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                context.read<CommentBloc>().add(
                                  CommentDeleteRequested(id: comment.id),
                                );
                              },
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              icon: Icons.delete_outline_rounded,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[800],
                                backgroundImage: hasAvatar
                                    ? NetworkImage(author.imageUrl ?? '')
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
                                            color: textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _timeAgo(comment.createdAt),
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      comment.content,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // Input Field
          CommentInputField(controller: _controller, onSubmit: _submitComment),
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
