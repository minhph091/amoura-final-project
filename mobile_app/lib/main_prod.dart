import 'config/environment.dart';
import 'main.dart';

void main() {
  EnvironmentConfig.current = Environment.prod;
  runMain();
}
