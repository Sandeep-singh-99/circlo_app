import 'package:circlo_app/core/storage/secure_storage.dart';
import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_event.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/features/auth/repository/auth_repository.dart';
import 'package:circlo_app/features/bio/bloc/bio_bloc.dart';
import 'package:circlo_app/features/bio/repository/bio_repository.dart';
import 'package:circlo_app/features/bookmark/bloc/bookmark_bloc.dart';
import 'package:circlo_app/features/bookmark/repository/bookmark_repository.dart';
import 'package:circlo_app/features/comment/bloc/comment_bloc.dart';
import 'package:circlo_app/features/comment/repository/comment_repository.dart';
import 'package:circlo_app/features/like/bloc/like_bloc.dart';
import 'package:circlo_app/features/like/repository/like_repository.dart';
import 'package:circlo_app/features/post/bloc/post_bloc.dart';
import 'package:circlo_app/features/post/repository/post_repository.dart';
import 'package:circlo_app/features/repost/bloc/repost_bloc.dart';
import 'package:circlo_app/features/repost/repository/repost_repository.dart';
import 'package:circlo_app/features/theme/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:circlo_app/config/theme.dart';
import 'package:circlo_app/router/route.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit(SecureStorageService())),
        BlocProvider(
          create: (context) =>
              AuthBloc(AuthRepository(), SecureStorageService())
                ..add(AuthCheckRequested()),
        ),
        BlocProvider(create: (context) => PostBloc(PostRepository())),
        BlocProvider(create: (context) => BookmarkBloc(BookmarkRepository())),
        BlocProvider(create: (context) => LikeBloc(LikeRepository())),
        BlocProvider(create: (context) => CommentBloc(CommentRepository())),
        BlocProvider(create: (context) => BioBloc(BioRepository())),
        BlocProvider(create: (context) => RepostBloc(RepostRepository())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Initialize the router EXACTLY ONCE.
    // If it's initialized in build(), every theme change reconstructs the
    // router instance, which resets the navigation stack to the home route.
    _router = createRouter(context.read<AuthBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          builder: (context, child) {
            return AnimatedTheme(
              data: themeMode == ThemeMode.light
                  ? AppTheme.lightTheme
                  : AppTheme.darkTheme,
              duration: const Duration(milliseconds: 20),
              curve: Curves.easeInOut,
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
                child: child!,
              ),
            );
          },
        );
      },
    );
  }
}
