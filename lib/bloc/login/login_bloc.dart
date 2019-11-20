import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:seagull/bloc/authentication/bloc.dart';
import 'package:seagull/bloc/login/bloc.dart';
import 'package:seagull/repository/push.dart';
import 'package:seagull/repository/user_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;
  final FirebasePush push;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
    @required this.push,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null),
        assert(push != null);

  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final pushToken = await push.initPushToken();
        final token = await userRepository.authenticate(
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
