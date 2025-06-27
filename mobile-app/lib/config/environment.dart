// lib/config/environment.dart
enum Environment { dev, staging, prod }

class EnvironmentConfig {
  static Environment current = Environment.dev;

  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        return 'http://10.0.2.2:8080/api';
      case Environment.staging:
        return 'http://150.95.109.13:8080/api';
      case Environment.prod:
        return 'https://api.amoura.com';
    }
  }
}