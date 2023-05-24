class UnavailableException implements Exception {
  final List<int> statusCodes;

  UnavailableException(this.statusCodes);
  String errMsg() => 'Unavailable with statusCodes: $statusCodes';
  @override
  String toString() => errMsg();
}
