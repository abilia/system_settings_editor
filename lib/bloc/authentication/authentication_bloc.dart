import 'dart:async';

import 'package:bloc/bloc.dart';
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

  AuthenticationBloc(
    UserRepository userRepository, {
    this.onLogout,
  }) : super(AuthenticationLoading(userRepository)) {
    on<NotReady>(_notReady);
    on<ChangeRepository>(_changeRepository);
    on<CheckAuthentication>(_checkAuthentication);
    on<LoggedIn>(_loggedIn);
    on<LoggedOut>(_loggedOut);
  }

  void _notReady(NotReady event, Emitter<AuthenticationState> emit) async {
    await Future.delayed(const Duration(milliseconds: 50));
    emit(state._forceNew());
  }

  void _changeRepository(
      ChangeRepository event, Emitter<AuthenticationState> emit) async {
    emit(Unauthenticated(
      event.repository,
      forcedNewState: state.forcedNewState,
    ));
  }

  void _checkAuthentication(
      CheckAuthentication event, Emitter<AuthenticationState> emit) async {
    final repo = state.userRepository;
    final token = state.userRepository.getToken();
    if (token != null) {
      final nextState = await _tryGetUser(repo, token);
      emit(nextState);
    } else {
      emit(Unauthenticated(repo));
    }
  }

  void _loggedIn(LoggedIn event, Emitter<AuthenticationState> emit) async {
    final repo = state.userRepository;
    await repo.persistToken(event.token);
    final nextState = await _tryGetUser(repo, event.token, newlyLoggedIn: true);
    emit(nextState);
  }

  void _loggedOut(LoggedOut event, Emitter<AuthenticationState> emit) async {
    final repo = state.userRepository;
    final nextState =
        await _logout(repo, loggedOutReason: event.loggedOutReason);
    emit(nextState);
  }

  Future<AuthenticationState> _tryGetUser(
    UserRepository repo,
    String token, {
    bool newlyLoggedIn = false,
  }) async {
    try {
      final user = await repo.me(token);
      return Authenticated(
        token: token,
        userId: user.id,
        userRepository: repo,
        newlyLoggedIn: newlyLoggedIn,
      );
    } on UnauthorizedException {
      return await _logout(
        repo,
        token: token,
      );
    } catch (_) {
      return Unauthenticated(repo);
      // Do nothing
    }
  }

  Future<AuthenticationState> _logout(
    UserRepository repo, {
    String? token,
    LoggedOutReason loggedOutReason = LoggedOutReason.logOut,
  }) async {
    try {
      await onLogout?.call();
    } catch (e) {
      Logger('onLogout').severe('exception when logging out: $e');
    }
    repo.logout(token);
    return Unauthenticated(
      state.userRepository,
      loggedOutReason: loggedOutReason,
    );
  }
}
