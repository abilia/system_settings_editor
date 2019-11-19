import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Login extends Equatable{
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

  @override
  List<Object> get props => [token, endDate, renewToken];
}