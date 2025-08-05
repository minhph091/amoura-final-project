import 'package:flutter/foundation.dart';
import '../profile/interest_model.dart';
import '../profile/photo_model.dart';

class ReceivedLikeModel {
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
  final DateTime likedAt;

  ReceivedLikeModel({
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
    required this.likedAt,
  });

  factory ReceivedLikeModel.fromJson(Map<String, dynamic> json) {
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
      
      return ReceivedLikeModel(
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
        likedAt: DateTime.parse(json['likedAt'] as String),
      );
    } catch (e) {
      debugPrint('ReceivedLikeModel: Error parsing from JSON: $e');
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
        'likedAt': likedAt.toIso8601String(),
      };
    } catch (e) {
      debugPrint('ReceivedLikeModel: Error converting to JSON: $e');
      rethrow;
    }
  }

  /// Get full name
  String get fullName {
    try {
      return '$firstName $lastName';
    } catch (e) {
      debugPrint('ReceivedLikeModel: Error getting full name: $e');
      return 'Unknown User';
    }
  }

  /// Get primary photo URL
  String? get primaryPhotoUrl {
    try {
      return photos.isNotEmpty ? photos.first.url : null;
    } catch (e) {
      debugPrint('ReceivedLikeModel: Error getting primary photo URL: $e');
      return null;
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