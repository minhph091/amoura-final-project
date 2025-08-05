import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/match/received_like_model.dart';
import '../../../core/services/profile_service.dart';
import '../../../app/di/injection.dart';

class UserProfileInfoSheet extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userAvatar;

  const UserProfileInfoSheet({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar,
  });

  @override
  State<UserProfileInfoSheet> createState() => _UserProfileInfoSheetState();
}

class _UserProfileInfoSheetState extends State<UserProfileInfoSheet> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final profileService = getIt<ProfileService>();
      final userId = int.tryParse(widget.userId);
      
      if (userId == null) {
        setState(() {
          _error = 'Invalid user ID';
          _isLoading = false;
        });
        return;
      }

      final data = await profileService.getProfileByUserId(userId);
      if (mounted) {
        setState(() {
          _profileData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: widget.userAvatar != null 
                      ? NetworkImage(widget.userAvatar!)
                      : null,
                  child: widget.userAvatar == null 
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_profileData != null)
                        Text(
                          '${_profileData!['age'] ?? 'Unknown'} years old',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load profile',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : _buildProfileContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_profileData == null) return const SizedBox.shrink();

    final profile = _profileData!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info
          _buildSection('Basic Information', [
            _buildInfoRow('Age', '${profile['age'] ?? 'Unknown'} years old'),
            _buildInfoRow('Location', profile['location']?['city'] ?? 'Unknown'),
            _buildInfoRow('Height', profile['height'] != null ? '${profile['height']} cm' : 'Unknown'),
            _buildInfoRow('Orientation', profile['orientation']?['name'] ?? 'Unknown'),
          ]),

          const SizedBox(height: 24),

          // Bio
          if (profile['bio'] != null && profile['bio'].toString().isNotEmpty)
            _buildSection('Bio', [
              Text(
                profile['bio'],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ]),

          const SizedBox(height: 24),

          // Education & Work
          _buildSection('Education & Work', [
            _buildInfoRow('Education', profile['educationLevel']?['name'] ?? 'Unknown'),
            _buildInfoRow('Job', profile['jobIndustry']?['name'] ?? 'Unknown'),
          ]),

          const SizedBox(height: 24),

          // Lifestyle
          _buildSection('Lifestyle', [
            _buildInfoRow('Drinking', profile['drinkStatus']?['name'] ?? 'Unknown'),
            _buildInfoRow('Smoking', profile['smokeStatus']?['name'] ?? 'Unknown'),
          ]),

          const SizedBox(height: 24),

          // Languages
          if (profile['languages'] != null && (profile['languages'] as List).isNotEmpty)
            _buildSection('Languages', [
              Text(
                (profile['languages'] as List).map((e) => e['name']).join(', '),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ]),

          const SizedBox(height: 24),

          // Interests
          if (profile['interests'] != null && (profile['interests'] as List).isNotEmpty)
            _buildSection('Interests', [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (profile['interests'] as List).map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      interest['name'],
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),

          const SizedBox(height: 24),

          // Pets
          if (profile['pets'] != null && (profile['pets'] as List).isNotEmpty)
            _buildSection('Pets', [
              Text(
                (profile['pets'] as List).map((e) => e['name']).join(', '),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
} 