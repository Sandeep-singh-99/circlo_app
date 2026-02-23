import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A circular avatar surrounded by a purple → violet → coral gradient ring.
///
/// Used in:
///  - Profile page header
///  - Story highlight bubbles
///  - Feed post card headers
///
/// Pass [radius] to control avatar size.
/// Pass [ringPadding] / [gapPadding] to control ring thickness (defaults: 3 / 2).
class GradientAvatarRing extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final double ringPadding;
  final double gapPadding;
  final VoidCallback? onTap;

  const GradientAvatarRing({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 24,
    this.ringPadding = 2.5,
    this.gapPadding = 2,
    this.onTap,
  });

  static const _gradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFFBB86FC), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  bool get _hasAvatar => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ringPadding),
        decoration: const BoxDecoration(
          gradient: _gradient,
          shape: BoxShape.circle,
        ),
        child: Container(
          padding: EdgeInsets.all(gapPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xFF2A2A2A),
            backgroundImage: _hasAvatar ? NetworkImage(imageUrl!) : null,
            child: !_hasAvatar
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      fontSize: radius * 0.6,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
