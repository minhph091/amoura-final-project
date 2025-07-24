// lib/data/models/profile/location_model.dart

// Model vị trí người dùng (Location)
class LocationModel {
  final int userId;
  final double latitudes;
  final double longitudes;
  final String country;
  final String? state;
  final String? city;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LocationModel({
    required this.userId,
    required this.latitudes,
    required this.longitudes,
    required this.country,
    this.state,
    this.city,
    required this.createdAt,
    this.updatedAt,
  });
}
