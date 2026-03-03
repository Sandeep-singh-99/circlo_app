import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_event.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/features/auth/models/auth_model.dart';
import 'package:circlo_app/features/post/bloc/post_bloc.dart';
import 'package:circlo_app/features/post/bloc/post_event.dart';
import 'package:circlo_app/features/post/bloc/post_state.dart';
import 'package:circlo_app/features/post/models/post_model.dart';
import 'package:circlo_app/features/repost/bloc/repost_bloc.dart';
import 'package:circlo_app/features/repost/bloc/repost_event.dart';
import 'package:circlo_app/features/repost/bloc/repost_state.dart';
import 'package:circlo_app/widgets/gradient_avatar_ring.dart';
import 'package:circlo_app/widgets/profile_grid_post_card.dart';
import 'package:circlo_app/widgets/profile_stat_column.dart';
import 'package:circlo_app/router/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF6C63FF);

// ─────────────────────────────────────────────────────────────
//  PROFILE PAGE
// ─────────────────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return _ProfileContent(user: state.user, tab: _tab);
        }
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: _kPurple)),
          );
        }
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_off_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'You are not logged in',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  MAIN CONTENT  (authenticated)
// ─────────────────────────────────────────────────────────────
class _ProfileContent extends StatefulWidget {
  final AuthModel user;
  final TabController tab;

  const _ProfileContent({required this.user, required this.tab});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  @override
  void initState() {
    super.initState();
    // Fetch the current user's own posts when the profile page loads
    context.read<PostBloc>().add(PostGetOwnRequested());
    // Fetch reposts for the Reposts tab
    context.read<RepostBloc>().add(GetRepostsRequested());
  }

  void _showSettingsSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SettingsSheet(isDark: isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    // Derive follower/following stats from user id hash (kept as before)
    final seed = widget.user.id?.hashCode.abs() ?? 42;
    final followersCount = (seed % 9800) + 200;
    final followingCount = (seed % 600) + 50;

    return BlocBuilder<PostBloc, PostState>(
      builder: (context, postState) {
        final posts = postState is PostSuccess
            ? postState.postResponseModel.posts
            : <PostModel>[];
        final postsCount = posts.length;

        return Scaffold(
          backgroundColor: bg,
          body: NestedScrollView(
            headerSliverBuilder: (ctx, _) => [
              // ── AppBar ──────────────────────────────────────────
              SliverAppBar(
                backgroundColor: bg,
                elevation: 0,
                pinned: true,
                title: Text(
                  widget.user.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: textPrimary,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.add_box_outlined, color: textPrimary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.menu_rounded, color: textPrimary),
                    onPressed: () => _showSettingsSheet(context, isDark),
                  ),
                ],
              ),

              // ── Profile header ──────────────────────────────────
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  user: widget.user,
                  postsCount: postsCount,
                  followersCount: followersCount,
                  followingCount: followingCount,
                  isDark: isDark,
                ),
              ),

              // ── Story Highlights row ────────────────────────────
              SliverToBoxAdapter(
                child: _HighlightsRow(
                  user: widget.user,
                  textSecondary: textSecondary,
                ),
              ),

              // ── Sticky Tab bar ──────────────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: widget.tab,
                    indicatorColor: textPrimary,
                    indicatorWeight: 1.5,
                    labelColor: textPrimary,
                    unselectedLabelColor: textSecondary,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on_rounded, size: 24)),
                      Tab(
                        icon: Icon(Icons.slow_motion_video_rounded, size: 24),
                      ),
                      Tab(
                        icon: Icon(Icons.person_pin_circle_outlined, size: 24),
                      ),
                      Tab(icon: Icon(Icons.repeat_rounded, size: 24)),
                    ],
                  ),
                  color: bg,
                ),
              ),
            ],
            body: TabBarView(
              controller: widget.tab,
              children: [
                // ── Posts grid ────────────────────────────────────
                _PostsGrid(
                  posts: posts,
                  isLoading: postState is PostLoading,
                  errorMessage: postState is PostFailure
                      ? postState.message
                      : null,
                  textSecondary: textSecondary,
                ),

                // ── Reels placeholder ─────────────────────────────
                _EmptyTabContent(
                  icon: Icons.slow_motion_video_rounded,
                  label: 'No Reels yet',
                  textSecondary: textSecondary,
                ),

                // ── Tagged placeholder ────────────────────────────
                _EmptyTabContent(
                  icon: Icons.person_pin_circle_outlined,
                  label: 'No tagged posts',
                  textSecondary: textSecondary,
                ),

                // ── Reposts tab ────────────────────────────────────
                _RepostsTab(textSecondary: textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PROFILE HEADER
// ─────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final AuthModel user;
  final int postsCount, followersCount, followingCount;
  final bool isDark;

  const _ProfileHeader({
    required this.user,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar + stats ──────────────────────────────────
          Row(
            children: [
              // ↓ GradientAvatarRing custom widget
              GradientAvatarRing(
                imageUrl: user.imageUrl,
                name: user.name,
                radius: 44,
                ringPadding: 3,
                gapPadding: 3,
              ),
              const SizedBox(width: 24),

              // ↓ ProfileStatColumn custom widget (×3)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ProfileStatColumn(
                      value: formatStatCount(postsCount),
                      label: 'Posts',
                    ),
                    ProfileStatColumn(
                      value: formatStatCount(followersCount),
                      label: 'Followers',
                    ),
                    ProfileStatColumn(
                      value: formatStatCount(followingCount),
                      label: 'Following',
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Name & bio ─────────────────────────────────────
          Text(
            user.name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user.email,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
          ),
          const SizedBox(height: 4),

          // ── Bio text ──────────────────────────────────────
          if (user.bio?.bio != null && user.bio!.bio!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                user.bio!.bio!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: textPrimary.withValues(alpha: 0.85),
                ),
              ),
            ),

          // ── Location ──────────────────────────────────────
          if (user.bio?.location != null && user.bio!.location!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.bio!.location!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                ],
              ),
            ),

          // ── Website ───────────────────────────────────────
          if (user.bio?.website != null && user.bio!.website!.isNotEmpty)
            GestureDetector(
              onTap: () async {
                final url = Uri.tryParse(user.bio!.website!);
                if (url != null && await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, size: 14, color: _kPurple),
                    const SizedBox(width: 4),
                    Text(
                      user.bio!.website!,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _kPurple,
                        decoration: TextDecoration.underline,
                        decorationColor: _kPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Fallback empty bio hint ────────────────────────
          if (user.bio == null ||
              (user.bio!.bio?.isEmpty ?? true) &&
                  (user.bio!.location?.isEmpty ?? true) &&
                  (user.bio!.website?.isEmpty ?? true))
            Text(
              'Add a bio to tell people about yourself',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: isDark ? Colors.grey[600]! : Colors.grey[500]!,
                fontStyle: FontStyle.italic,
              ),
            ),

          const SizedBox(height: 14),

          // ── Action buttons ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ProfileActionButton(
                  label: 'Edit Profile',
                  filled: false,
                  onTap: () => context.push(editBio),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProfileActionButton(
                  label: 'Share Profile',
                  filled: false,
                  onTap: () {},
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              _IconSquareButton(
                icon: Icons.person_add_alt_1_outlined,
                onTap: () {},
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PROFILE ACTION BUTTON  (Edit / Share)
// ─────────────────────────────────────────────────────────────
class _ProfileActionButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  final bool isDark;

  const _ProfileActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF262626) : const Color(0xFFEFEFEF);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 32,
        decoration: BoxDecoration(
          color: filled ? _kPurple : bg,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: filled
                ? Colors.white
                : isDark
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  ICON SQUARE BUTTON  (person add)
// ─────────────────────────────────────────────────────────────
class _IconSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _IconSquareButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF262626) : const Color(0xFFEFEFEF);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HIGHLIGHTS ROW
// ─────────────────────────────────────────────────────────────
class _HighlightsRow extends StatelessWidget {
  final AuthModel user;
  final Color textSecondary;

  const _HighlightsRow({required this.user, required this.textSecondary});

  static const _labels = ['Travel', 'Food', 'Fitness', 'Work', 'Family'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 98,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _labels.length + 1,
        itemBuilder: (ctx, i) {
          if (i == 0) {
            // "New" bubble
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 28,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'New',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          final label = _labels[i - 1];
          final seed = (user.id?.hashCode.abs() ?? 0) + i * 37;
          return _HighlightBubble(
            label: label,
            imageUrl: 'https://picsum.photos/seed/$seed/200/200',
            textSecondary: textSecondary,
          );
        },
      ),
    );
  }
}

class _HighlightBubble extends StatelessWidget {
  final String label;
  final String imageUrl;
  final Color textSecondary;

  const _HighlightBubble({
    required this.label,
    required this.imageUrl,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            // ↓ reuse GradientAvatarRing for highlight images
            GradientAvatarRing(
              imageUrl: imageUrl,
              name: label,
              radius: 28,
              ringPadding: 2.5,
              gapPadding: 2,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  STICKY TAB BAR DELEGATE
// ─────────────────────────────────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;

  const _TabBarDelegate(this.tabBar, {required this.color});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: color, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}

// ─────────────────────────────────────────────────────────────
//  POSTS GRID
// ─────────────────────────────────────────────────────────────
class _PostsGrid extends StatelessWidget {
  final List<PostModel> posts;
  final bool isLoading;
  final String? errorMessage;
  final Color textSecondary;
  final IconData? emptyIcon;
  final String? emptyLabel;

  const _PostsGrid({
    required this.posts,
    required this.isLoading,
    required this.textSecondary,
    this.errorMessage,
    this.emptyIcon,
    this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1.5,
          mainAxisSpacing: 1.5,
        ),
        itemCount: 9,
        itemBuilder: (ctx, i) =>
            Container(color: Colors.grey.withValues(alpha: 0.15)),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: GoogleFonts.poppins(color: textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              emptyIcon ?? Icons.grid_off_rounded,
              size: 52,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 12),
            Text(
              emptyLabel ?? 'No posts yet',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
      ),
      itemCount: posts.length,
      // ↓ Uses ProfileGridPostCard widget from widgets/
      itemBuilder: (ctx, i) => ProfileGridPostCard(post: posts[i]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EMPTY TAB CONTENT  (Reels / Tagged placeholders)
// ─────────────────────────────────────────────────────────────
class _EmptyTabContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color textSecondary;

  const _EmptyTabContent({
    required this.icon,
    required this.label,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.grey[700]),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  REPOSTS TAB  (stateful so it can re-trigger fetch)
// ─────────────────────────────────────────────────────────────
class _RepostsTab extends StatefulWidget {
  final Color textSecondary;
  const _RepostsTab({required this.textSecondary});

  @override
  State<_RepostsTab> createState() => _RepostsTabState();
}

class _RepostsTabState extends State<_RepostsTab> {
  List<PostModel> _lastPosts = [];

  @override
  void initState() {
    super.initState();
    // Always refresh when the tab widget mounts
    context.read<RepostBloc>().add(GetRepostsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RepostBloc, RepostState>(
      listener: (context, state) {
        if (state is RepostsLoaded) {
          // Cache last-known list so RepostToggled doesn't blank the tab
          _lastPosts = state.posts;
        }
      },
      builder: (context, state) {
        if (state is RepostLoading || state is RepostInitial) {
          return const Center(
            child: CircularProgressIndicator(color: _kPurple),
          );
        }
        if (state is RepostError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: GoogleFonts.poppins(
                    color: widget.textSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      context.read<RepostBloc>().add(GetRepostsRequested()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        // Use freshly loaded list; fall back to cached _lastPosts
        // when state is RepostToggled (toggle on feed) to avoid blank tab
        final posts = state is RepostsLoaded ? state.posts : _lastPosts;
        return _PostsGrid(
          posts: posts,
          isLoading: false,
          errorMessage: null,
          textSecondary: widget.textSecondary,
          emptyIcon: Icons.repeat_rounded,
          emptyLabel: 'No reposts yet',
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SETTINGS SHEET
// ─────────────────────────────────────────────────────────────
class _SettingsSheet extends StatelessWidget {
  final bool isDark;

  const _SettingsSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black87;
    return SafeArea(
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
          _SheetTile(
            icon: Icons.settings_outlined,
            label: 'Settings & Privacy',
            color: textColor,
            onTap: () {
              Navigator.pop(context);
              context.push(setting);
            },
          ),
          _SheetTile(
            icon: Icons.bookmark_border_rounded,
            label: 'Saved',
            color: textColor,
            onTap: () => Navigator.pop(context),
          ),
          _SheetTile(
            icon: Icons.qr_code_rounded,
            label: 'QR Code',
            color: textColor,
            onTap: () => Navigator.pop(context),
          ),
          _SheetTile(
            icon: Icons.bar_chart_rounded,
            label: 'Insights',
            color: textColor,
            onTap: () => Navigator.pop(context),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _SheetTile(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            color: Colors.redAccent,
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
      onTap: onTap,
    );
  }
}
