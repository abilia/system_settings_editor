import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

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
        super(LoginSucceeded());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      if (authenticationBloc.state is AuthenticationInitialized) {
        final authState = authenticationBloc.state as AuthenticationInitialized;
        yield LoginLoading();
        try {
          final pushToken = await pushService.initPushToken();
          final token = await authState.userRepository.authenticate(
            username: event.username.trim(),
            password: event.password.trim(),
            pushToken: pushToken,
            time: clockBloc.state,
          );
          authenticationBloc.add(LoggedIn(token: token));
          yield LoginSucceeded();
        } on UnauthorizedException catch (error) {
          yield LoginFailure(
              error: error.toString(),
              loginFailureCause: LoginFailureCause.Credentials);
        } catch (error) {
          yield LoginFailure(
              error: error.toString(),
              loginFailureCause: LoginFailureCause.NoConnection);
        }
      }
    }
  }
}
