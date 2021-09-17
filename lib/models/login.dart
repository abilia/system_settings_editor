import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Login extends Equatable {
  final String token;
  final int endDate;
  final String renewToken;
  const Login._({
    required this.token,
    required this.endDate,
    required this.renewToken,
  });

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login._(
      token: json['token'],
      endDate: json['endDate'],
      renewToken: json['renewToken'],
    );
  }

  @override
  List<Object> get props => [token, endDate, renewToken];
}
