// lib/core/utils/logger.dart
import 'package:flutter/foundation.dart';
import '../../config/environment.dart';

class Logger {
  static void debug(String message) {
    // Chỉ hiển thị debug logs trong development mode
    if (kDebugMode && EnvironmentConfig.current != Environment.prod) {
      debugPrint(message);
    }
  }
  
  static void info(String message) {
    // Info logs hiển thị trong debug mode nhưng không trong production
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }
  
  static void error(String message) {
    // Error logs luôn hiển thị trong terminal nhưng không trên UI
    debugPrint('[ERROR] $message');
  }
  
  static void warning(String message) {
    // Warning logs hiển thị trong debug mode
    if (kDebugMode) {
      debugPrint('[WARNING] $message');
    }
  }
}
