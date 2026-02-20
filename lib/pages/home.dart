import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/pages/home_tabs/activity_page.dart';
import 'package:circlo_app/pages/home_tabs/add_post_page.dart';
import 'package:circlo_app/pages/home_tabs/feed_page.dart';
import 'package:circlo_app/pages/home_tabs/profile_page.dart';
import 'package:circlo_app/pages/home_tabs/search_page.dart';
import 'package:circlo_app/widgets/my_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FeedPage(),
    const SearchPage(),
    const AddPostPage(),
    const ActivityPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            profileImageUrl: profileImageUrl,
          ),
        );
      },
    );
  }
}
