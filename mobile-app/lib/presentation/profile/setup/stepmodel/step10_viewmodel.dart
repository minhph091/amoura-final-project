// lib/presentation/profile/setup/stepmodel/step10_viewmodel.dart
import 'dart:io';
import '../../../../core/services/setup_profile_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import 'base_step_viewmodel.dart';

class Step10ViewModel extends BaseStepViewModel {
  String? bio; // User's bio
  List<Map<String, dynamic>> additionalPhotos = []; // List of photo details {path, url, id}
  final SetupProfileService _setupProfileService;
  bool isUploading = false; // Track upload state
  String? errorMessage; // Store error messages if upload fails

  Step10ViewModel(super.parent, {SetupProfileService? setupProfileService})
      : _setupProfileService = setupProfileService ?? SetupProfileService() {
    bio = parent.bio; // Initialize bio from parent view model
    additionalPhotos = parent.additionalPhotos?.map((url) => {'url': url}).toList() ?? []; // Initialize from parent
  }

  // Upload a single photo to the API and return its details
  Future<Map<String, dynamic>> uploadPhoto(String photoPath) async {
    isUploading = true;
    errorMessage = null;
    notifyListeners(); // Notify UI about upload state change

    try {
      final file = File(photoPath);
      // [API Integration] Upload photo to /profiles/photos/highlights endpoint
      // - Endpoint: /profiles/photos/highlights
      // - Method: POST
      // - Body: Multipart file (photo)
      // - Response: {id: int, url: string, type: string, uploadedAt: string}
      final response = await _setupProfileService.uploadPhoto(file, ApiEndpoints.uploadHighlights);
      if (response['url'] != null && response['id'] != null) {
        return {
          'path': photoPath,
          'url': response['url'] as String,
          'id': response['id'].toString(), // Store photoId as string for consistency
        };
      } else {
        throw Exception('Photo upload failed: Missing URL or ID');
      }
    } catch (e) {
      errorMessage = 'Failed to upload photo: $e';
      print('Error uploading photo: $e');
      rethrow;
    } finally {
      isUploading = false;
      notifyListeners(); // Notify UI after upload completes (success or failure)
    }
  }

  // Delete a specific highlight photo using its photoId
  Future<void> deletePhoto(String photoId) async {
    try {
      // [API Integration] Delete photo from /profiles/photos/highlights/{photoId} endpoint
      // - Endpoint: /profiles/photos/highlights/{photoId}
      // - Method: DELETE
      // - Headers: Authorization Bearer <accessToken>
      // - Response: 200 OK or 404 if not found
      print('Deleting photo with ID: $photoId'); // Debug log to verify photoId
      await _setupProfileService.deletePhoto(ApiEndpoints.deleteHighlight(int.parse(photoId)));
      additionalPhotos.removeWhere((photo) => photo['id'] == photoId);
      notifyListeners(); // Notify UI after successful deletion
    } catch (e) {
      print('Error deleting photo: $e');
      throw Exception('Failed to delete photo: $e');
    }
  }

  // Update bio
  void setBio(String value) {
    bio = value;
    parent.bio = value; // Sync with parent view model
    notifyListeners();
  }

  // Add a photo to the list after uploading
  Future<void> addPhoto(String photoPath) async {
    if (additionalPhotos.length < 4) { // Max 4 photos
      final photoDetails = await uploadPhoto(photoPath);
      additionalPhotos.add(photoDetails);
      notifyListeners(); // Notify UI after adding photo
    }
  }

  // Replace an existing photo
  Future<void> replacePhoto(String oldPhotoId, String newPhotoPath) async {
    await deletePhoto(oldPhotoId);
    if (additionalPhotos.length < 4) { // Ensure max limit is respected
      final photoDetails = await uploadPhoto(newPhotoPath);
      additionalPhotos.add(photoDetails); // Add new photo after deletion
      notifyListeners(); // Notify UI after replacement
    }
  }

  // Get list of uploaded photo URLs
  List<String> getUploadedPhotoUrls() {
    return additionalPhotos.map((photo) => photo['url'] as String).toList();
  }

  @override
  bool get isRequired => false; // Step 10 is optional

  @override
  String? validate() {
    return null; // No validation required
  }

  @override
  void saveData() {
    parent.bio = bio;
    parent.profileData['bio'] = bio;
    parent.additionalPhotos = getUploadedPhotoUrls(); // Save URLs to parent
  }
}