import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A single stat column showing a numeric value and a text label.
///
/// Example usage:
/// ```dart
/// ProfileStatColumn(value: '128', label: 'Posts', onTap: () {})
/// ```
class ProfileStatColumn extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;

  const ProfileStatColumn({
    super.key,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Helper to format large numbers: 1200 → "1.2K", 1200000 → "1.2M"
String formatStatCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}
