class UnauthorizedException implements Exception {
  String errMsg() => 'Not authorized';
}

class UnavailableException implements Exception {
  String errMsg() => 'Unavailable';
}

class WrongRevisionException implements Exception {
  String errMsg() => 'Unavailable';
}