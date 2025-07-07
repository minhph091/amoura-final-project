import '../../config/environment.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class UrlTransformer {
  static String transform(String url) {
    if (url.isEmpty) {
      debugPrint('UrlTransformer: Empty URL provided');
      return url;
    }

    // Log original URL for debugging
    debugPrint('UrlTransformer: Original URL = $url');
    
    // Check for malformed URLs
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      debugPrint('UrlTransformer: WARNING - URL does not start with http/https: $url');
    }
    
    String transformedUrl = url;
    
    if (EnvironmentConfig.current == Environment.dev) {
      // On Android emulators, the host machine's localhost is accessible via 10.0.2.2.
      // The backend might return URLs with 'localhost', which need to be replaced.
      if (url.contains('localhost')) {
        transformedUrl = url.replaceAll('localhost', '10.0.2.2');
        debugPrint('UrlTransformer: Transformed localhost URL = $transformedUrl');
      }
    }
    
    // Final validation
    if (transformedUrl != url) {
      debugPrint('UrlTransformer: URL transformed from $url to $transformedUrl');
    }
    
    return transformedUrl;
  }
  
  /// Debug method để kiểm tra URL structure
  static void debugUrl(String originalUrl, String? transformedUrl) {
    if (!kDebugMode) return;
    
    debugPrint('=== URL DEBUG ===');
    debugPrint('Original: $originalUrl');
    debugPrint('Transformed: ${transformedUrl ?? "null"}');
    
    // Check for common issues
    if (originalUrl.contains('example.com')) {
      debugPrint('WARNING: URL contains example.com - this might be mock data');
    }
    
    if (originalUrl.contains('localhost') && !originalUrl.contains('10.0.2.2')) {
      debugPrint('WARNING: URL contains localhost but not transformed');
    }
    
    // Check for missing protocol
    if (!originalUrl.startsWith('http')) {
      debugPrint('WARNING: URL missing protocol');
    }
    
    // Check for malformed concatenation
    if (originalUrl.contains('comus') || originalUrl.contains('com/users')) {
      debugPrint('WARNING: Possible malformed URL concatenation detected');
    }
    
    debugPrint('=== END URL DEBUG ===');
  }

  /// Transform localhost URLs to work with Android emulator
  /// Android emulator cần dùng 10.0.2.2 thay vì localhost
  static String transformUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    
    // For Android emulator: Transform localhost to 10.0.2.2
    if (!kIsWeb && Platform.isAndroid) {
      if (url.contains('localhost')) {
        final transformed = url.replaceAll('localhost', '10.0.2.2');
        debugPrint('UrlTransformer: Transformed $url -> $transformed');
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
      debugPrint('UrlTransformer: Empty image URL provided');
      return '';
    }
    
    debugPrint('UrlTransformer: Transforming image URL: $imageUrl');
    final transformed = transformUrl(imageUrl);
    debugPrint('UrlTransformer: Image URL result: $transformed');
    return transformed;
  }
} 