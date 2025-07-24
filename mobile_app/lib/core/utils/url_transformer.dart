import '../../config/environment.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class UrlTransformer {
  static String transform(String url) {
    if (url.isEmpty) {
      return url;
    }
    
    String transformedUrl = url;
    
    if (EnvironmentConfig.current == Environment.dev) {
      // On Android emulators, the host machine's localhost is accessible via 10.0.2.2.
      // The backend might return URLs with 'localhost', which need to be replaced.
      if (url.contains('localhost')) {
        transformedUrl = url.replaceAll('localhost', '10.0.2.2');
      }
    }
    
    return transformedUrl;
  }
  
  /// Transform localhost URLs to work with Android emulator
  /// Android emulator cần dùng 10.0.2.2 thay vì localhost
  static String transformUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    
    // For Android emulator: Transform localhost to 10.0.2.2
    if (!kIsWeb && Platform.isAndroid) {
      if (url.contains('localhost')) {
        final transformed = url.replaceAll('localhost', '10.0.2.2');
        return transformed;
      }
    }
    
    return url;
  }
  
  /// Transform avatar URL specifically for better error handling
  static String transformAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return '';
    return transformUrl(avatarUrl);
  }
  
  /// Transform image URL specifically for chat messages
  static String transformImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    
    final transformed = transformUrl(imageUrl);
    return transformed;
  }
} 

