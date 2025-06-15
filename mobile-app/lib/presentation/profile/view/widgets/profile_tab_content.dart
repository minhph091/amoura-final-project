import 'package:flutter/material.dart';
import '../../../../domain/models/match/liked_user_model.dart';

enum ProfileTabType {
  about,
  photos,
}

class ProfileTabContent extends StatelessWidget {
  final ProfileTabType type;
  final LikedUserModel user;

  const ProfileTabContent({
    Key? key,
    required this.type,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ProfileTabType.about:
        return _buildAboutTab(context);
      case ProfileTabType.photos:
        return _buildPhotosTab(context);
    }
  }

  Widget _buildAboutTab(BuildContext context) {
    final details = user.profileDetails ?? {};

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 16),

        // Basic Information Section
        _buildSection(
          context,
          title: 'Basic Information',
          icon: Icons.person_outline,
          children: [
            if (details.containsKey('height'))
              _buildDetailItem('Height', details['height']),
            if (details.containsKey('occupation'))
              _buildDetailItem('Occupation', details['occupation']),
            if (details.containsKey('education'))
              _buildDetailItem('Education', details['education']),
          ],
        ),

        // Interests Section
        if (details.containsKey('interests'))
          _buildSection(
            context,
            title: 'Interests',
            icon: Icons.favorite_outline,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (details['interests'] as List<dynamic>? ?? [])
                  .map((interest) => Chip(
                        label: Text(interest.toString()),
                        labelStyle: const TextStyle(fontSize: 12),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ))
                  .toList(),
            ),
          ),

        // Languages Section
        if (details.containsKey('languages'))
          _buildSection(
            context,
            title: 'Languages',
            icon: Icons.language,
            children: (details['languages'] as List<dynamic>? ?? [])
                .map((language) => _buildDetailItem('Speaks', language.toString()))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildPhotosTab(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: user.photoUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullScreenImage(context, user.photoUrls, index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(user.photoUrls[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    List<Widget>? children,
    Widget? child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Section content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child ?? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children ?? [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, List<String> imageUrls, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PageView.builder(
            itemCount: imageUrls.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: Hero(
                    tag: 'image_${imageUrls[index]}',
                    child: Image.network(
                      imageUrls[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
