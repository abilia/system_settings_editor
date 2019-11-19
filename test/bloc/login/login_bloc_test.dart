import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/authentication/bloc.dart';
import 'package:seagull/bloc/login/bloc.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/repository/user_repository.dart';

import '../../mocks.dart';

void main() {
  group('LoginBloc event order', () {
    LoginBloc loginBloc;
    AuthenticationBloc authenticationBloc;

    setUp(() {
      final userRepository = UserRepository(httpClient: Fakes.client(), secureStorage: MockSecureStorage());
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
        AuthenticationLoading(),
        Unauthenticated(),
        AuthenticationLoading(),
        Authenticated(token: Fakes.token, userId: Fakes.userId),
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
      when(mockedUserRepository.getToken()).thenAnswer((_) => Future.value(Fakes.token));
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
