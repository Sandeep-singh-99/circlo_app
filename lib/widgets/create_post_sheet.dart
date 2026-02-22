import 'package:circlo_app/router/route.dart' as app_routes;
import 'package:circlo_app/widgets/create_post_option.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreatePostSheet extends StatelessWidget {
  const CreatePostSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Create',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: colorScheme.onSurface,
                ),
              ],
            ),
          ),

          const Divider(height: 1),
          const SizedBox(height: 8),

          CreatePostOption(
            icon: Icons.image_outlined,
            label: 'Image Upload',
            subtitle: 'Share a photo with your followers',
            iconColor: primaryColor,
            onTap: () {
              Navigator.of(context).pop();
              context.push(app_routes.createImagePost);
            },
          ),

          CreatePostOption(
            icon: Icons.videocam_outlined,
            label: 'Video Upload',
            subtitle: 'Share a video or reel',
            iconColor: Colors.deepPurple,
            onTap: () {
              Navigator.of(context).pop();
              // TODO: navigate to video upload screen
            },
          ),

          CreatePostOption(
            icon: Icons.stream,
            label: 'Live',
            subtitle: 'Start a live broadcast',
            iconColor: Colors.redAccent,
            onTap: () {
              Navigator.of(context).pop();
              // TODO: navigate to live stream screen
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
