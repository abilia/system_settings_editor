import 'package:http/http.dart';

class UnavailableException implements Exception {
  final List<int> statusCodes;

  UnavailableException(this.statusCodes);

  String errMsg() => 'Unavailable with statusCodes: $statusCodes';

  @override
  String toString() => errMsg();
}

class UnauthorizedException implements Exception {
  String errMsg() => 'Not authorized';
}

class StatusCodeException implements Exception {
  final Response response;
  final String? message;
  StatusCodeException(this.response, [this.message])
      : assert(response.statusCode != 200);
  @override
  String toString() => 'Wrong status code in response: '
      '${response.statusCode}, $response, $message';
}
