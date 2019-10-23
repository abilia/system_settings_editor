import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/authentication/bloc.dart';
import 'package:seagull/bloc/login/bloc.dart';
import 'package:seagull/repository/user_repository.dart';

import 'mocks.dart';

void main() {
  group('LoginBloc event order', () {
    LoginBloc loginBloc;
    AuthenticationBloc authenticationBloc;
    Client mockClient;

    setUp(() {
      mockClient = MockHttpClient();
      final userRepository = UserRepository(client: mockClient);
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
      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) => Future.value(Response('{"token":"token","endDate":1,"renewToken":"renewToken"}', 200)));

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
    UserRepository mockedUserRepository;

    setUp(() {
      mockedUserRepository = MockUserRepository();
      authenticationBloc = AuthenticationBloc(userRepository: mockedUserRepository);
      loginBloc = LoginBloc(authenticationBloc: authenticationBloc, userRepository: mockedUserRepository);
      when(mockedUserRepository.hasToken()).thenAnswer((_) => Future.value(false));
    });

    test('LoginButtonPressed event calls logges in and saves token', () async {

      String username = 'username', password = 'password';
      loginBloc.add(LoginButtonPressed(username: username, password: password));
      await untilCalled(mockedUserRepository.authenticate(username: username, password: password));
      await untilCalled(mockedUserRepository.persistToken(any));
    });

    tearDown(() {
      authenticationBloc.close();
      loginBloc.close();
    });
  });
}
