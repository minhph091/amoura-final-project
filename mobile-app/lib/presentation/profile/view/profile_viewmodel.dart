// lib/presentation/profile/view/profile_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/usecases/profile/get_profile_usecase.dart';

class ProfileViewModel extends ChangeNotifier {
  final GetProfileUseCase _getProfileUseCase = GetIt.I<GetProfileUseCase>();

  Map<String, dynamic>? profile;
  bool isLoading = false;
  String? error;

  // Load profile data when the view is initialized
  Future<void> loadProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Fetch profile data from the API endpoint GET /profiles/me using the use case
      profile = await _getProfileUseCase.execute();
      
      // Log profile data for debugging
      print('Profile loaded successfully: $profile');
      
      // Check appearance data specifically
      if (profile != null) {
        print('Appearance Data Check:');
        print('Body Type: ${profile!['bodyType']}');
        print('Height: ${profile!['height']}');
        
        // Validate appearance data structure
        if (profile!['bodyType'] != null) {
          print('Body Type Structure: ${profile!['bodyType'].runtimeType}');
          if (profile!['bodyType'] is Map) {
            print('Body Type Name: ${profile!['bodyType']['name']}');
          }
        }
      }
    } catch (e) {
      // Comment: Handle any errors that occur during the API call and store the error message
      error = 'Failed to load profile: $e';
      print('Error in loadProfile: $error');
    } finally {
      // Comment: Ensure the loading state is reset and notify listeners to update the UI
      isLoading = false;
      notifyListeners();
    }
  }
}