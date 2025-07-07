import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'widgets/expandable_text.dart';

class ProfileBio extends StatelessWidget {
  final String? bio;
  final bool editable;
  final VoidCallback? onEditBio;

  const ProfileBio({
    super.key,
    this.bio,
    this.editable = false,
    this.onEditBio,
  });

  @override
  Widget build(BuildContext context) {
    if (bio == null || bio!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Only show edit button if editable, no title
        if (editable && onEditBio != null)
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.edit, size: 20, color: ProfileTheme.darkPink),
              onPressed: onEditBio,
              tooltip: "Edit Bio",
            ),
          ),
        // Bio content, centered
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          alignment: Alignment.center,
          child: ExpandableText(
            text: bio!,
            maxLines: 3,
          ),
        ),
      ],
    );
  }
}
