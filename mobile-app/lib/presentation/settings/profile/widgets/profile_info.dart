import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({super.key});
  @override
  Widget build(BuildContext context) {
    // Display info such as bio, age, gender, etc from model/provider
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(profile.bio ?? '', style: ...)
          // ...more profile fields
        ],
      ),
    );
  }
}