// lib/presentation/settings/security/account_management/account_management_viewmodel.dart

import 'package:flutter/material.dart';

class AccountManagementViewModel extends ChangeNotifier {
  bool _iUnderstandTheRisk = false;
  bool get iUnderstandTheRisk => _iUnderstandTheRisk;

  void setIUnderstandTheRisk(bool value) {
    _iUnderstandTheRisk = value;
    notifyListeners();
  }

  void resetConfirmation() {
    _iUnderstandTheRisk = false;
    notifyListeners();
  }

  void onDeactivateConfirmed(BuildContext context) {
    // Placeholder cho logic backend
    print('Account Deactivated');
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }

  void onDeleteConfirmed(BuildContext context) {
    // Placeholder cho logic backend
    print('Account Permanently Deleted');
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }
}