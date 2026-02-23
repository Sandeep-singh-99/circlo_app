import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────────────────────

/// Holds the gradient colors for a single explore grid tile.
class SearchTileData {
  final List<Color> colors;
  const SearchTileData({required this.colors});
}

// ─────────────────────────────────────────────────────────────
//  PRESET TILE DATA
// ─────────────────────────────────────────────────────────────

final kSearchGridTiles = [
  SearchTileData(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
  SearchTileData(colors: [Color(0xFF0F3460), Color(0xFF533483)]),
  SearchTileData(colors: [Color(0xFF2D132C), Color(0xFF1B1B2F)]),
  SearchTileData(colors: [Color(0xFF1B1B2F), Color(0xFF2C2C54)]),
  SearchTileData(colors: [Color(0xFF162447), Color(0xFF1F4068)]),
  SearchTileData(colors: [Color(0xFF0B0C10), Color(0xFF1F2833)]),
  SearchTileData(colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)]),
  SearchTileData(colors: [Color(0xFF2D132C), Color(0xFF9B59B6)]),
  SearchTileData(colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)]),
  SearchTileData(colors: [Color(0xFF373B44), Color(0xFF4286f4)]),
  SearchTileData(colors: [Color(0xFF1A1A1A), Color(0xFF6C63FF)]),
  SearchTileData(colors: [Color(0xFF16213E), Color(0xFF533483)]),
];

const kSearchGridIcons = [
  Icons.landscape_rounded,
  Icons.person_rounded,
  Icons.restaurant_rounded,
  Icons.directions_bike_rounded,
  Icons.music_note_rounded,
  Icons.architecture_rounded,
  Icons.photo_camera_rounded,
  Icons.favorite_rounded,
  Icons.travel_explore_rounded,
  Icons.palette_rounded,
  Icons.movie_rounded,
  Icons.fitness_center_rounded,
];

// ─────────────────────────────────────────────────────────────
//  WIDGET
// ─────────────────────────────────────────────────────────────

/// A single cell in the explore grid.
/// [index] drives the gradient colors, icon, and "featured" badge.
class SearchGridTile extends StatelessWidget {
  final SearchTileData tile;
  final IconData icon;
  final int index;

  const SearchGridTile({
    super.key,
    required this.tile,
    required this.icon,
    required this.index,
  });

  bool get _isFeatured => index % 7 == 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: tile.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Subtle noise texture overlay
            Opacity(
              opacity: 0.06,
              child: CustomPaint(painter: _NoisePainter(index)),
            ),

            // Centre icon watermark
            Center(
              child: Icon(
                icon,
                size: _isFeatured ? 36 : 28,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),

            // "Reel" badge on featured tiles
            if (_isFeatured)
              Positioned(
                bottom: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Reel',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Like count
            Positioned(
              top: 5,
              right: 5,
              child: Opacity(
                opacity: 0.8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${(index + 1) * 137}',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  NOISE PAINTER
// ─────────────────────────────────────────────────────────────

class _NoisePainter extends CustomPainter {
  final int seed;
  _NoisePainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.4);
    for (int i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(_NoisePainter old) => old.seed != seed;
}
