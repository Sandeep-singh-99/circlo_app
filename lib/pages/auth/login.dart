import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Container(), flex: 2),
              // Instagram Text Logo
              const Text(
                'Circlo',
                style: TextStyle(
                  fontFamily:
                      'Poppins', // Make sure you have the font or use a generic one
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 64),

              // Email Input
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Phone number, email or username',
                  border: OutlineInputBorder(
                    borderSide: Divider.createBorderSide(context),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: Divider.createBorderSide(context),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: Divider.createBorderSide(context),
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.all(8),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),

              // Password Input
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderSide: Divider.createBorderSide(context),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: Divider.createBorderSide(context),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: Divider.createBorderSide(context),
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.all(8),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              InkWell(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: Colors.blue,
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                      child: const Text(
                        " Sign up.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
