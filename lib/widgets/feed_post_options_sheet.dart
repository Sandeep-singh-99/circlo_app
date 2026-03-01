import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showFeedPostOptions(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _OptionTile(
            icon: Icons.person_add_outlined,
            label: 'Follow',
            isDark: isDark,
          ),
          _OptionTile(
            icon: Icons.link_rounded,
            label: 'Copy link',
            isDark: isDark,
          ),
          _OptionTile(
            icon: Icons.share_outlined,
            label: 'Share to...',
            isDark: isDark,
          ),
          _OptionTile(
            icon: Icons.flag_outlined,
            label: 'Report',
            isDark: isDark,
            danger: true,
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool danger;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.isDark,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? Colors.redAccent
        : (isDark ? Colors.white : Colors.black87);
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}
