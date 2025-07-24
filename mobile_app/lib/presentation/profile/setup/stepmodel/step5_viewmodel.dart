// lib/presentation/profile/setup/stepmodel/step5_viewmodel.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'base_step_viewmodel.dart';

class Step5ViewModel extends BaseStepViewModel {
  String? city;
  String? state;
  String? country;
  double? latitude;
  double? longitude;
  int? locationPreference;

  // Controllers to manage UI updates
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  Step5ViewModel(super.parent) {
    // Sync initial values with parent
    cityController.text = parent.city ?? '';
    stateController.text = parent.state ?? '';
    countryController.text = parent.country ?? '';
    locationPreference =
        parent.locationPreference ?? 50; // Default value changed to 50
  }

  @override
  bool get isRequired => false; // Step 5 is not required

  Future<void> getCurrentLocation(BuildContext context) async {
    try {
      debugPrint('Starting to get current location...');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please enable them in settings.';
      }
      debugPrint('Location services are enabled.');

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied, requesting permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied. Please enable them in settings.';
      }
      debugPrint('Location permission granted.');

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = position.latitude;
      longitude = position.longitude;
      debugPrint('Got position: lat=$latitude, lon=$longitude');

      // Reverse geocoding to get address details
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude!,
        longitude!,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        city = place.subAdministrativeArea ?? 'Unknown City';
        state = place.administrativeArea ?? 'Unknown State';
        country = place.country ?? 'Unknown Country';
        debugPrint(
          'Geocoding result: city=$city, state=$state, country=$country',
        );
      } else {
        throw 'Could not get address from coordinates.';
      }

      // Update controllers and parent viewmodel
      cityController.text = city!;
      stateController.text = state!;
      countryController.text = country!;
      parent.city = city;
      parent.state = state;
      parent.country = country;
      parent.latitude = latitude;
      parent.longitude = longitude;
      debugPrint(
        'Updated parent viewmodel and controllers with location data.',
      );

      // Notify listeners to update UI
      notifyListeners();
      debugPrint('Notified listeners to update UI.');
    } catch (e) {
      debugPrint('Error getting location: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    }
  }

  void setLocationPreference(int value) {
    locationPreference = value;
    parent.locationPreference = value;
    notifyListeners();
    debugPrint(
      'Set location preference: $value km',
    ); // Log to verify slider change
  }

  @override
  String? validate() {
    // Step 5 is not required, so no validation needed
    return null;
  }

  @override
  void saveData() {
    parent.city = city;
    parent.state = state;
    parent.country = country;
    parent.latitude = latitude;
    parent.longitude = longitude;
    // Use the latest locationPreference from parent to ensure slider value is saved
    parent.locationPreference = parent.locationPreference ?? 50;
    parent.profileData['city'] = city;
    parent.profileData['state'] = state;
    parent.profileData['country'] = country;
    parent.profileData['latitude'] = latitude;
    parent.profileData['longitude'] = longitude;
    parent.profileData['locationPreference'] =
        parent.locationPreference; // Sync with parent value
    debugPrint(
      'Saved location data to parent profileData: ${parent.profileData}',
    );
  }

  @override
  void dispose() {
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    super.dispose();
  }
}
