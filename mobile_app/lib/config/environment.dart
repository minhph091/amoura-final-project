// lib/config/environment.dart
enum Environment { dev, staging, prod }

class EnvironmentConfig {
  static Environment current = Environment.dev;

  static String get baseUrl {
    switch (current) {
      case Environment.dev:
        // Cho Android Emulator: 10.0.2.2 = localhost của máy host  
        // Cho Physical Device: Thay bằng IP thực của máy (ví dụ: http://192.168.1.100:8080/api)
        return 'http://10.0.2.2:8080/api';
      case Environment.staging:
        return 'http://150.95.109.13:8080/api';
      case Environment.prod:
        return 'https://api.amoura.com';
    }
  }
}