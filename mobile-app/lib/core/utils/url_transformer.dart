import '../../config/environment.dart';

class UrlTransformer {
  static String transform(String url) {
    if (EnvironmentConfig.current == Environment.dev) {
      // On Android emulators, the host machine's localhost is accessible via 10.0.2.2.
      // The backend might return URLs with 'localhost', which need to be replaced.
      if (url.contains('localhost')) {
        return url.replaceAll('localhost', '10.0.2.2');
      }
    }
    // For other environments or if the URL is already correct, return it as is.
    return url;
  }
} 