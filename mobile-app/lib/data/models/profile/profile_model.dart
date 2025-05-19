// lib/data/models/profile/profile_model.dart

import 'body_type_model.dart';
import 'orientation_model.dart';
import 'job_industry_model.dart';
import 'drink_status_model.dart';
import 'smoke_status_model.dart';
import 'education_level_model.dart';

// Model hồ sơ người dùng (Profile)
class ProfileModel {
  final int userId;
  final DateTime? dateOfBirth;
  final int? height;
  final BodyTypeModel? bodyType;
  final Sex sex;
  final OrientationModel? orientation;
  final JobIndustryModel? jobIndustry;
  final DrinkStatusModel? drinkStatus;
  final SmokeStatusModel? smokeStatus;
  final bool? interestedInNewLanguage;
  final EducationLevelModel? educationLevel;
  final bool? dropOut;
  final int? locationPreference; // bán kính tìm kiếm
  final String? bio;

  ProfileModel({
    required this.userId,
    this.dateOfBirth,
    this.height,
    this.bodyType,
    required this.sex,
    this.orientation,
    this.jobIndustry,
    this.drinkStatus,
    this.smokeStatus,
    this.interestedInNewLanguage,
    this.educationLevel,
    this.dropOut,
    this.locationPreference,
    this.bio,
  });
}

// Enum giới tính
enum Sex { male, female }

Sex sexFromString(String value) {
  switch (value) {
    case 'male':
      return Sex.male;
    case 'female':
      return Sex.female;
    default:
      return Sex.male;
  }
}