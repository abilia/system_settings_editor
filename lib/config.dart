import 'package:flutter/foundation.dart';

class Config {
  static const beta =
      bool.fromEnvironment('beta', defaultValue: false) || kDebugMode;
  static const release = !beta;
}
