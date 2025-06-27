import 'package:flutter/material.dart';
import 'config/environment.dart';
import 'main.dart';

void main() {
  EnvironmentConfig.current = Environment.staging;
  runMain();
}
