import 'package:repository_base/models/whale_error.dart';

class UnauthorizedException implements Exception {
  String errMsg() => 'Not authorized';
}

class NoLicenseException implements Exception {
  String errMsg() => 'No valid license';
}

class WrongUserTypeException implements Exception {
  String errMsg() => 'Only type User is supported';
}

enum CreateAccountFailure {
  noUsername,
  usernameToShort,
  usernameInvalid,
  usernameTaken,
  noPassword,
  passwordToShort,
  noConfirmPassword,
  passwordMismatch,
  termsOfUse,
  privacyPolicy,
  clientNotAllowed,
  invalidLanguage,
  noConnection,
  unknown,
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

extension CreateAccountBadRequestErrorExtension on BadRequestError {
  CreateAccountFailure get failure {
    if (code == _whale0137) {
      return message.toLowerCase().contains('terms')
          ? CreateAccountFailure.termsOfUse
          : CreateAccountFailure.privacyPolicy;
    }
    return _failureMapping[code] ?? CreateAccountFailure.unknown;
  }

  static const _whale0137 = 'WHALE-0137';
  static const _failureMapping = {
    // Client not allowed to create users
    'WHALE-0120': CreateAccountFailure.clientNotAllowed,
    // Username/email address already in use
    'WHALE-0130': CreateAccountFailure.usernameTaken,
    // Password can't be null or empty
    'WHALE-0131': CreateAccountFailure.noPassword,
    // The password must consist of at least 8 characters
    'WHALE-0133': CreateAccountFailure.passwordToShort,
    // Username must only contain letters, numbers, dash or underscore and be between 3 and 15 characters long
    'WHALE-0134': CreateAccountFailure.usernameToShort,
    // Username/email address is invalid
    'WHALE-0135': CreateAccountFailure.usernameInvalid,
    // Language must be valid
    'WHALE-0136': CreateAccountFailure.invalidLanguage,
    // Input field must be true
    _whale0137: CreateAccountFailure.termsOfUse,
  };
}
