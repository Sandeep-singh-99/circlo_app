import 'package:flutter/material.dart';

/// An animated shimmer placeholder row shown while search results load.
class SearchSkeletonTile extends StatefulWidget {
  const SearchSkeletonTile({super.key});

  @override
  State<SearchSkeletonTile> createState() => _SearchSkeletonTileState();
}

class _SearchSkeletonTileState extends State<SearchSkeletonTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _colorAnim = ColorTween(
      begin: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE),
      end: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFDDDDDD),
    ).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnim,
      builder: (context, child) {
        final c = _colorAnim.value!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(radius: 25, backgroundColor: c),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(c, width: 130, height: 12),
                    const SizedBox(height: 6),
                    _box(c, width: 80, height: 10),
                  ],
                ),
              ),
              _box(c, width: 72, height: 32, radius: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _box(
    Color c, {
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
