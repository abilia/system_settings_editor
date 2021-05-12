import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationBloc authenticationBloc;
  final FirebasePushService pushService;
  final ClockBloc clockBloc;

  LoginBloc({
    @required this.authenticationBloc,
    @required this.pushService,
    @required this.clockBloc,
  })  : assert(authenticationBloc != null),
        assert(pushService != null),
        super(LoginState.initial());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is UsernameChanged) {
      yield state.copyWith(
        username: event.username,
      );
    }
    if (event is PasswordChanged) {
      yield state.copyWith(
        password: event.password,
      );
    }
    if (event is ClearFailure) {
      yield state.copyWith();
    }
    if (event is LoginButtonPressed) {
      yield* _mapLoginButtonPressedToState(event);
    }
  }

  static bool usernameValid(String username) => username.length > 2;

  static bool passwordValid(String password) => password.length > 7;

  Stream<LoginState> _mapLoginButtonPressedToState(
      LoginButtonPressed event) async* {
    yield state.loadning();
    if (!state.isUsernameValid) {
      yield state.failure(cause: LoginFailureCause.NoUsername);
      return;
    }
    if (!state.isPasswordValid) {
      yield state.failure(cause: LoginFailureCause.NoPassword);
      return;
    }
    final authState = authenticationBloc.state;
    try {
      final pushToken = await pushService.initPushToken();
      final token = await authState.userRepository.authenticate(
        username: state.username.trim(),
        password: state.password.trim(),
        pushToken: pushToken,
        time: clockBloc.state,
      );
      final licenses = await authState.userRepository.getLicensesFromApi(token);
      if (licenses.anyValidLicense(clockBloc.state)) {
        authenticationBloc.add(LoggedIn(token: token));
        yield LoginSucceeded();
      } else {
        yield state.failure(
          error: 'No valid license',
          cause: licenses.anyMemoplannerLicense()
              ? LoginFailureCause.LicenseExpired
              : LoginFailureCause.NoLicense,
        );
      }
    } on UnauthorizedException catch (error) {
      yield state.failure(
          error: error.toString(), cause: LoginFailureCause.Credentials);
    } catch (error) {
      yield state.failure(
          error: error.toString(), cause: LoginFailureCause.NoConnection);
    }
  }
}
