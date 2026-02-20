import 'dart:io';

import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_event.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/widgets/my_button.dart';
import 'package:circlo_app/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _image;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _onSignup() {
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthSignupRequested(
        name: username,
        email: email,
        password: password,
        image: _image,
      ),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),
                            // Circlo Text Logo
                            Text(
                              'Circlo',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 24),

                            // Profile Image Picker
                            Stack(
                              children: [
                                _image != null
                                    ? CircleAvatar(
                                        radius: 64,
                                        backgroundImage: FileImage(_image!),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).inputDecorationTheme.fillColor,
                                      )
                                    : CircleAvatar(
                                        radius: 64,
                                        backgroundImage: const NetworkImage(
                                          'https://i.stack.imgur.com/l60Hf.png', // Default avatar
                                        ),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).inputDecorationTheme.fillColor,
                                      ),
                                Positioned(
                                  bottom: -10,
                                  left: 80,
                                  child: IconButton(
                                    onPressed: _selectImage,
                                    icon: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 48),

                            // Email Input
                            MyTextField(
                              controller: _emailController,
                              hintText: 'Enter your email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Username Input
                            MyTextField(
                              controller: _usernameController,
                              hintText: 'Create a username',
                              keyboardType: TextInputType.text,
                            ),
                            const SizedBox(height: 16),

                            // Password Input
                            MyTextField(
                              controller: _passwordController,
                              hintText: 'Create a password',
                              obscureText: true,
                            ),
                            const SizedBox(height: 32),

                            // Sign Up Button
                            MyButton(
                              text: 'Sign up',
                              onTap: _onSignup,
                              isLoading: state is AuthLoading,
                            ),
                            const SizedBox(height: 12),

                            const Spacer(flex: 2),

                            // Transition to Log In
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: const Text("Already have an account?"),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.go('/login');
                                  },
                                  child: Container(
                                    child: Text(
                                      " Log in now",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.secondary,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
