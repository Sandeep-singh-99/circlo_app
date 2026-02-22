import 'dart:io';

import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/features/post/bloc/post_bloc.dart';
import 'package:circlo_app/features/post/bloc/post_event.dart';
import 'package:circlo_app/features/post/bloc/post_state.dart';
import 'package:circlo_app/widgets/hashtag_text_field.dart';
import 'package:circlo_app/widgets/image_picker_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class CreateImagePostPage extends StatefulWidget {
  const CreateImagePostPage({super.key});

  @override
  State<CreateImagePostPage> createState() => _CreateImagePostPageState();
}

class _CreateImagePostPageState extends State<CreateImagePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocus = FocusNode();
  File? _selectedImage;
  bool _isPosting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  // ── Image picker ────────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade500,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  void _submitPost() {
    final content = _contentController.text.trim();
    if (content.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a caption or image to post.')),
      );
      return;
    }
    context.read<PostBloc>().add(
      PostCreateRequested(content: content, image: _selectedImage),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = context.watch<AuthBloc>().state;
    String? avatarUrl;
    String username = '';
    if (authState is AuthAuthenticated) {
      avatarUrl = authState.user.imageUrl;
      username = authState.user.name;
    }

    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state is PostLoading) {
          setState(() => _isPosting = true);
        } else {
          setState(() => _isPosting = false);
        }
        if (state is PostSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post shared successfully!')),
          );
        } else if (state is PostFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'New Post',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _isPosting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: _submitPost,
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Share',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── User row ───────────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : const NetworkImage(
                            'https://i.stack.imgur.com/l60Hf.png',
                          ),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // ── Extracted widget ──────────────────────────────
                        HashtagTextField(controller: _contentController),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Image area ─────────────────────────────────────────────────
              if (_selectedImage != null)
                // ── Extracted widget ────────────────────────────────────────
                ImagePickerPreview(
                  image: _selectedImage!,
                  onRemove: () => setState(() => _selectedImage = null),
                  onChange: _showImageSourceSheet,
                )
              else
                // ── Extracted widget ────────────────────────────────────────
                AddImageButton(onTap: _showImageSourceSheet),

              const SizedBox(height: 24),

              // ── Hashtag hint ───────────────────────────────────────────────
              Row(
                children: [
                  Icon(
                    Icons.tag,
                    size: 16,
                    color: colorScheme.onSurface.withAlpha(100),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Use # to add hashtags — they'll be highlighted",
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withAlpha(100),
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
