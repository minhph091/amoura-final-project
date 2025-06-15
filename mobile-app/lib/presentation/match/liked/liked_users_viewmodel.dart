import 'package:flutter/material.dart';
import '../../../domain/models/match/liked_user_model.dart';
import '../../profile/view/profile_view.dart';

class LikedUsersViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _showFilterMenu = false;

  bool get isLoading => _isLoading;
  bool get showFilterMenu => _showFilterMenu;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Toggle filter menu visibility
  void toggleFilterMenu() {
    _showFilterMenu = !_showFilterMenu;
    notifyListeners();
  }

  // Handle when a user card is tapped
  void onUserSelected(BuildContext context, LikedUserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileView(isMyProfile: false),
      ),
    );
  }

  // Navigate to user profile - method called from the view
  void navigateToUserProfile(BuildContext context, LikedUserModel user) {
    onUserSelected(context, user);
  }
}
