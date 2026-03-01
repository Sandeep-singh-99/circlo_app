import 'package:circlo_app/widgets/image_shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPostImage extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onDoubleTap;
  final AnimationController heartOverlayController;
  final Animation<double> heartOverlayScale;
  final Animation<double> heartOverlayOpacity;

  const FeedPostImage({
    super.key,
    required this.imageUrl,
    required this.onDoubleTap,
    required this.heartOverlayController,
    required this.heartOverlayScale,
    required this.heartOverlayOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Image fills screen width, height auto from actual image dimensions
          SizedBox(
            width: screenWidth,
            child: Image.network(
              imageUrl,
              width: screenWidth,
              // Let the image render at its natural aspect ratio (up to 4:5 portrait max)
              fit: BoxFit.fitWidth,
              frameBuilder: (ctx, child, frame, wasSynchronous) {
                if (wasSynchronous || frame != null) return child;
                // Show shimmer placeholder while loading
                return ImageShimmerWidget(isDark: isDark, width: screenWidth);
              },
              loadingBuilder: (ctx, child, progress) {
                if (progress == null) return child;
                return ImageShimmerWidget(isDark: isDark, width: screenWidth);
              },
              errorBuilder: (_, __, ___) => Container(
                width: screenWidth,
                height: 280,
                color: isDark
                    ? const Color(0xFF1C1C1E)
                    : const Color(0xFFF5F5F5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      color: Colors.grey[600],
                      size: 44,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Image unavailable',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Double-tap heart overlay
          AnimatedBuilder(
            animation: heartOverlayController,
            builder: (_, __) => Opacity(
              opacity: heartOverlayOpacity.value,
              child: Transform.scale(
                scale: heartOverlayScale.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 90,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 24)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
