import 'dart:async';

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
  late final StreamSubscription? _clientSubscription;

  AuthenticationBloc(
    this.userRepository, {
    this.onLogout,
    ListenableClient? client,
  }) : super(const AuthenticationLoading()) {
    _clientSubscription = client?.messageStream
        .where((event) => event == HttpMessage.unauthorized)
        .listen((event) {
      if (state is Authenticated) {
        add(const LoggedOut(loggedOutReason: LoggedOutReason.unauthorized));
      }
    });
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
    if (userRepository.isLoggedIn()) {
      final nextState = await _tryGetUser();
      emit(nextState);
    } else {
      emit(const Unauthenticated());
    }
  }

  Future _loggedIn(LoggedIn event, Emitter<AuthenticationState> emit) async {
    final nextState = await _tryGetUser(newlyLoggedIn: true);
    emit(nextState);
  }

  Future _loggedOut(LoggedOut event, Emitter<AuthenticationState> emit) async {
    await _logout();
    emit(Unauthenticated(loggedOutReason: event.loggedOutReason));
  }

  Future<AuthenticationState> _tryGetUser({
    bool newlyLoggedIn = false,
  }) async {
    try {
      final user = await userRepository.me();
      await userRepository.fetchAndSetCalendar(user.id);
      return Authenticated(
        userId: user.id,
        newlyLoggedIn: newlyLoggedIn,
      );
    } on UnauthorizedException {
      await _logout();
      return const Unauthenticated();
    } catch (_) {
      return const Unauthenticated();
      // Do nothing
    }
  }

  Future _logout() async {
    if (state is Unauthenticated) return;
    try {
      await onLogout?.call();
    } catch (e) {
      Logger('onLogout').severe('exception when logging out: $e');
    }
    await userRepository.logout();
  }

  @override
  Future<void> close() async {
    await _clientSubscription?.cancel();
    return super.close();
  }
}
