import 'package:http/http.dart';
import 'package:memoplanner/models/all.dart';

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

class BadRequestException implements Exception {
  final BadRequest badRequest;

  BadRequestException({required this.badRequest});
}

class CreateAccountException implements Exception {
  final BadRequest badRequest;

  CreateAccountException({required this.badRequest});
}

enum ConnectingLicenseFailedReason {
  notFound,
  alreadyConnected,
  wrongProduct,
  noDevice,
  noConnection,
  unknown;

  bool get notFoundOrWrongLicense => this == notFound || this == wrongProduct;
  bool get alreadyInuUse => this == alreadyConnected;
  bool get noInternet => this == noConnection;
}

class ConnectedLicenseException implements Exception {
  final BadRequest badRequest;
  bool _hasCode(String errorCode) => badRequest.errors.map((e) => e.code).any(
        (code) => code == errorCode,
      );
  ConnectingLicenseFailedReason get reason {
    if (_hasCode('WHALE-0801')) return ConnectingLicenseFailedReason.notFound;
    if (_hasCode('WHALE-6012')) return ConnectingLicenseFailedReason.noDevice;
    if (_hasCode('WHALE-6017')) {
      return ConnectingLicenseFailedReason.alreadyConnected;
    }
    if (_hasCode('WHALE-0863')) {
      return ConnectingLicenseFailedReason.wrongProduct;
    }
    return ConnectingLicenseFailedReason.unknown;
  }

  ConnectedLicenseException({required this.badRequest});

  @override
  String toString() => 'VerifyDeviceException $badRequest';
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

class SyncFailedException implements Exception {
  SyncFailedException([this.e]);
  final Exception? e;
  @override
  String toString() => 'Sync failed $e';
}
