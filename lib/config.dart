class Config {
  static const alpha = String.fromEnvironment('release') == 'alpha';
  static const beta = alpha || String.fromEnvironment('release') == 'beta';
  static const release = !beta;
}
