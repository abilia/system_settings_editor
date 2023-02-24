import 'package:equatable/equatable.dart';

class WhaleError extends Equatable {
  static const String unsupportedUserType = 'WHALE-0156';

  final String code;
  final String message;
  const WhaleError._({required this.code, required this.message});

  factory WhaleError.fromJson(Map<String, dynamic> json) {
    return WhaleError._(
      code: json['code'],
      message: json['message'],
    );
  }

  @override
  List<Object?> get props => [code, message];
}

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
          for (var e in json['errors'] ?? []) BadRequestError.fromJson(e)
        ],
      );

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [status, message, errorId, errors];
}

class BadRequestException implements Exception {
  final BadRequest badRequest;

  BadRequestException({required this.badRequest});
}

class BadRequestError extends Equatable {
  final String code;
  final String message;

  const BadRequestError._({required this.code, required this.message});

  static BadRequestError fromJson(Map<String, dynamic> json) =>
      BadRequestError._(
        code: json['code'] ?? '',
        message: json['message'] ?? '',
      );

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [code, message];
}

class CreateAccountException implements Exception {
  final BadRequest badRequest;

  CreateAccountException({required this.badRequest});
}
