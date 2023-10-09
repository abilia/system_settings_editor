class FetchSessionsException implements Exception {
  FetchSessionsException(this.statusCode);
  final int statusCode;
}
