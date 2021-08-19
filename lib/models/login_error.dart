import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class LoginError extends Equatable {
  final int status;
  final String message;
  final int errorId;
  final Iterable<Error> errors;
  LoginError._({
    required this.status,
    required this.message,
    required this.errorId,
    required this.errors,
  });

  factory LoginError.fromJson(Map<String, dynamic> json) {
    print(json.toString());
    return LoginError._(
      status: json['status'],
      message: json['message'],
      errorId: json['errorId'],
      errors: json['errors'] != null
          ? List<Error>.from(
        json['errors'].map(
              (x) => Error.fromJson(x),
        ),
      )
          : List<Error>.empty(),
    );
  }

  @override
  List<Object?> get props => [status, message, errorId, errors];
}

class Error extends Equatable {
  final String code;
  final String message;
  Error._({
    required this.code,
    required this.message
  });

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error._(
      code: json['code'],
      message: json['message'],
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [code, message];

}