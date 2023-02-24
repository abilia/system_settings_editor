import 'package:equatable/equatable.dart';
import 'package:repo_base/models/whale_error.dart';

class LoginError extends Equatable {
  final int status;
  final String message;
  final int errorId;
  final Iterable<WhaleError> errors;
  const LoginError._({
    required this.status,
    required this.message,
    required this.errorId,
    required this.errors,
  });

  factory LoginError.fromJson(Map<String, dynamic> json) {
    return LoginError._(
      status: json['status'] ?? -1,
      message: json['message'] ?? '',
      errorId: json['errorId'] ?? -1,
      errors: json['errors'] != null
          ? List<WhaleError>.from(
              json['errors'].map(
                (x) => WhaleError.fromJson(x),
              ),
            )
          : List<WhaleError>.empty(),
    );
  }

  @override
  List<Object?> get props => [status, message, errorId, errors];
}
