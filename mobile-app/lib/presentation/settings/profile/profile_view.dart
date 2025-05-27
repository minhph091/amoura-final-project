import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_gallery.dart';
import 'widgets/profile_info.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Profile data provided via Provider or props (not hardcoded)
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        children: const [
          ProfileHeader(),
          ProfileGallery(),
          ProfileInfo(),
        ],
      ),
    );
  }
}