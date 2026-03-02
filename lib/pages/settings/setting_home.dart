import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_event.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/widgets/setting_section.dart';
import 'package:circlo_app/widgets/setting_tile.dart';
import 'package:circlo_app/widgets/setting_theme_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingHome extends StatelessWidget {
  const SettingHome({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : const Color(0xFFF2F2F7);
    final textPrimary = isDark ? Colors.white : Colors.black87;

    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          // ── Profile summary card ──────────────────────────
          if (user != null) _ProfileSummaryCard(user: user, isDark: isDark),

          // ── Account ──────────────────────────────────────
          SettingSection(
            title: 'Account',
            tiles: [
              SettingTile(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                subtitle: 'Name, bio, avatar',
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: user?.email,
                onTap: () {},
              ),
            ],
          ),

          // ── Preferences ───────────────────────────────────
          SettingSection(
            title: 'Preferences',
            tiles: [
              const SettingThemeToggle(),
              SettingTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.bookmark_border_rounded,
                title: 'Saved Posts',
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.lock_person_outlined,
                title: 'Privacy',
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.qr_code_rounded,
                title: 'QR Code',
                onTap: () {},
              ),
            ],
          ),

          // ── About ─────────────────────────────────────────
          SettingSection(
            title: 'About',
            tiles: [
              SettingTile(
                icon: Icons.info_outline_rounded,
                title: 'About Circlo',
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.policy_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              SettingTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {},
              ),
            ],
          ),

          // ── Account actions ───────────────────────────────
          SettingSection(
            title: 'Account Actions',
            tiles: [
              SettingTile(
                icon: Icons.logout_rounded,
                title: 'Log Out',
                iconColor: Colors.redAccent,
                titleColor: Colors.redAccent,
                trailing: const SizedBox.shrink(),
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log Out',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              'Log Out',
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(AuthLogoutRequested());
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  PROFILE SUMMARY CARD
// ─────────────────────────────────────────────────────────────
class _ProfileSummaryCard extends StatelessWidget {
  final dynamic user;
  final bool isDark;

  const _ProfileSummaryCard({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final divider = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7);
    final hasAvatar =
        user.imageUrl != null && (user.imageUrl as String).isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(
          top: BorderSide(color: divider, width: 0.5),
          bottom: BorderSide(color: divider, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Gradient-ringed avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFBB86FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: cardBg, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFF2C2C2E),
                backgroundImage: hasAvatar
                    ? NetworkImage(user.imageUrl as String)
                    : null,
                child: !hasAvatar
                    ? Text(
                        (user.name as String).isNotEmpty
                            ? (user.name as String)[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name as String,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                Text(
                  user.email as String,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.chevron_right_rounded, color: textSecondary, size: 20),
        ],
      ),
    );
  }
}
