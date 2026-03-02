import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const SettingSection({super.key, required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final dividerColor = isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFF2F2F7);
    final labelColor = isDark ? Colors.grey[500]! : Colors.grey[500]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: labelColor,
            ),
          ),
        ),

        // Tiles card
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            border: Border(
              top: BorderSide(color: dividerColor, width: 0.5),
              bottom: BorderSide(color: dividerColor, width: 0.5),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i < tiles.length - 1)
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    indent: 66,
                    color: dividerColor,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
