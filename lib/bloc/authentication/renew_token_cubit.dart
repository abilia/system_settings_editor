import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:seagull/models/bad_request.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/repository/json_response.dart';
import 'package:seagull/utils/all.dart';

class RenewTokenCubit extends Cubit {
  final BaseClient client;
  final String baseUrl;
  final int postApiVersion;

  RenewTokenCubit({
    required this.client,
    required this.baseUrl,
    this.postApiVersion = 1,
    String? clientId,
    String? authToken,
    String? renewToken,
    int endDate = 0,
  }) : super(const TokenValid()) {
    _evaluateTokenValid(clientId, authToken, renewToken, endDate);
  }

  void _evaluateTokenValid(
      String? clientId, String? authToken, String? renewToken, int endDate) {
    if (authToken != null && DateTime(endDate).isAfter(DateTime.now())) {
      emit(TokenValid(token: authToken));
    } else if (clientId != null && renewToken != null) {
      requestToken(clientId, renewToken);
    } else {
      emit(const TokenRenewFailed(-1));
    }
  }

  Future<void> requestToken(String clientId, String renewToken) async {
    emit(const TokenRequested());
    final response = await client.post(
      '$baseUrl/api/v$postApiVersion/token/renew'.toUri(),
      body: jsonEncode(
        {
          'clientId': clientId,
          'renewToken': renewToken,
        },
      ),
    );
    switch (response.statusCode) {
      case 200:
        Map<String, dynamic> data = response.json();
        emit(
          TokenValid(
            endDate: data['endDate'],
            renewToken: data['renewToken'],
            token: data['token'],
          ),
        );
        break;
      case 400:
        emit(const TokenRenewFailed(400));
        throw BadRequestException(
          badRequest: BadRequest.fromJson(
            response.json(),
          ),
        );
      case 401:
        emit(const TokenRenewFailed(401));
        break;
      default:
        emit(TokenRenewFailed(response.statusCode));
      // throw UnavailableException([response.statusCode]);
    }
  }
}

abstract class _TokenState extends Equatable {
  final String? token;
  final int? endDate;
  final String? renewToken;

  const _TokenState({this.token, this.endDate, this.renewToken});

  @override
  List<Object?> get props => [token, endDate, renewToken];
}

class TokenRequested extends _TokenState {
  const TokenRequested();
}

class TokenValid extends _TokenState {
  const TokenValid({
    token,
    endDate,
    renewToken,
  }) : super(
          token: token,
          endDate: endDate,
          renewToken: renewToken,
        );
}

class TokenRenewFailed extends _TokenState {
  final int reason;

  const TokenRenewFailed(this.reason);

  @override
  List<Object?> get props => [token, endDate, renewToken, reason];
}
