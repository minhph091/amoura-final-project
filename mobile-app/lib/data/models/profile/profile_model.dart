// lib/data/models/profile/profile_model.dart

import 'body_type_model.dart';
import 'orientation_model.dart';
import 'job_industry_model.dart';
import 'drink_status_model.dart';
import 'smoke_status_model.dart';
import 'education_level_model.dart';

class ProfileModel {
  final int userId;
  final DateTime? dateOfBirth;
  final int? height;
  final BodyTypeModel? bodyType;
  final String? sex;
  final OrientationModel? orientation;
  final JobIndustryModel? jobIndustry;
  final DrinkStatusModel? drinkStatus;
  final SmokeStatusModel? smokeStatus;
  final bool? interestedInNewLanguage;
  final EducationLevelModel? educationLevel;
  final bool? dropOut;
  final int? locationPreference;
  final String? bio;

  ProfileModel({
    required this.userId,
    this.dateOfBirth,
    this.height,
    this.bodyType,
    this.sex,
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