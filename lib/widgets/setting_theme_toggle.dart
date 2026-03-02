import 'package:circlo_app/features/theme/theme_cubit.dart';
import 'package:circlo_app/widgets/setting_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingThemeToggle extends StatelessWidget {
  const SettingThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;
        final icon = isDark
            ? Icons.dark_mode_rounded
            : Icons.light_mode_rounded;
        final title = isDark ? 'Dark Mode' : 'Light Mode';

        return SettingTile(
          icon: icon,
          title: title,
          onTap: () => context.read<ThemeCubit>().toggleTheme(),
          trailing: CupertinoSwitch(
            value: isDark,
            activeColor: const Color(0xFF6C63FF),
            onChanged: (_) {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        );
      },
    );
  }
}
