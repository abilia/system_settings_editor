import 'package:meta/meta.dart';

@immutable
class Login {
  final String token;
  final int endDate;
  final String renewToken;
  Login._({this.token, this.endDate, this.renewToken});

  factory Login.fromJson(Map<String, dynamic> json) {
    return Login._(
      token: json['token'],
      endDate: json['endDate'],
      renewToken: json['renewToken'],
    );
  }
}