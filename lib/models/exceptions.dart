import 'package:http/http.dart';
import 'package:seagull/models/all.dart';

class UnauthorizedException implements Exception {
  String errMsg() => 'Not authorized';
}

class UnavailableException implements Exception {
  final List<int> statusCodes;

  UnavailableException(this.statusCodes);
  String errMsg() => 'Unavailable with statusCodes: $statusCodes';
  @override
  String toString() => errMsg();
}

class WrongRevisionException implements Exception {
  String errMsg() => 'Unavailable';
}

class NoLicenseException implements Exception {
  String errMsg() => 'No valid license';
}

class WrongUserTypeException implements Exception {
  String errMsg() => 'Only type User is supported';
}

class BadRequestException implements Exception {
  final BadRequest badRequest;

  BadRequestException({required this.badRequest});
}

class CreateAccountException implements Exception {
  final BadRequest badRequest;

  CreateAccountException({required this.badRequest});
}

class VerifyDeviceException implements Exception {
  final BadRequest badRequest;

  VerifyDeviceException({required this.badRequest});
}

class RequestTokenException implements Exception {
  final BadRequest badRequest;

  RequestTokenException({required this.badRequest});
}

class VoiceFileDownloadException implements Exception {
  final VoiceFile voiceFile;
  final String? message;
  VoiceFileDownloadException(this.voiceFile, [this.message]);
  @override
  String toString() => 'failed to download voice file: $voiceFile, ($message)';
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

class FetchSessionsException implements Exception {
  FetchSessionsException(this.statusCode);
  final int statusCode;
}
