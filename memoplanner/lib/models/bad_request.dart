import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';

class BadRequest extends Equatable {
  final int status;
  final String message;
  final int errorId;
  final List<BadRequestError> errors;

  const BadRequest({
    required this.status,
    required this.message,
    required this.errorId,
    required this.errors,
  });

  static BadRequest fromJson(Map<String, dynamic> json) => BadRequest(
        status: json['status'] ?? -1,
        message: json['message'] ?? '',
        errorId: json['errorId'] ?? -1,
        errors: [
          for (var e in json['errors'] ?? []) BadRequestError._fromJson(e)
        ],
      );

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [status, message, errorId, errors];
}

class BadRequestError extends Equatable {
  final String code;
  final String message;

  const BadRequestError._({required this.code, required this.message});

  static BadRequestError _fromJson(Map<String, dynamic> json) =>
      BadRequestError._(
        code: json['code'] ?? '',
        message: json['message'] ?? '',
      );

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

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [code, message];
}
