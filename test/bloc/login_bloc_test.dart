import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/authentication/bloc.dart';
import 'package:seagull/bloc/login/bloc.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/repository/user_repository.dart';

import 'mocks.dart';

void main() {
  group('LoginBloc event order', () {
    LoginBloc loginBloc;
    AuthenticationBloc authenticationBloc;
    Client mockClient;

    setUp(() {
      mockClient = MockHttpClient();
      final userRepository = UserRepository(httpClient: mockClient, secureStorage: MockSecureStorage());
      authenticationBloc = AuthenticationBloc(userRepository: userRepository);
      loginBloc = LoginBloc(
          userRepository: userRepository,
          authenticationBloc: authenticationBloc);

      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) => Future.value(Response('{"token":"token","endDate":1,"renewToken":"renewToken"}', 200)));
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) => Future.value(Response('''
        {
          "me" : {
            "id" : 0,
            "type" : "testcase",
            "name" : "Testcase user",
            "username" : "testcase",
            "language" : "sv",
            "image" : null
          }
        }
        ''', 200)));
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
        AuthenticationLoading(),
        Unauthenticated(),
        AuthenticationLoading(),
        Authenticated(token: 'token', userId: 0),
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
    UserRepository mockedUserRepository;

    setUp(() {
      mockedUserRepository = MockUserRepository();
      authenticationBloc = AuthenticationBloc(userRepository: mockedUserRepository);
      loginBloc = LoginBloc(authenticationBloc: authenticationBloc, userRepository: mockedUserRepository);
      when(mockedUserRepository.getToken()).thenAnswer((_) => Future.value('token'));
      when(mockedUserRepository.me(any)).thenAnswer((_) => Future.value(User(id: 0, name: '', type: '')));
    });

    test('LoginButtonPressed event calls logges in and saves token', () async {

      String username = 'username', password = 'password';
      loginBloc.add(LoginButtonPressed(username: username, password: password));
      await untilCalled(mockedUserRepository.authenticate(username: username, password: password));
      await untilCalled(mockedUserRepository.me(any));
      await untilCalled(mockedUserRepository.persistToken(any));
    });

    tearDown(() {
      authenticationBloc.close();
      loginBloc.close();
    });
  });
}
