class LikedUserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final int age;
  final String location;
  final String coverImageUrl;
  final String avatarUrl;
  final String bio;
  final List<String> photoUrls;
  final bool isVip;
  final Map<String, dynamic>? profileDetails;

  const LikedUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.age,
    required this.location,
    required this.coverImageUrl,
    required this.avatarUrl,
    required this.bio,
    required this.photoUrls,
    this.isVip = false,
    this.profileDetails,
  });

  String get fullName => '$firstName $lastName';
}

