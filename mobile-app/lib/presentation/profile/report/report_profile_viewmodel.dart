import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ReportProfileViewModel extends ChangeNotifier {
  String? _selectedReason;
  String? _details;
  List<File> _selectedImages = [];
  bool _isLoading = false;

  String? get selectedReason => _selectedReason;
  String? get details => _details;
  List<File> get selectedImages => _selectedImages;
  bool get isLoading => _isLoading;
  bool get isFormValid => _selectedReason != null && (_details?.length ?? 0) >= 10;

  final List<String> reportReasons = [
    'Inappropriate content',
    'Fake profile',
    'Harassment or bullying',
    'Violent or threatening content',
    'Hate speech',
    'Spam',
    'Other',
  ];

  void setSelectedReason(String? reason) {
    _selectedReason = reason;
    notifyListeners();
  }

  void setDetails(String details) {
    _details = details;
    notifyListeners();
  }

  Future<void> selectImage(BuildContext context) async {
    if (_selectedImages.length >= 4) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImages.add(File(image.path));
        notifyListeners();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void removeImage(int index) {
    if (index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  Future<bool> submitReport(String userId) async {
    if (!isFormValid) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // This would be an API call in a real application
      // For now we'll simulate a delay and return success
      await Future.delayed(const Duration(seconds: 1));

      // Reset the form after successful submission
      _selectedReason = null;
      _details = null;
      _selectedImages = [];
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
