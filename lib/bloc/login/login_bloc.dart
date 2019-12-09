import 'dart:async';

import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/repository/push.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationBloc authenticationBloc;
  final FirebasePushService pushService;

  LoginBloc({
    @required this.authenticationBloc,
    @required this.pushService,
  })  : assert(authenticationBloc != null),
        assert(pushService != null);

  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      if (authenticationBloc.state is AuthenticationInitialized) {
        final authState = authenticationBloc.state as AuthenticationInitialized;
        yield LoginLoading();

        try {
          final pushToken = await pushService.initPushToken();
          final token = await authState.userRepository.authenticate(
            username: event.username,
            password: event.password,
            pushToken: pushToken,
          );

          authenticationBloc.add(LoggedIn(token: token));
          yield LoginInitial();
        } catch (error) {
          yield LoginFailure(error: error.toString());
        }
      }
    }
  }
}
