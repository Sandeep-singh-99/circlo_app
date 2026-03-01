import 'package:circlo_app/features/comment/bloc/comment_bloc.dart';
import 'package:circlo_app/features/comment/bloc/comment_event.dart';
import 'package:circlo_app/features/comment/model/comment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

void showCommentOptions(
  BuildContext context,
  CommentModel comment,
  TextEditingController commentController, {
  required VoidCallback onEdit,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
  final textPrimary = isDark ? Colors.white : Colors.black87;

  showModalBottomSheet(
    context: context,
    backgroundColor: bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit_rounded, color: textPrimary),
              title: Text(
                'Edit',
                style: GoogleFonts.poppins(
                  color: textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                commentController.text = comment.content;
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
              title: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                context.read<CommentBloc>().add(
                  CommentDeleteRequested(id: comment.id),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
