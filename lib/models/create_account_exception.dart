import 'package:equatable/equatable.dart';

enum CreateAccountFailure {
  NoUsername,
  UsernameToShort,
  UsernameInvalid,
  UsernameTaken,
  NoPassword,
  PasswordToShort,
  NoConfirmPassword,
  PasswordMismatch,
  TermsOfUse,
  PrivacyPolicy,
  ClientNotAllowed,
  InvalidLanguage,
  NoConnection,
  Unknown,
}

class CreateAccountException extends Equatable {
  final int status;
  final String message;
  final int errorId;
  final List<_Errors> errors;

  const CreateAccountException({
    required this.status,
    required this.message,
    required this.errorId,
    required this.errors,
  });

  static CreateAccountException fromJson(Map<String, dynamic> json) =>
      CreateAccountException(
        status: json['status'] ?? -1,
        message: json['message'] ?? '',
        errorId: json['errorId'] ?? -1,
        errors: [for (var e in json['errors'] ?? []) _Errors._fromJson(e)],
      );

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [status, message, errorId, errors];
}

class _Errors extends Equatable {
  final String code;
  final String message;

  const _Errors._({required this.code, required this.message});

  static _Errors _fromJson(Map<String, dynamic> json) => _Errors._(
        code: json['code'] ?? '',
        message: json['message'] ?? '',
      );

  CreateAccountFailure get failure {
    if (code == _WHALE_0137) {
      return message.toLowerCase().contains('terms')
          ? CreateAccountFailure.TermsOfUse
          : CreateAccountFailure.PrivacyPolicy;
    }
    return _failureMaping[code] ?? CreateAccountFailure.Unknown;
  }

  static const _WHALE_0137 = 'WHALE-0137';
  static const _failureMaping = {
    // Client not allowed to create users
    'WHALE-0120': CreateAccountFailure.ClientNotAllowed,
    // Username/email address already in use
    'WHALE-0130': CreateAccountFailure.UsernameTaken,
    // Password can't be null or empty
    'WHALE-0131': CreateAccountFailure.NoPassword,
    // The password must consist of at least 8 characters
    'WHALE-0133': CreateAccountFailure.PasswordToShort,
    // Username must only contain letters, numbers, dash or underscore and be between 3 and 15 characters long
    'WHALE-0134': CreateAccountFailure.UsernameToShort,
    // Username/email address is invalid
    'WHALE-0135': CreateAccountFailure.UsernameInvalid,
    // Language must be valid
    'WHALE-0136': CreateAccountFailure.InvalidLanguage,
    // Input field must be true
    _WHALE_0137: CreateAccountFailure.TermsOfUse,
  };

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [code, message];
}
