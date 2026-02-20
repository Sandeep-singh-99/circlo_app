import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_event.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/widgets/my_button.dart';
import 'package:circlo_app/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthLoginRequested(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(child: Container(), flex: 2),
                  // Circlo Text Logo
                  Text(
                    'Circlo',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Email Input
                  MyTextField(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  MyTextField(
                    controller: _passwordController,
                    hintText: 'Enter your password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        context.push('/forget-password');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  MyButton(
                    text: 'Log in',
                    onTap: _onLogin,
                    isLoading: state is AuthLoading,
                  ),
                  const SizedBox(height: 24),

                  Flexible(child: Container(), flex: 2),

                  // Transition to Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: const Text("Don't have an account?"),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go('/signup');
                        },
                        child: Container(
                          child: Text(
                            " Register now",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
