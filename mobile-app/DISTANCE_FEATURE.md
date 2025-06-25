# Distance Calculation Feature

## Overview

This feature calculates and displays the distance between the current user and other users in the discovery view. The distance is calculated using the Haversine formula and displayed in kilometers.

## Implementation Details

### Backend

- **Location Storage**: User locations are stored in the `locations` table with `latitudes` and `longitudes` fields
- **API Response**: The `/profiles/me` endpoint returns location data in the `location` object
- **Recommendations**: The `/matching/recommendations` endpoint includes `latitude` and `longitude` for each recommended user

### Mobile App

- **Distance Calculator**: `lib/core/utils/distance_calculator.dart` contains the Haversine formula implementation
- **Profile Service**: `lib/core/services/profile_service.dart` fetches current user's location
- **Discovery ViewModel**: `lib/presentation/discovery/discovery_viewmodel.dart` calculates distances for each profile
- **UI Display**: Distance is shown below the location in the profile card as text

## Features

- **Real-time Calculation**: Distance is calculated for each profile as it's displayed
- **Simple Formatting**: Distances are rounded to nearest kilometer and displayed as "Cách xa X km"
- **Error Handling**: Shows "Distance unavailable" when location data is missing or invalid (0.0 coordinates)
- **Performance**: Uses efficient Haversine formula for accurate calculations
- **Backend Compatibility**: Handles both null and 0.0 coordinate values from backend

## Usage

1. Users must have location data in their profile
2. Distance is automatically calculated and displayed in discovery view
3. Distance updates as users swipe through different profiles

## Testing

1. Build and run the mobile app
2. Ensure users have location data in their profiles
3. Navigate to discovery view
4. Swipe through profiles to see distance calculations
5. Check console logs for debug information

## Technical Notes

- Uses Haversine formula for accurate spherical distance calculation
- Handles null coordinates and 0.0 values gracefully
- Formats distances as rounded kilometers with "Cách xa" prefix
- Maintains existing UI design without breaking changes
- Compatible with existing backend without modifications

## Display Format

- **Example**: "Cách xa 623 km"
- **No decimals**: All distances are rounded to nearest kilometer
- **Text only**: No icons, just clean text display

```bash
flutter test test/distance_calculator_test.dart
```
