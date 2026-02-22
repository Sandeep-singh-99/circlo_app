import 'package:flutter/material.dart';

/// A TextField that highlights #hashtag words in the primary color as you type.
/// Uses a transparent real TextField stacked over a RichText overlay.
class HashtagTextField extends StatefulWidget {
  final TextEditingController controller;
  final int minLines;
  final String hintText;

  const HashtagTextField({
    super.key,
    required this.controller,
    this.minLines = 4,
    this.hintText = 'Write a caption… #hashtag',
  });

  @override
  State<HashtagTextField> createState() => _HashtagTextFieldState();
}

class _HashtagTextFieldState extends State<HashtagTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  List<TextSpan> _buildSpans(String text, TextStyle base, Color hashColor) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'(#\w+)');
    int last = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(
          TextSpan(text: text.substring(last, match.start), style: base),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: base.copyWith(color: hashColor, fontWeight: FontWeight.w600),
        ),
      );
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last), style: base));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hashColor = Theme.of(context).primaryColor;
    final baseStyle = TextStyle(
      fontSize: 15,
      height: 1.5,
      color: colorScheme.onSurface,
    );

    return Stack(
      children: [
        // Real (invisible) TextField – handles all input & cursor
        TextField(
          controller: widget.controller,
          maxLines: null,
          minLines: widget.minLines,
          style: baseStyle.copyWith(color: Colors.transparent),
          cursorColor: hashColor,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withAlpha(80),
              fontSize: 15,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        // Colored overlay – purely visual, ignores pointer events
        IgnorePointer(
          child: widget.controller.text.isEmpty
              ? const SizedBox.shrink()
              : RichText(
                  text: TextSpan(
                    children: _buildSpans(
                      widget.controller.text,
                      baseStyle,
                      hashColor,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
