import 'package:flutter/material.dart';

class ProfileBioSection extends StatefulWidget {
  final String bio;
  final int initialMaxLines;

  const ProfileBioSection({
    Key? key,
    required this.bio,
    this.initialMaxLines = 2,
  }) : super(key: key);

  @override
  State<ProfileBioSection> createState() => _ProfileBioSectionState();
}

class _ProfileBioSectionState extends State<ProfileBioSection> {
  late bool _isExpanded;
  late TextPainter _textPainter;
  late bool _needsToShowMore;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
    _setupTextPainter();
  }

  void _setupTextPainter() {
    // Create a TextPainter to determine if the text needs to be expandable
    final textSpan = TextSpan(
      text: widget.bio,
      style: const TextStyle(fontSize: 15),
    );
    _textPainter = TextPainter(
      text: textSpan,
      maxLines: widget.initialMaxLines,
      textDirection: TextDirection.ltr,
    );

    // Default to not showing "more" until we measure in didChangeDependencies
    _needsToShowMore = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Measure the text width based on the available width
    // We need to do this in didChangeDependencies because it needs the layout constraints
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Get the available width for text (accounting for padding)
      final width = MediaQuery.of(context).size.width - 32; // 16px padding on each side

      // Update the painter and layout with the constraints
      _textPainter.layout(maxWidth: width);

      // Check if the text overflows the specified number of lines
      final didExceedMaxLines = _textPainter.didExceedMaxLines;

      if (mounted && didExceedMaxLines != _needsToShowMore) {
        setState(() {
          _needsToShowMore = didExceedMaxLines;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bio text
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Container(
            width: double.infinity,
            child: Text(
              widget.bio,
              style: const TextStyle(fontSize: 15),
              maxLines: _isExpanded ? null : widget.initialMaxLines,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
        ),

        // Show more / Show less button, only if needed
        if (_needsToShowMore)
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
            ),
            child: Text(
              _isExpanded ? 'Show less' : 'Show more...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
