import 'config/environment.dart';
import 'main.dart';

void main() {
  EnvironmentConfig.current = Environment.dev;
  runMain();
}
