import 'package:flutter/material.dart';
import '../../config/language/app_localizations.dart';
import 'validation_util.dart';

class LocalizedValidation {
  final AppLocalizations localizations;

  LocalizedValidation(this.localizations);

  static LocalizedValidation of(BuildContext context) {
    return LocalizedValidation(AppLocalizations.of(context));
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return localizations.translate('email_required');
    }
    if (!ValidationUtil.isEmail(value)) {
      return localizations.translate('email_invalid');
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return localizations.translate('phone_required');
    }
    if (!ValidationUtil.isPhoneNumber(value)) {
      return localizations.translate('phone_invalid');
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return localizations.translate('password_required');
    }
    if (!ValidationUtil.isPasswordValid(value)) {
      return localizations.translate('password_invalid');
    }
    return null;
  }

  String? validateConfirmPassword(String? password, String? confirm) {
    if (confirm == null || confirm.trim().isEmpty) {
      return localizations.translate('confirm_password_required');
    }
    if (password != confirm) {
      return localizations.translate('passwords_dont_match');
    }
    return null;
  }

  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return localizations.translate('first_name_required');
    }
    if (value.trim().length < 2) {
      return localizations.translate('first_name_too_short');
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return localizations.translate('last_name_required');
    }
    if (value.trim().length < 2) {
      return localizations.translate('last_name_too_short');
    }
    return null;
  }

  String? validateBirthday(DateTime? value) {
    if (value == null) {
      return localizations.translate('birthday_required');
    }

    final now = DateTime.now();
    final age = now.year - value.year;

    if (age < 18) {
      return localizations.translate('age_minimum_18');
    }
    if (age > 120) {
      return localizations.translate('age_maximum_120');
    }

    return null;
  }

  String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return localizations.translate('otp_required');
    }
    if (value.length != 6) {
      return localizations.translate('otp_invalid_length');
    }
    return null;
  }
}
