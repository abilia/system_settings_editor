import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/utils/strings.dart';

@immutable
class LoginInfo extends Equatable {
  final String token;
  final int endDate;
  final String renewToken;

  @visibleForTesting
  const LoginInfo({
    required this.token,
    required this.endDate,
    required this.renewToken,
  });

  factory LoginInfo.fromJson(Map<String, dynamic> json) {
    return LoginInfo(
      token: json['token'],
      endDate: json['endDate'],
      renewToken: json['renewToken'],
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token.nullOnEmpty(),
        'endDate': endDate,
        'renewToken': renewToken.nullOnEmpty(),
      };

  @override
  List<Object> get props => [token, endDate, renewToken];
}
