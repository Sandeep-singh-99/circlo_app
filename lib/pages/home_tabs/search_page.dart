import 'package:circlo_app/widgets/search_bar_field.dart';
import 'package:circlo_app/widgets/search_category_chip.dart';
import 'package:circlo_app/widgets/search_grid_tile.dart';
import 'package:circlo_app/widgets/search_skeleton_tile.dart';
import 'package:circlo_app/widgets/search_user_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────────────────────
const _kPurple = Color(0xFF6C63FF);
const _kViolet = Color(0xFFBB86FC);

const _kCategories = ['All', 'Photos', 'Videos', 'Reels', 'People', 'Tags'];

const _kTrending = [
  '#photography',
  '#nature',
  '#travel',
  '#art',
  '#food',
  '#fashion',
  '#fitness',
  '#music',
  '#architecture',
  '#sunset',
];

const _kUserNames = [
  'alex.photography',
  'travel_with_sarah',
  'art.by.lena',
  'foodie_vibes',
  'urban.explorer',
  'wild.nature.shots',
  'studio.dreams',
  'creative.chaos',
];
const _kUserFollowers = [
  '142K',
  '89K',
  '34K',
  '211K',
  '56K',
  '78K',
  '12K',
  '300K',
];
const _kRecentNames = [
  'alex.creative',
  'photo_world',
  'travel.diaries',
  'art_studio',
  'daily_fitness',
];

// ─────────────────────────────────────────────────────────────
//  SEARCH PAGE
// ─────────────────────────────────────────────────────────────
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────────
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSearching = false;
  bool _isLoading = false;
  String _query = '';
  int _selectedCategory = 0;

  // ── Cancel-button animation ──────────────────────────────────
  late AnimationController _searchBarCtrl;
  late Animation<double> _cancelWidth;

  // ── Lifecycle ────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _searchBarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _cancelWidth = Tween<double>(begin: 0, end: 72).animate(
      CurvedAnimation(parent: _searchBarCtrl, curve: Curves.easeOutCubic),
    );

    _focusNode.addListener(_onFocusChange);
    _searchController.addListener(
      () => setState(() => _query = _searchController.text),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _searchBarCtrl.dispose();
    super.dispose();
  }

  // ── Handlers ─────────────────────────────────────────────────
  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    setState(() => _isSearching = focused);
    focused ? _searchBarCtrl.forward() : _searchBarCtrl.reverse();
  }

  void _onSearch(String value) {
    if (value.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _cancelSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    setState(() {
      _isSearching = false;
      _query = '';
    });
  }

  void _onHashtagTap(String tag) {
    _searchController.text = tag;
    setState(() => _query = tag);
    _focusNode.requestFocus();
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            SearchBarField(
              controller: _searchController,
              focusNode: _focusNode,
              isSearching: _isSearching,
              query: _query,
              cancelWidth: _cancelWidth,
              onCancel: _cancelSearch,
              onSubmitted: _onSearch,
            ),

            // Category chips (hidden while searching)
            if (!_isSearching) _buildCategoryChips(),

            // Body
            Expanded(
              child: _isSearching
                  ? _buildSearchResults(isDark)
                  : _buildExploreGrid(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ── Category chips row ────────────────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: _kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => SearchCategoryChip(
          label: _kCategories[i],
          selected: i == _selectedCategory,
          onTap: () => setState(() => _selectedCategory = i),
        ),
      ),
    );
  }

  // ── Explore grid ──────────────────────────────────────────────
  Widget _buildExploreGrid(bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Trending section
        SliverToBoxAdapter(child: _buildTrendingSection(isDark)),

        // "Explore – For You" header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                Text(
                  'Explore',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 6),
                _ForYouBadge(),
              ],
            ),
          ),
        ),

        // Grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => SearchGridTile(
                tile: kSearchGridTiles[i % kSearchGridTiles.length],
                icon: kSearchGridIcons[i % kSearchGridIcons.length],
                index: i,
              ),
              childCount: 24,
            ),
          ),
        ),
      ],
    );
  }

  // ── Trending hashtags ─────────────────────────────────────────
  Widget _buildTrendingSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF6B35),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Trending',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _kTrending.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _onHashtagTap(_kTrending[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1C1E)
                      : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _kPurple.withValues(alpha: 0.2)),
                ),
                child: Text(
                  _kTrending[i],
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: _kPurple,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Search results ────────────────────────────────────────────
  Widget _buildSearchResults(bool isDark) {
    if (_query.isEmpty) return _buildRecentSearches(isDark);
    if (_isLoading) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (_, __) => const SearchSkeletonTile(),
      );
    }
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _kUserNames.length,
      itemBuilder: (_, i) => SearchUserTile(
        username: _kUserNames[i],
        followers: _kUserFollowers[i],
        colorIndex: i,
        verified: i % 3 == 0,
      ),
    );
  }

  // ── Recent searches ───────────────────────────────────────────
  Widget _buildRecentSearches(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Clear all',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _kPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _kRecentNames.length,
            itemBuilder: (_, i) => SearchRecentTile(
              name: _kRecentNames[i],
              onTap: () {
                _searchController.text = _kRecentNames[i];
                setState(() => _query = _kRecentNames[i]);
                _onSearch(_kRecentNames[i]);
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  "FOR YOU" BADGE
// ─────────────────────────────────────────────────────────────
class _ForYouBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_kPurple, _kViolet]),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'For You',
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
