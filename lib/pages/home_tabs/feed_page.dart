import 'package:circlo_app/features/post/bloc/post_bloc.dart';
import 'package:circlo_app/features/post/bloc/post_state.dart';
import 'package:circlo_app/widgets/feed_post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconAnimController;
  late Animation<double> _iconScaleAnim;
  bool _hasNotification = true;

  @override
  void initState() {
    super.initState();
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _iconScaleAnim = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _iconAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _iconAnimController.dispose();
    super.dispose();
  }

  void _onIconTap(VoidCallback action) async {
    HapticFeedback.lightImpact();
    await _iconAnimController.forward();
    await _iconAnimController.reverse();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final iconColor = isDark ? Colors.white : Colors.black87;
    final fgColor = isDark ? Colors.white : Colors.black;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            title: _buildLogoTitle(),
            actions: [
              _buildActionIcon(
                icon: Icons.favorite_border_rounded,
                badge: _hasNotification,
                color: iconColor,
                onTap: () => setState(() => _hasNotification = false),
              ),
              const SizedBox(width: 4),
              _buildActionIcon(
                icon: Icons.send_rounded,
                color: iconColor,
                onTap: () {},
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(height: 0.5, color: dividerColor),
            ),
          ),
        ],
        body: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state is PostLoading || state is PostStateInitial) {
              return _buildSkeletonLoader(isDark);
            }

            if (state is PostFailure) {
              return _buildErrorState(state.message, fgColor, isDark);
            }

            if (state is PostSuccess) {
              final posts = state.postResponseModel.posts;
              final user = state.postResponseModel.user;

              if (posts.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return RefreshIndicator(
                color: const Color(0xFF6C63FF),
                backgroundColor: isDark
                    ? const Color(0xFF1C1C1E)
                    : Colors.white,
                onRefresh: () async {
                  // Trigger refresh; optionally add PostGetAllRequested event
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return FeedPostCard(post: posts[index], user: user);
                  },
                ),
              );
            }

            return _buildEmptyState(isDark);
          },
        ),
      ),
    );
  }

  // ── AppBar Widgets ──────────────────────────────────────────────────────

  Widget _buildLogoTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF6C63FF), Color(0xFFBB86FC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        'Circlo',
        style: GoogleFonts.pacifico(
          fontSize: 26,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool badge = false,
  }) {
    return ScaleTransition(
      scale: _iconScaleAnim,
      child: GestureDetector(
        onTap: () => _onIconTap(onTap),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: 26),
              if (badge)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B5C),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Feed States ─────────────────────────────────────────────────────────

  Widget _buildSkeletonLoader(bool isDark) {
    final shimmer = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE);
    final shimmerHighlight = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE0E0E0);

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (_, __) => _SkeletonPostCard(
        baseColor: shimmer,
        highlightColor: shimmerHighlight,
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05),
            ),
            child: Icon(
              Icons.dynamic_feed_rounded,
              size: 40,
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.15),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your feed is empty',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Follow people to see their posts here',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, Color fgColor, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 52,
              color: isDark
                  ? Colors.white.withOpacity(0.2)
                  : Colors.black.withOpacity(0.15),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: fgColor.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6C63FF)),
              label: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton card ───────────────────────────────────────────────────────────

class _SkeletonPostCard extends StatefulWidget {
  final Color baseColor;
  final Color highlightColor;

  const _SkeletonPostCard({
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<_SkeletonPostCard> createState() => _SkeletonPostCardState();
}

class _SkeletonPostCardState extends State<_SkeletonPostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _colorAnim = ColorTween(
      begin: widget.baseColor,
      end: widget.highlightColor,
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
      builder: (_, __) {
        final c = _colorAnim.value!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(radius: 20, backgroundColor: c),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(c, width: 110, height: 11),
                      const SizedBox(height: 5),
                      _box(c, width: 70, height: 9),
                    ],
                  ),
                ],
              ),
            ),
            // Image skeleton
            AspectRatio(aspectRatio: 1, child: Container(color: c)),
            // Actions skeleton
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Row(
                children: [
                  _box(c, width: 26, height: 26),
                  const SizedBox(width: 14),
                  _box(c, width: 26, height: 26),
                  const SizedBox(width: 14),
                  _box(c, width: 26, height: 26),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _box(c, width: 100, height: 11),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _box(c, width: double.infinity, height: 11),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _box(c, width: 200, height: 11),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _box(Color color, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
