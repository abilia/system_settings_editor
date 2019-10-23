import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/authentication/bloc.dart';
import 'package:seagull/bloc/login/bloc.dart';
import 'package:seagull/repository/user_repository.dart';

import 'mock_user_repository.dart';

void main() {
  group('LoginBloc event order', () {
    LoginBloc loginBloc;
    AuthenticationBloc authenticationBloc;

    setUp(() {
      final userRepository = UserRepository();
      authenticationBloc = AuthenticationBloc(userRepository: userRepository);
      loginBloc = LoginBloc(
          userRepository: userRepository,
          authenticationBloc: authenticationBloc);
    });

    test('initial state is LoginInitial', () {
      expect(loginBloc.initialState, LoginInitial());
    });

    test('LoginState and AuthenticationState in correct order', () {
      final List<LoginState> expectedLoginStates = [
        LoginInitial(),
        LoginLoading(),
        LoginInitial(),
      ];
      final List<AuthenticationState> expectedAuthenticationStates = [
        AuthenticationUninitialized(),
        AuthenticationUnauthenticated(),
        AuthenticationLoading(),
        AuthenticationAuthenticated(),
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expectedAuthenticationStates),
      );

      expectLater(
        loginBloc,
        emitsInOrder(expectedLoginStates),
      );

      authenticationBloc.add(AppStarted());
      loginBloc
          .add(LoginButtonPressed(username: 'username', password: 'password'));
    });

    tearDown(() {
      loginBloc.close();
      authenticationBloc.close();
    });
  });

  group('LoginBloc side effect', () {
    LoginBloc loginBloc;
    AuthenticationBloc authenticationBloc;
    UserRepository userRepository;

    setUp(() {
      userRepository = MockUserRepository();
      authenticationBloc = AuthenticationBloc(userRepository: userRepository);
      loginBloc = LoginBloc(authenticationBloc: authenticationBloc, userRepository: userRepository);
    });

    test('LoginButtonPressed event calls logges in and saves token', () async {

      String username = 'username', password = 'password';
      loginBloc.add(LoginButtonPressed(username: username, password: password));
      await untilCalled(userRepository.authenticate(username: username, password: password));
      await untilCalled(userRepository.persistToken(any));
    });

    tearDown(() {
      authenticationBloc.close();
      loginBloc.close();
    });
  });
}
