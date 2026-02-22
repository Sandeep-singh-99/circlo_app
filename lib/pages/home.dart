import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/pages/home_tabs/activity_page.dart';
import 'package:circlo_app/pages/home_tabs/feed_page.dart';
import 'package:circlo_app/pages/home_tabs/profile_page.dart';
import 'package:circlo_app/pages/home_tabs/search_page.dart';
import 'package:circlo_app/widgets/create_post_sheet.dart';
import 'package:circlo_app/widgets/my_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 0=Feed, 1=Search, 2=Activity, 3=Profile  (index 2 in nav is the "Add" dialog, not a page)
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FeedPage(),
    const SearchPage(),
    const ActivityPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // The "Add" button – show the create post dialog instead of navigating
      _showCreatePostDialog();
      return;
    }
    // Remap nav indices: 0→0, 1→1, 3→2, 4→3
    final pageIndex = index > 2 ? index - 1 : index;
    setState(() {
      _selectedIndex = pageIndex;
    });
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const CreatePostSheet(),
    );
  }

  // Converts page index back to nav index for the nav bar highlight
  int get _navIndex =>
      _selectedIndex >= 2 ? _selectedIndex + 1 : _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? profileImageUrl;
        if (state is AuthAuthenticated) {
          profileImageUrl = state.user.imageUrl;
        }

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _pages),
          bottomNavigationBar: MyBottomNavBar(
            currentIndex: _navIndex,
            onTap: _onItemTapped,
            profileImageUrl: profileImageUrl,
          ),
        );
      },
    );
  }
}
