import 'package:circlo_app/pages/auth/forget_password.dart';
import 'package:circlo_app/pages/auth/login.dart';
import 'package:circlo_app/pages/auth/signup.dart';
import 'package:circlo_app/pages/home.dart';
import 'package:go_router/go_router.dart';

const String login = '/login';
const String signup = '/signup';
const String home = '/';
const String forgetPassword = '/forget-password';

final GoRouter routerConfig = GoRouter(
  initialLocation: login,
  routes: [
    GoRoute(path: login, builder: (context, state) => const LoginPage()),
    GoRoute(path: signup, builder: (context, state) => const SignupPage()),
    GoRoute(path: forgetPassword, builder: (context, state) => const ForgetPassword()),
    GoRoute(path: home, builder: (context, state) => const HomePage()),
  ],
);
