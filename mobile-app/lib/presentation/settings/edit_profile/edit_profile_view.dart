import 'package:flutter/material.dart';
import 'widgets/photo_selector.dart';
import 'widgets/interest_selector.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Split sections into widgets: photos, basic info, interests, pets, languages, etc.
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        children: const [
          PhotoSelector(),
          // ...other section widgets (e.g. BasicInfoSection(), LanguageSelector(), PetSelector(), etc.)
          InterestSelector(),
        ],
      ),
    );
  }
}