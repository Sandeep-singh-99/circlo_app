import 'dart:io';

import 'package:flutter/material.dart';
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
              // Circlo Text Logo
              const Text(
                'Circlo',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
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
                        )
                      : const CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(
                            'https://i.stack.imgur.com/l60Hf.png',
                          ),
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: _selectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64),

              // Email Input
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
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

              // Username Input
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
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
                keyboardType: TextInputType.text,
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

              // Sign Up Button
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
                    'Sign up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(child: Container(), flex: 2),

              // Transition to Log In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: const Text("Already have an account?"),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.go('/login');
                    },
                    child: Container(
                      child: const Text(
                        " Log in.",
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
