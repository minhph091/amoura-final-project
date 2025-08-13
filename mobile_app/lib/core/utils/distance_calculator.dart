// ignore_for_file: unused_import
import 'package:amoura/config/language/app_localizations.dart';
import 'dart:math';

class DistanceCalculator {
  /// Calculate distance between two points using Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert degrees to radians
    final double lat1Rad = _degreesToRadians(lat1);
    final double lon1Rad = _degreesToRadians(lon1);
    final double lat2Rad = _degreesToRadians(lat2);
    final double lon2Rad = _degreesToRadians(lon2);

    // Differences in coordinates
    final double deltaLat = lat2Rad - lat1Rad;
    final double deltaLon = lon2Rad - lon1Rad;

    // Haversine formula
    final double a =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Format distance for display (localized)
  /// Returns formatted string like "Cách xa 12 km" hoặc "Away by 12 km"
  static String formatDistance(
    double distanceInKm, {
    required String Function(String key) tr,
  }) {
    final int roundedDistance = distanceInKm.round();
    return '${tr('away_by')} $roundedDistance km';
  }

  /// Check if coordinates are valid (not null and not 0.0)
  static bool _isValidCoordinate(double? coord) {
    return coord != null && coord != 0.0;
  }

  /// Get distance display text with proper formatting (localized)
  /// Pass a translation function (e.g. AppLocalizations.of(context).translate)
  static String getDistanceText(
    double? lat1,
    double? lon1,
    double? lat2,
    double? lon2, {
    required String Function(String key) tr,
  }) {
    if (!_isValidCoordinate(lat1) ||
        !_isValidCoordinate(lon1) ||
        !_isValidCoordinate(lat2) ||
        !_isValidCoordinate(lon2)) {
      return tr('distance_unavailable');
    }
    final double distance = calculateDistance(lat1!, lon1!, lat2!, lon2!);
    return formatDistance(distance, tr: tr);
  }
}
