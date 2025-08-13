import 'package:flutter/material.dart';

class ProfileDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String? distance;

  const ProfileDetailBottomSheet({
    super.key,
    required this.profile,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = profile['orientation']?['name'] ?? '-';
    final bio = profile['bio'] ?? '-';
    final height = profile['height'] != null ? '${profile['height']} cm' : '-';
    final job = profile['jobIndustry']?['name'] ?? '-';
    final education = profile['educationLevel']?['name'] ?? '-';
    final city = profile['location']?['city'] ?? '-';
    final languageList = (profile['languages'] as List?)?.map((e) => e['name']).join(', ') ?? '-';
    final drink = profile['drinkStatus']?['name'] ?? '-';
    final smoke = profile['smokeStatus']?['name'] ?? '-';
    final petList = (profile['pets'] as List?)?.map((e) => e['name']).join(', ') ?? '-';
    final interestList = (profile['interests'] as List?)?.map((e) => e['name']).toList() ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orientation
          _sectionTitle(context, 'Orientation'),
          const SizedBox(height: 8),
          _infoRowWithIcon(Icons.transgender, orientation),

          const SizedBox(height: 18),
          // Bio
          _sectionTitle(context, 'Bio'),
          const SizedBox(height: 8),
          Text(bio, style: Theme.of(context).textTheme.bodyMedium),

          const SizedBox(height: 18),
          // Main Info
          _sectionTitle(context, 'Main Info'),
          const SizedBox(height: 8),
          _infoRowWithIcon(Icons.location_on, distance ?? '-','Distance'),
          _infoRowWithIcon(Icons.height, height,'Height'),
          _infoRowWithIcon(Icons.work, job,'Job'),
          _infoRowWithIcon(Icons.school, education,'Education'),
          _infoRowWithIcon(Icons.home, city,'City'),
          _infoRowWithIcon(Icons.language, languageList,'Language'),

          const SizedBox(height: 18),
          // Lifestyle
          _sectionTitle(context, 'Lifestyle'),
          const SizedBox(height: 8),
          _infoRowWithIcon(Icons.local_bar, drink,'Drink'),
          _infoRowWithIcon(Icons.smoking_rooms, smoke,'Smoke'),
          _infoRowWithIcon(Icons.pets, petList,'Pet'),

          const SizedBox(height: 18),
          // Interests
          _sectionTitle(context, 'Interests'),
          const SizedBox(height: 8),
          interestList.isNotEmpty
              ? Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interestList.map((name) => Chip(
              label: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              backgroundColor: Colors.pink[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            )).toList(),
          )
              : const Text('-', style: TextStyle(color: Colors.grey)),

          const SizedBox(height: 32),
          // 3 nút chia sẻ, chặn, báo cáo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(
                context,
                icon: Icons.share,
                label: 'Share',
                color: Colors.pinkAccent,
                onPressed: () {},
              ),
              _actionButton(
                context,
                icon: Icons.block,
                label: 'Block',
                color: Colors.deepPurple,
                onPressed: () {},
              ),
              _actionButton(
                context,
                icon: Icons.report,
                label: 'Report',
                color: Colors.redAccent,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.pinkAccent,
        fontSize: 18,
      ),
    );
  }

  Widget _infoRowWithIcon(IconData icon, String value, [String? label]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.pinkAccent, size: 20),
          const SizedBox(width: 10),
          if (label != null) ...[
            Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          ],
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.white),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        elevation: 2,
      ),
    );
  }
} 

