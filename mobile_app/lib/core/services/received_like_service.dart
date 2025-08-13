import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/remote/match_api.dart';
import '../../data/models/match/received_like_model.dart';
import '../../app/di/injection.dart';

/// Service để quản lý danh sách người đã like mình
class ReceivedLikeService {
  final MatchApi _matchApi = getIt<MatchApi>();
  
  // Stream controllers để broadcast dữ liệu
  final StreamController<List<ReceivedLikeModel>> _receivedLikesController = 
      StreamController<List<ReceivedLikeModel>>.broadcast();
  final StreamController<ReceivedLikeModel> _newReceivedLikeController = 
      StreamController<ReceivedLikeModel>.broadcast();
  
  // Cache để lưu trữ local
  List<ReceivedLikeModel> _cachedReceivedLikes = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters for streams
  Stream<List<ReceivedLikeModel>> get receivedLikesStream => _receivedLikesController.stream;
  Stream<ReceivedLikeModel> get newReceivedLikeStream => _newReceivedLikeController.stream;
  
  // Getters for cached data
  List<ReceivedLikeModel> get receivedLikes => _cachedReceivedLikes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get count => _cachedReceivedLikes.length;
  
  /// Lấy danh sách người đã like mình từ API
  Future<List<ReceivedLikeModel>> getReceivedLikes() async {
    try {
      _isLoading = true;
      _error = null;
      debugPrint('ReceivedLikeService: Loading received likes...');
      
      final receivedLikes = await _matchApi.getReceivedLikes();
      
      // Cache the results
      _cachedReceivedLikes = receivedLikes;
      _receivedLikesController.add(receivedLikes);
      
      debugPrint('ReceivedLikeService: Loaded ${receivedLikes.length} received likes');
      
      // Debug: In ra chi tiết từng received like
      for (int i = 0; i < receivedLikes.length; i++) {
        final like = receivedLikes[i];
        debugPrint('ReceivedLikeService: Like $i - User: ${like.fullName} (ID: ${like.userId}), LikedAt: ${like.likedAt}');
      }
      
      return receivedLikes;
    } catch (e) {
      _error = e.toString();
      debugPrint('ReceivedLikeService: Error loading received likes: $e');
      debugPrint('ReceivedLikeService: Error details: ${e.runtimeType}');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }
  
  /// Refresh danh sách received likes
  Future<void> refreshReceivedLikes() async {
    try {
      await getReceivedLikes();
    } catch (e) {
      debugPrint('ReceivedLikeService: Error refreshing received likes: $e');
    }
  }
  
  /// Thêm received like mới (từ WebSocket hoặc real-time update)
  void addReceivedLike(ReceivedLikeModel receivedLike) {
    // Kiểm tra duplicate
    final existingIndex = _cachedReceivedLikes.indexWhere((like) => like.userId == receivedLike.userId);
    
    if (existingIndex == -1) {
      // Thêm vào đầu danh sách
      _cachedReceivedLikes.insert(0, receivedLike);
      _receivedLikesController.add(_cachedReceivedLikes);
      _newReceivedLikeController.add(receivedLike);
      
      debugPrint('ReceivedLikeService: Added new received like from user ${receivedLike.fullName}');
    } else {
      // Update existing
      _cachedReceivedLikes[existingIndex] = receivedLike;
      _receivedLikesController.add(_cachedReceivedLikes);
      
      debugPrint('ReceivedLikeService: Updated existing received like from user ${receivedLike.fullName}');
    }
  }
  
  /// Xóa received like (khi user đã response hoặc unlike)
  void removeReceivedLike(int userId) {
    final initialLength = _cachedReceivedLikes.length;
    _cachedReceivedLikes.removeWhere((like) => like.userId == userId);
    
    if (_cachedReceivedLikes.length != initialLength) {
      _receivedLikesController.add(_cachedReceivedLikes);
      debugPrint('ReceivedLikeService: Removed received like from user $userId');
    }
  }
  
  /// Clear tất cả received likes
  void clearReceivedLikes() {
    _cachedReceivedLikes.clear();
    _receivedLikesController.add(_cachedReceivedLikes);
    debugPrint('ReceivedLikeService: Cleared all received likes');
  }
  
  /// Dispose resources
  void dispose() {
    _receivedLikesController.close();
    _newReceivedLikeController.close();
  }
} 