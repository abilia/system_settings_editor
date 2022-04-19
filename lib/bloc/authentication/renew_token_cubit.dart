import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/repository/all.dart';

class RenewTokenCubit extends Cubit {
  final UserRepository userRepository;

  RenewTokenCubit({
    required this.userRepository,
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
      emit(const TokenRenewFailed());
    }
  }

  Future<void> requestToken(String clientId, String renewToken) async {
    emit(const TokenRequested());

    final response = await userRepository.requestToken(clientId, renewToken);

    if (response != null) {
      Map<String, dynamic> data = response;
      emit(
        TokenValid(
          endDate: data['endDate'],
          renewToken: data['renewToken'],
          token: data['token'],
        ),
      );
    } else {
      emit(const TokenRenewFailed());
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
  const TokenRenewFailed();
}
