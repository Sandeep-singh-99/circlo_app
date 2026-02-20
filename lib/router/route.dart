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

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: login,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      // Also consider AuthUnauthenticated as strictly not authenticated
      // And AuthInitial/AuthLoading as "wait"

      final isLoggingIn = state.uri.toString() == login;
      final isSigningUp = state.uri.toString() == signup;
      final isForgetPassword = state.uri.toString() == forgetPassword;

      if (!isAuthenticated) {
        // If not authenticated, we can be on login, signup or forgetPassword
        // If we are on home, redirect to login
        if (!isLoggingIn && !isSigningUp && !isForgetPassword) {
          return login;
        }
      }

      if (isAuthenticated) {
        // If authenticated, we should not be on login/signup/forgetPassword
        if (isLoggingIn || isSigningUp || isForgetPassword) {
          return home;
        }
      }

      return null;
    },
    routes: [
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
