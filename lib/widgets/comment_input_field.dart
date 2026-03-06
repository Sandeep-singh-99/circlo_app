import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final FocusNode? focusNode;

  /// When non-null, prefills "@name " to show reply context
  final String? replyingToName;

  /// Called when the user taps the ✕ to cancel a reply
  final VoidCallback? onCancelReply;

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
    final textSecondary = isDark ? Colors.grey[500]! : Colors.grey[500]!;
    final fieldBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0F0F0);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "Replying to @name" bar
          if (replyingToName != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              color: isDark ? const Color(0xFF252528) : const Color(0xFFF7F7F7),
              child: Row(
                children: [
                  Text(
                    'Replying to ',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                  Text(
                    replyingToName!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textSecondary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onCancelReply,
                    child: Icon(
                      Icons.close_rounded,
                      size: 15,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // Input row
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: bottomPadding > 0 ? 8 : 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isDark
                        ? const Color(0xFF3A3A3C)
                        : const Color(0xFFD1D1D6),
                    child: Icon(
                      Icons.person,
                      color: isDark
                          ? const Color(0xFF8E8E93)
                          : const Color(0xFF8E8E93),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: fieldBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: GoogleFonts.inter(
                          color: textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: replyingToName != null
                              ? 'Add a reply...'
                              : 'Add a comment...',
                          hintStyle: GoogleFonts.inter(
                            color: textSecondary,
                            fontSize: 14,
                          ),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: 4,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onSubmit,
                    child: Text(
                      'Post',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF0095F6),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
