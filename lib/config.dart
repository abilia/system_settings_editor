import 'package:flutter/foundation.dart';

class Config {
  static const alpha =
      String.fromEnvironment('release') == 'alpha' || kDebugMode;
  static const beta = alpha || String.fromEnvironment('release') == 'beta';
  static const release = !beta;
}
