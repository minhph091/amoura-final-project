import 'package:flutter/foundation.dart';
import '../../../domain/models/match/liked_user_model.dart';

class RewindService with ChangeNotifier {
  final List<LikedUserModel> _rewindableUsers = [];
  bool _isVipRewindEnabled = false;

  List<LikedUserModel> get rewindableUsers => _rewindableUsers;
  bool get hasRewindableUsers => _rewindableUsers.isNotEmpty;

  void setVipRewindEnabled(bool enabled) {
    _isVipRewindEnabled = enabled;
    notifyListeners();
  }

  // Add a user to the rewindable list when swiped left
  void addToRewindable(LikedUserModel user) {
    _rewindableUsers.add(user);
    notifyListeners();
  }

  // Pop the last user from the rewindable list
  LikedUserModel? rewindLastUser() {
    if (_rewindableUsers.isEmpty) return null;

    final lastUser = _rewindableUsers.removeLast();
    notifyListeners();
    return lastUser;
  }

  // Clear the rewindable list
  void clearRewindableUsers() {
    _rewindableUsers.clear();
    notifyListeners();
  }
}
