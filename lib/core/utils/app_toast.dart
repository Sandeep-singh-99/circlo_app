import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global toast utility — matches the bookmark toast design.
abstract class AppToast {
  /// Show a themed floating toast.
  ///
  /// [icon] — optional leading icon widget.
  /// [message] — the text to display.
  /// [isError] — when true uses a red background; otherwise uses the
  ///             adaptive dark/light theme colour.
  /// [duration] — how long the snackbar stays visible (default 2 s).
  static void show(
    BuildContext context, {
    Widget? icon,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor;
    final Color textColor;

    if (isError) {
      bgColor = Colors.redAccent;
      textColor = Colors.white;
    } else {
      bgColor = isDark ? Colors.white : Colors.black87;
      textColor = isDark ? Colors.black87 : Colors.white;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[icon, const SizedBox(width: 10)],
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: duration,
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }
}
