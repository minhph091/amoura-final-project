import 'package:flutter/foundation.dart';
import '../profile/interest_model.dart';
import '../profile/photo_model.dart';
import '../profile/profile_model.dart';

class UserRecommendationModel {
  final int userId;
  final String username;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final int? age;
  final int? height;
  final String? sex;
  final String? bio;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<InterestModel> interests;
  final List<PetModel> pets;
  final List<PhotoModel> photos;
  // Optional display-only fields for discovery details (page 2)
  final String? jobIndustryName;
  final String? educationLevelName;
  final String? drinkStatusName;
  final String? smokeStatusName;

  UserRecommendationModel({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.age,
    this.height,
    this.sex,
    this.bio,
    this.location,
    this.latitude,
    this.longitude,
    required this.interests,
    required this.pets,
    required this.photos,
    this.jobIndustryName,
    this.educationLevelName,
    this.drinkStatusName,
    this.smokeStatusName,
  });

  factory UserRecommendationModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle latitude/longitude - convert 0.0 to null
      final rawLat = json['latitude'];
      final rawLon = json['longitude'];
      
      double? latitude;
      double? longitude;
      
      if (rawLat != null && rawLat is num && rawLat != 0.0) {
        latitude = rawLat.toDouble();
      }
      
      if (rawLon != null && rawLon is num && rawLon != 0.0) {
        longitude = rawLon.toDouble();
      }
      
      return UserRecommendationModel(
        userId: json['userId'] as int,
        username: json['username'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        dateOfBirth: json['dateOfBirth'] != null 
            ? DateTime.parse(json['dateOfBirth'] as String)
            : null,
        age: json['age'] as int?,
        height: json['height'] as int?,
        sex: json['sex'] as String?,
        bio: json['bio'] as String?,
        location: json['location'] as String?,
        latitude: latitude,
        longitude: longitude,
        interests: (json['interests'] as List<dynamic>?)
            ?.map((e) => InterestModel.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        pets: (json['pets'] as List<dynamic>?)
            ?.map((e) => PetModel.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        photos: (json['photos'] as List<dynamic>?)
            ?.map((e) => PhotoModel.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        // Some backends return nested objects with 'name' for these attributes
        jobIndustryName: (json['jobIndustry'] is Map<String, dynamic>)
            ? (json['jobIndustry']['name'] as String?)
            : json['jobIndustryName'] as String?,
        educationLevelName: (json['educationLevel'] is Map<String, dynamic>)
            ? (json['educationLevel']['name'] as String?)
            : json['educationLevelName'] as String?,
        drinkStatusName: (json['drinkStatus'] is Map<String, dynamic>)
            ? (json['drinkStatus']['name'] as String?)
            : json['drinkStatusName'] as String?,
        smokeStatusName: (json['smokeStatus'] is Map<String, dynamic>)
            ? (json['smokeStatus']['name'] as String?)
            : json['smokeStatusName'] as String?,
      );
    } catch (e) {
      debugPrint('UserRecommendationModel: Error parsing from JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'userId': userId,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'age': age,
        'height': height,
        'sex': sex,
        'bio': bio,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'interests': interests.map((e) => e.toJson()).toList(),
        'pets': pets.map((e) => e.toJson()).toList(),
        'photos': photos.map((e) => e.toJson()).toList(),
        'jobIndustryName': jobIndustryName,
        'educationLevelName': educationLevelName,
        'drinkStatusName': drinkStatusName,
        'smokeStatusName': smokeStatusName,
      };
    } catch (e) {
      debugPrint('UserRecommendationModel: Error converting to JSON: $e');
      rethrow;
    }
  }

  /// Convert to ProfileModel for UI compatibility
  ProfileModel toProfileModel() {
    try {
      return ProfileModel(
        userId: userId,
        dateOfBirth: dateOfBirth,
        height: height,
        sex: sex,
        bio: bio,
        locationPreference: null, // Not available in recommendation
      );
    } catch (e) {
      debugPrint('UserRecommendationModel: Error converting to ProfileModel: $e');
      rethrow;
    }
  }

  /// Get full name
  String get fullName {
    try {
      return '$firstName $lastName';
    } catch (e) {
      debugPrint('UserRecommendationModel: Error getting full name: $e');
      return 'Unknown User';
    }
  }
}

class PetModel {
  final int id;
  final String name;

  PetModel({
    required this.id,
    required this.name,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    try {
      return PetModel(
        id: json['id'] as int,
        name: json['name'] as String,
      );
    } catch (e) {
      debugPrint('PetModel: Error parsing from JSON: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'name': name,
      };
    } catch (e) {
      debugPrint('PetModel: Error converting to JSON: $e');
      rethrow;
    }
  }
} 
