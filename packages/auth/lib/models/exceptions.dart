class UnauthorizedException implements Exception {
  String errMsg() => 'Not authorized';
}

class NoLicenseException implements Exception {
  String errMsg() => 'No valid license';
}

class WrongUserTypeException implements Exception {
  String errMsg() => 'Only type User is supported';
}
