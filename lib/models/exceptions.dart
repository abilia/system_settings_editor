class UnauthorizedException implements Exception {
  String errMsg() => 'Not authorized';
}

class UnavailableException implements Exception {
  String errMes() => 'Unavailable';
}
