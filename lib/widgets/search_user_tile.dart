import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const _kPurple = Color(0xFF6C63FF);
const _kViolet = Color(0xFFBB86FC);

const _kResultGradients = [
  [Color(0xFF6C63FF), Color(0xFFBB86FC)],
  [Color(0xFF0F3460), Color(0xFF533483)],
  [Color(0xFF4CA1AF), Color(0xFF2C3E50)],
  [Color(0xFFFF6B35), Color(0xFFFF9068)],
  [Color(0xFF1B998B), Color(0xFF2EC4B6)],
  [Color(0xFF9B59B6), Color(0xFF6C63FF)],
  [Color(0xFF2980B9), Color(0xFF6DD5FA)],
  [Color(0xFFFF3B5C), Color(0xFFFF6B35)],
];

// ─────────────────────────────────────────────────────────────
//  SEARCH RESULT USER TILE
// ─────────────────────────────────────────────────────────────

/// A single user result row (gradient avatar, name, followers, follow button).
class SearchUserTile extends StatelessWidget {
  final String username;
  final String followers;
  final int colorIndex;
  final bool verified;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;

  const SearchUserTile({
    super.key,
    required this.username,
    required this.followers,
    required this.colorIndex,
    this.verified = false,
    this.onTap,
    this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grad = _kResultGradients[colorIndex % _kResultGradients.length];

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: grad,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: grad[0].withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
      ),
      title: Row(
        children: [
          Text(
            username,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          if (verified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified_rounded, size: 14, color: _kPurple),
          ],
        ],
      ),
      subtitle: Text(
        '$followers followers',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
      trailing: _FollowButton(onTap: onFollow),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  RECENT SEARCH TILE
// ─────────────────────────────────────────────────────────────

/// A recent-search row with gradient avatar, name, and dismiss (×) button.
class SearchRecentTile extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const SearchRecentTile({
    super.key,
    required this.name,
    this.onTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              _kPurple.withValues(alpha: 0.7),
              _kViolet.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
      ),
      title: Text(
        name,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        'Recent search',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
      trailing: GestureDetector(
        onTap: onDismiss,
        child: Icon(
          Icons.close_rounded,
          size: 18,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  FOLLOW BUTTON
// ─────────────────────────────────────────────────────────────

class _FollowButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _FollowButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_kPurple, _kViolet]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _kPurple.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          'Follow',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
