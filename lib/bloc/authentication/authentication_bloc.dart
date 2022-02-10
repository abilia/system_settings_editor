import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FutureOr<void> Function()? onLogout;
  final UserRepository userRepository;

  AuthenticationBloc(
    this.userRepository, {
    this.onLogout,
  }) : super(const AuthenticationLoading()) {
    on<AuthenticationEvent>(_onAuthenticationEvent, transformer: sequential());
  }

  Future _onAuthenticationEvent(
    AuthenticationEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    if (event is NotReady) {
      await _notReady(event, emit);
    } else if (event is CheckAuthentication) {
      await _checkAuthentication(event, emit);
    } else if (event is LoggedIn) {
      await _loggedIn(event, emit);
    } else if (event is LoggedOut) {
      await _loggedOut(event, emit);
    }
  }

  Future _notReady(NotReady event, Emitter<AuthenticationState> emit) async {
    await Future.delayed(const Duration(milliseconds: 50));
    emit(state._forceNew());
  }

  Future _checkAuthentication(
    CheckAuthentication event,
    Emitter<AuthenticationState> emit,
  ) async {
    final token = userRepository.getToken();
    if (token != null) {
      final nextState = await _tryGetUser(token);
      emit(nextState);
    } else {
      emit(const Unauthenticated());
    }
  }

  Future _loggedIn(LoggedIn event, Emitter<AuthenticationState> emit) async {
    await userRepository.persistLoginInfo(event.loginInfo);
    final nextState =
        await _tryGetUser(event.loginInfo.token, newlyLoggedIn: true);
    emit(nextState);
  }

  Future _loggedOut(LoggedOut event, Emitter<AuthenticationState> emit) async {
    emit(Unauthenticated(loggedOutReason: event.loggedOutReason));
    await _logout();
  }

  Future<AuthenticationState> _tryGetUser(
    String token, {
    bool newlyLoggedIn = false,
  }) async {
    try {
      final user = await userRepository.me(token);
      return Authenticated(
        token: token,
        userId: user.id,
        newlyLoggedIn: newlyLoggedIn,
      );
    } on UnauthorizedException {
      await _logout(token: token);
      return const Unauthenticated();
    } catch (_) {
      return const Unauthenticated();
      // Do nothing
    }
  }

  Future _logout({String? token}) async {
    try {
      await onLogout?.call();
    } catch (e) {
      Logger('onLogout').severe('exception when logging out: $e');
    }
    await userRepository.logout(token);
  }
}
