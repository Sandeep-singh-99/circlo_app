import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  /// When non-null, displays a "Replying to @name" chip above the input
  final String? replyingToName;

  /// Called when the user taps the ✕ on the reply banner to cancel the reply
  final VoidCallback? onCancelReply;

  /// Optional focus node; when provided, the internal TextField uses it
  final FocusNode? focusNode;

  const CommentInputField({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.focusNode,
    this.replyingToName,
    this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Replying to @name" banner
          if (replyingToName != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: isDark ? const Color(0xFF2A2A2E) : const Color(0xFFF0F0F0),
              child: Row(
                children: [
                  Icon(
                    Icons.reply_rounded,
                    size: 14,
                    color: const Color(0xFF6C63FF),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Replying to @$replyingToName',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6C63FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCancelReply,
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Input row
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: bottomPadding > 0 ? bottomPadding + 10 : 20,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: GoogleFonts.poppins(
                      color: textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: replyingToName != null
                          ? 'Add a reply...'
                          : 'Add a comment...',
                      hintStyle: GoogleFonts.poppins(color: textSecondary),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    maxLines: null,
                  ),
                ),
                GestureDetector(
                  onTap: onSubmit,
                  child: Text(
                    'Post',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6C63FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
