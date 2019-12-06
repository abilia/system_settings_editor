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
    UserRepository userRepository;
    MockFirebasePushService mockFirebasePushService;

    setUp(() {
      userRepository = UserRepository(
          httpClient: Fakes.client(),
          secureStorage: MockSecureStorage(),
          userDb: MockUserDb());
      authenticationBloc =
          AuthenticationBloc(databaseRepository: MockDatabaseRepository());
      mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('pushToken'));

      loginBloc = LoginBloc(
          authenticationBloc: authenticationBloc,
          pushService: mockFirebasePushService);
    });

    test('initial state is LoginInitial', () {
      expect(loginBloc.initialState, LoginInitial());
    });

    test('LoginState and AuthenticationState in correct order', () async {
      final List<LoginState> expectedLoginStates = [
        LoginInitial(),
        LoginLoading(),
        LoginInitial(),
      ];
      final List<AuthenticationState> expectedAuthenticationStates = [
        AuthenticationUninitialized(),
        AuthenticationLoading(userRepository),
        Unauthenticated(userRepository),
        AuthenticationLoading(userRepository),
        Authenticated(
            token: Fakes.token,
            userId: Fakes.userId,
            userRepository: userRepository),
      ];

      expectLater(
        authenticationBloc,
        emitsInOrder(expectedAuthenticationStates),
      );

      expectLater(
        loginBloc,
        emitsInOrder(expectedLoginStates),
      );

      authenticationBloc.add(AppStarted(userRepository));
      await authenticationBloc
          .firstWhere((s) => s is AuthenticationInitialized);
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
    MockFirebasePushService mockFirebasePushService;

    setUp(() {
      mockedUserRepository = MockUserRepository();
      authenticationBloc =
          AuthenticationBloc(databaseRepository: MockDatabaseRepository())
            ..add(AppStarted(mockedUserRepository));
      mockFirebasePushService = MockFirebasePushService();
      loginBloc = LoginBloc(
          authenticationBloc: authenticationBloc,
          pushService: mockFirebasePushService);
      when(mockedUserRepository.getToken())
          .thenAnswer((_) => Future.value(Fakes.token));
      when(mockedUserRepository.me(any))
          .thenAnswer((_) => Future.value(User(id: 0, name: '', type: '')));
    });

    test('LoginButtonPressed event calls logges in and saves token', () async {
      String username = 'username',
          password = 'password',
          fakePushToken = 'fakePushToken';
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value(fakePushToken));
      loginBloc.add(LoginButtonPressed(username: username, password: password));
      await untilCalled(mockedUserRepository.authenticate(
          username: username, password: password, pushToken: fakePushToken));
      await untilCalled(mockedUserRepository.me(any));
      await untilCalled(mockedUserRepository.persistToken(any));
    });

    tearDown(() {
      authenticationBloc.close();
      loginBloc.close();
    });
  });
}
