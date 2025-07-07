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

  // Navigate to user profile - renamed method to match what's called in the view
  void navigateToUserProfile(BuildContext context, LikedUserModel user) {
    onUserSelected(context, user);
  }

  // Handle when a user likes back someone who already liked them
  Future<void> likeUser(BuildContext context, LikedUserModel user) async {
    setLoading(true);

    try {
      // TODO: In the future, call the API to record the like
      // For now, we just simulate a successful like
      await Future.delayed(const Duration(milliseconds: 300));

      // This method is called after the match dialog is shown
      // Handle any post-match actions here, such as:
      // 1. Remove the liked user from the list (optional)
      // 2. Add the match to the conversations list
      // 3. Update match statistics

      // For demonstration purposes, we'll just print a message
      debugPrint('Matched with ${user.firstName}!');
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error liking user: ${e.toString()}')),
      );
    } finally {
      setLoading(false);
    }
  }
}
