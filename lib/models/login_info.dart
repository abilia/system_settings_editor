import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class LoginInfo extends Equatable {
  final String token;
  final int endDate;
  final String renewToken;
  final String clientId;

  @visibleForTesting
  const LoginInfo({
    required this.token,
    required this.endDate,
    required this.renewToken,
    this.clientId = '',
  });

  factory LoginInfo.fromJson(Map<String, dynamic> json) {
    return LoginInfo(
      token: json['token'],
      endDate: json['endDate'],
      renewToken: json['renewToken'],
      clientId: json['clientId'] ?? '',
    );
  }

  LoginInfo copyWithClientId(String clientId) => LoginInfo(
        token: token,
        endDate: endDate,
        renewToken: renewToken,
        clientId: clientId,
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'endDate': endDate,
        'renewToken': renewToken,
        'clientId': clientId,
      };

  @override
  List<Object> get props => [token, endDate, renewToken, clientId];
}
