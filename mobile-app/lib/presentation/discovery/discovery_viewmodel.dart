// lib/presentation/discovery/discovery_viewmodel.dart
// Holds state for DiscoveryView

import 'package:flutter/material.dart';

import '../../data/models/profile/interest_model.dart';
import '../../data/models/profile/profile_model.dart';

class DiscoveryViewModel extends ChangeNotifier {
  List<ProfileModel> _profiles = [];
  List<InterestModel> _interests = [];

  List<ProfileModel> get profiles => _profiles;
  List<InterestModel> get interests => _interests;

  void setProfiles(List<ProfileModel> profiles) {
    _profiles = profiles;
    notifyListeners();
  }

  void setInterests(List<InterestModel> interests) {
    _interests = interests;
    notifyListeners();
  }
}