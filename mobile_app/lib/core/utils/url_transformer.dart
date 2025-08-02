import '../../config/environment.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class UrlTransformer {
  /// Transform localhost URLs to work with Android emulator
  /// Android emulator cần dùng 10.0.2.2 thay vì localhost
  static String transform(String url) {
    if (url.isEmpty) {
      return url;
    }
    
    String transformedUrl = url;
    
    // For Android emulator: Transform localhost to 10.0.2.2
    if (!kIsWeb && Platform.isAndroid) {
      if (url.contains('localhost')) {
        transformedUrl = url.replaceAll('localhost', '10.0.2.2');
      }
    }
    
    return transformedUrl;
  }
  
  /// Legacy method - use transform() instead
  @deprecated
  static String transformUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    return transform(url);
  }
  
  /// Transform avatar URL specifically for better error handling
  static String transformAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return '';
    return transform(avatarUrl);
  }
  
  /// Transform image URL specifically for chat messages
  static String transformImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    
    return transform(imageUrl);
  }
} 

