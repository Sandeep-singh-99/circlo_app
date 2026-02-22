import 'package:flutter/material.dart';

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
              // TODO: navigate to image upload / create post screen
            },
          ),
          CreatePostOption(
            icon: Icons.videocam_outlined,
            label: 'Video Upload',
            subtitle: 'Share a video or reel',
            iconColor: Colors.deepPurple,
            onTap: () {
              Navigator.of(context).pop();
              // TODO: navigate to video upload / reel screen
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

class CreatePostOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const CreatePostOption({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withAlpha(102),
            ),
          ],
        ),
      ),
    );
  }
}
