import 'package:flutter/material.dart';

class LikesViewModel extends ChangeNotifier {
  bool _isLoading = true;
  String? _error;
  List<UserProfile> _likes = [];

  LikesViewModel() {
    _loadLikes();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserProfile> get likes => _likes;

  Future<void> _loadLikes() async {
    try {
      // In a real app, this would be an API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _likes = [
        UserProfile(
          id: '1',
          firstName: 'Sarah',
          lastName: 'Johnson',
          age: 28,
          city: 'New York',
          coverPhotoUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=634&q=80',
          avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=634&q=80',
        ),
        UserProfile(
          id: '2',
          firstName: 'Michael',
          lastName: 'Chen',
          age: 32,
          city: 'San Francisco',
          coverPhotoUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=731&q=80',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=634&q=80',
        ),
        UserProfile(
          id: '3',
          firstName: 'Emma',
          lastName: 'Garcia',
          age: 26,
          city: 'Los Angeles',
          coverPhotoUrl: 'https://images.unsplash.com/photo-1488716820095-cbe80883c496?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=636&q=80',
          avatarUrl: 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=634&q=80',
        ),
        UserProfile(
          id: '4',
          firstName: 'Daniel',
          lastName: 'Taylor',
          age: 30,
          city: 'Chicago',
          coverPhotoUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=634&q=80',
          avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=634&q=80',
        ),
        UserProfile(
          id: '5',
          firstName: 'Olivia',
          lastName: 'Baker',
          age: 27,
          city: 'Seattle',
          coverPhotoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=700&q=80',
          avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=634&q=80',
        ),
        UserProfile(
          id: '6',
          firstName: 'James',
          lastName: 'Wilson',
          age: 33,
          city: 'Boston',
          coverPhotoUrl: 'https://images.unsplash.com/photo-1463453091185-61582044d556?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=700&q=80',
          avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=634&q=80',
        ),
      ];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final String city;
  final String coverPhotoUrl;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.city,
    required this.coverPhotoUrl,
    required this.avatarUrl,
  });

  String get fullName => '$firstName $lastName';
}
