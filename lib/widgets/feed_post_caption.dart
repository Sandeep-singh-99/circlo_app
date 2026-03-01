import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPostCaption extends StatelessWidget {
  final String authorName;
  final String content;

  const FeedPostCaption({
    super.key,
    required this.authorName,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final words = content.trim().split(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: RichText(
        text: TextSpan(
          children: [
            // Bold author name
            TextSpan(
              text: '$authorName ',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            // Caption with hashtag highlights
            ...words.map((word) {
              final isHashtag = word.startsWith('#');
              return TextSpan(
                text: '$word ',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isHashtag
                      ? textPrimary
                      : textPrimary.withOpacity(0.88),
                  fontWeight: isHashtag ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }),
          ],
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
