import 'package:flutter/material.dart';
import '../../setup/theme/setup_profile_theme.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 2,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.text,
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
            style: ProfileTheme.getDescriptionStyle(context),
          ),
          secondChild: Text(
            widget.text,
            style: ProfileTheme.getDescriptionStyle(context),
          ),
          crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        if (widget.text.split("\n").length > widget.maxLines ||
            (TextPainter(
                text: TextSpan(text: widget.text, style: ProfileTheme.getDescriptionStyle(context)),
                maxLines: widget.maxLines,
                textDirection: TextDirection.ltr
            )
              ..layout(maxWidth: MediaQuery.of(context).size.width - 40))
                .didExceedMaxLines)
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: Text(
                _expanded ? "Show Less" : "Show More...",
                style: TextStyle(
                  color: ProfileTheme.darkPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}