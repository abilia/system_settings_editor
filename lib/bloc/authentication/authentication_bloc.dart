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

  AuthenticationBloc(
    UserRepository userRepository, {
    this.onLogout,
  }) : super(AuthenticationLoading(userRepository)) {
    on<AuthenticationEvent>(_onAuthenticationEvent, transformer: sequential());
  }

  Future _onAuthenticationEvent(
    AuthenticationEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    if (event is NotReady) {
      await _notReady(event, emit);
    } else if (event is ChangeRepository) {
      _changeRepository(event, emit);
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

  void _changeRepository(
    ChangeRepository event,
    Emitter<AuthenticationState> emit,
  ) =>
      emit(
        Unauthenticated(
          event.repository,
          forcedNewState: state.forcedNewState,
        ),
      );

  Future _checkAuthentication(
    CheckAuthentication event,
    Emitter<AuthenticationState> emit,
  ) async {
    final repo = state.userRepository;
    final token = state.userRepository.getToken();
    if (token != null) {
      final nextState = await _tryGetUser(repo, token);
      emit(nextState);
    } else {
      emit(Unauthenticated(repo));
    }
  }

  Future _loggedIn(LoggedIn event, Emitter<AuthenticationState> emit) async {
    final repo = state.userRepository;
    await repo.persistLoginInfo(event.loginInfo);
    final nextState =
        await _tryGetUser(repo, event.loginInfo.token, newlyLoggedIn: true);
    emit(nextState);
  }

  Future _loggedOut(LoggedOut event, Emitter<AuthenticationState> emit) async {
    final repo = state.userRepository;
    emit(Unauthenticated(repo, loggedOutReason: event.loggedOutReason));
    await _logout(repo);
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
      await _logout(repo, token: token);
      return Unauthenticated(repo);
    } catch (_) {
      return Unauthenticated(repo);
      // Do nothing
    }
  }

  Future _logout(UserRepository repo, {String? token}) async {
    try {
      await onLogout?.call();
    } catch (e) {
      Logger('onLogout').severe('exception when logging out: $e');
    }
    await repo.logout(token);
  }
}
