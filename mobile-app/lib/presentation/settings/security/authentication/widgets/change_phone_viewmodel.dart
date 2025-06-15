// filepath: c:\amoura-final-project\mobile-app\lib\presentation\settings\security\authentication\widgets\change_phone_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:amoura/data/repositories/user_repository.dart';
import '../../../../../core/utils/validation_util.dart';

class ChangePhoneViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  ChangePhoneViewModel({required this.userRepository});

  // Controllers
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Error messages
  String? _passwordError;
  String? _phoneError;

  String? get passwordError => _passwordError;
  String? get phoneError => _phoneError;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Change phone number with password verification
  Future<void> changePhoneNumber(BuildContext context) async {
    if (formKey.currentState?.validate() != true) {
      return;
    }

    _setLoading(true);

    try {
      // TODO: Call actual API to change phone number
      // await userRepository.changePhoneNumber(phoneController.text.trim(), passwordController.text);
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Phone number changed successfully!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Return to previous screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      _passwordError = "Incorrect password or unable to change phone number. Please try again.";
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
