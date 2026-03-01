import 'package:flutter/material.dart';

class ImageShimmerWidget extends StatefulWidget {
  final bool isDark;
  final double width;

  const ImageShimmerWidget({
    super.key,
    required this.isDark,
    required this.width,
  });

  @override
  State<ImageShimmerWidget> createState() => _ImageShimmerWidgetState();
}

class _ImageShimmerWidgetState extends State<ImageShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isDark
        ? const Color(0xFF1C1C1E)
        : const Color(0xFFEEEEEE);
    final highlight = widget.isDark
        ? const Color(0xFF2C2C2E)
        : const Color(0xFFE0E0E0);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.width, // square shimmer until image loads
        color: Color.lerp(base, highlight, _anim.value),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 48,
            color: widget.isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
    );
  }
}
