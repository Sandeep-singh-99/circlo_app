import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommentInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const CommentInputField({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: bottomPadding > 0 ? bottomPadding + 10 : 20,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[800],
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.poppins(color: textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a comment...',
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
    );
  }
}
