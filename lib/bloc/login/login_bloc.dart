import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
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
        super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      final authState = authenticationBloc.state;
      yield LoginLoading();
      try {
        final pushToken = await pushService.initPushToken();
        final token = await authState.userRepository.authenticate(
          username: event.username.trim(),
          password: event.password.trim(),
          pushToken: pushToken,
          time: clockBloc.state,
        );
        final licenses =
            await authState.userRepository.getLicensesFromApi(token);
        if (licenses.anyValidLicense(clockBloc.state)) {
          authenticationBloc.add(LoggedIn(token: token));
          yield LoginSucceeded();
        } else {
          yield LoginFailure(
              error: 'No valid license',
              loginFailureCause: LoginFailureCause.License);
        }
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
