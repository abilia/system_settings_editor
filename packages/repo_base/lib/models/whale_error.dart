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
