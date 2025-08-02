import 'package:flutter/material.dart';
import '../../../data/models/profile/interest_model.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import '../../../core/services/profile_service.dart';
import '../../../app/di/injection.dart';
import 'profile_detail_bottom_sheet.dart';

class ProfileDetailPage extends StatefulWidget {
  final UserRecommendationModel profile;
  final List<InterestModel> interests;
  final String? distance;

  const ProfileDetailPage({
    super.key,
    required this.profile,
    required this.interests,
    this.distance,
  });

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
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
      final data = await profileService.getProfileByUserId(widget.profile.userId);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profile Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading profile',
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadProfileData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Sử dụng dữ liệu từ API nếu có, nếu không thì dùng dữ liệu cũ
    final profileData = _profileData ?? {
      'bio': widget.profile.bio ?? '-',
      'height': widget.profile.height != null ? widget.profile.height.toString() : '-',
      'sex': widget.profile.sex ?? '-',
      'location': widget.profile.location != null ? {'city': widget.profile.location} : null,
      'interests': widget.interests.map((e) => {'name': e.name}).toList(),
      'pets': widget.profile.pets.map((e) => {'name': e.name}).toList(),
      'orientation': null,
      'jobIndustry': null,
      'educationLevel': null,
      'languages': [],
      'drinkStatus': null,
      'smokeStatus': null,
    };

    return SingleChildScrollView(
      child: ProfileDetailBottomSheet(
        profile: profileData,
        distance: widget.distance,
      ),
    );
  }
} 