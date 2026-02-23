import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kPurple = Color(0xFF6C63FF);

/// Animated search bar with a purple focus border,
/// clear (×) button, and a slide-in "Cancel" button.
class SearchBarField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final String query;
  final Animation<double> cancelWidth;
  final VoidCallback onCancel;
  final ValueChanged<String> onSubmitted;

  const SearchBarField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.query,
    required this.cancelWidth,
    required this.onCancel,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          // ── Text input ──────────────────────────────────────
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 42,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(13),
                border: isSearching
                    ? Border.all(
                        color: _kPurple.withValues(alpha: 0.6),
                        width: 1.5,
                      )
                    : Border.all(color: Colors.transparent),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.35)
                        : Colors.black38,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: isSearching
                        ? _kPurple
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : Colors.black38),
                  ),
                  suffixIcon: query.isNotEmpty
                      ? GestureDetector(
                          onTap: controller.clear,
                          child: Icon(
                            Icons.cancel_rounded,
                            size: 18,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.black38,
                          ),
                        )
                      : null,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ),

          // ── Animated Cancel button ───────────────────────────
          AnimatedBuilder(
            animation: cancelWidth,
            builder: (context, child) => SizedBox(
              width: cancelWidth.value,
              child: Opacity(
                opacity: (cancelWidth.value / 72).clamp(0.0, 1.0),
                child: GestureDetector(
                  onTap: onCancel,
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kPurple,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
