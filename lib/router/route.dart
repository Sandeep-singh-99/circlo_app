import 'dart:async';

import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/pages/auth/forget_password.dart';
import 'package:circlo_app/pages/auth/login.dart';
import 'package:circlo_app/pages/auth/signup.dart';
import 'package:circlo_app/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const String login = '/login';
const String signup = '/signup';
const String home = '/';
const String forgetPassword = '/forget-password';
const String splash = '/splash';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: splash,

    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    redirect: (context, state) {
      final authState = authBloc.state;

      final isOnLogin = state.matchedLocation == login;
      final isOnSignup = state.matchedLocation == signup;
      final isOnForget = state.matchedLocation == forgetPassword;
      final isOnSplash = state.matchedLocation == splash;

      // 1️⃣ While checking token → stay on splash
      if (authState is AuthStateInitial || authState is AuthLoading) {
        return isOnSplash ? null : splash;
      }

      // 2️⃣ Not authenticated
      if (authState is AuthUnauthenticated) {
        if (isOnLogin || isOnSignup || isOnForget) {
          return null;
        }
        return login;
      }

      // 3️⃣ Authenticated
      if (authState is AuthAuthenticated) {
        if (isOnLogin || isOnSignup || isOnForget || isOnSplash) {
          return home;
        }
      }

      return null;
    },

    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(path: login, builder: (context, state) => const LoginPage()),
      GoRoute(path: signup, builder: (context, state) => const SignupPage()),
      GoRoute(
        path: forgetPassword,
        builder: (context, state) => const ForgetPassword(),
      ),
      GoRoute(path: home, builder: (context, state) => const HomePage()),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
