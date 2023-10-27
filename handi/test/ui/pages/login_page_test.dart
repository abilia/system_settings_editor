import 'dart:async';

import 'package:auth/bloc/authentication/authentication_bloc.dart';
import 'package:auth/bloc/login/login_cubit.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/l10n/all.dart';
import 'package:handi/ui/pages/logged_in_page.dart';
import 'package:handi/ui/pages/login/login_page.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:seagull_fakes/all.dart';

import '../../extensions/finder_extensions.dart';
import '../../extensions/tester_extensions.dart';
import '../../fakes/fake_getit.dart';

void main() {
  late final Lt translate;
  final loginCubit = MockLoginCubit();
  final longUsername =
      'a7nDY7qyd87QEWBYFNDH87Wefyb8ew7ftbvFVT76EWFTFUHWGRUFA8ERWBGY7REGF' * 231;
  final longPassword =
      '98jw3t7vf8934hyvtg87yh5gw4yt3hf7gy7vwh9ydfh74yg5w3trd3467grtfd673' * 231;

  setUpAll(() async {
    setupPermissions();
    await Lokalise.initMock();
    translate = await Lt.load(Lt.supportedLocales.first);

    when(() => loginCubit.state).thenReturn(LoginState.initial());
    when(() => loginCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => loginCubit.close()).thenAnswer((_) => Future.value());
  });

  setUp(() {
    initGetItFakes();
  });

  tearDown(() => GetIt.I.reset());

  Future<void> pumpAndSettleLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [Lt.delegate],
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<UserRepository>(
              create: (_) => FakeUserRepository(),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthenticationBloc>(
                create: (_) => FakeAuthenticationBloc(),
              ),
              BlocProvider<LoginCubit>(
                create: (_) => loginCubit,
              ),
              BlocProvider<ClockCubit>(
                create: (_) => ClockCubit(
                  StreamController<DateTime>().stream,
                  initialTime: DateTime.now(),
                ),
              ),
            ],
            child: const LoginPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Login button', () {
    testWidgets('Disabled when username or password is empty', (tester) async {
      await tester.pumpAndSettleHandiApp();
      expect(tester.loginButton.onPressed, isNull);

      await tester.enterTextAndSettle(find.usernameField, 'username');
      await tester.enterTextAndSettle(find.passwordField, '');
      expect(tester.loginButton.onPressed, isNull);

      await tester.enterTextAndSettle(find.usernameField, '');
      await tester.enterTextAndSettle(find.passwordField, 'password');
      expect(tester.loginButton.onPressed, isNull);
    });

    testWidgets(
        'Disabled when username is only empty spaces and two characters',
        (tester) async {
      await tester.pumpAndSettleHandiApp();
      expect(tester.loginButton.onPressed, isNull);

      await tester.enterTextAndSettle(find.usernameField, '    us    ');
      await tester.enterTextAndSettle(find.passwordField, 'password');

      expect(tester.loginButton.onPressed, isNull);
    });

    testWidgets('Enabled when password is only empty spaces', (tester) async {
      await tester.pumpAndSettleHandiApp();
      expect(tester.loginButton.onPressed, isNull);

      await tester.enterTextAndSettle(find.usernameField, 'username');
      await tester.enterTextAndSettle(find.passwordField, '     ');

      expect(tester.loginButton.onPressed, isNotNull);
    });

    testWidgets(
        'Enabled when username is three characters and password is one character',
        (tester) async {
      await tester.pumpAndSettleHandiApp();
      expect(tester.loginButton.onPressed, isNull);

      await tester.enterTextAndSettle(find.usernameField, 'use');
      await tester.enterTextAndSettle(find.passwordField, 'p');

      expect(tester.loginButton.onPressed, isNotNull);
    });
  });

  group('Input fields', () {
    testWidgets('Username and password can be maximum 128 characters',
        (tester) async {
      await tester.pumpAndSettleHandiApp();

      await tester.enterTextAndSettle(find.usernameField, longUsername);
      await tester.enterTextAndSettle(find.passwordField, longPassword);

      expect(find.text(longUsername), findsNothing);
      expect(find.text(longPassword), findsNothing);

      expect(find.text(longUsername.substring(0, 128)), findsOneWidget);
      expect(find.text(longPassword.substring(0, 128)), findsOneWidget);
    });

    testWidgets('Play tts icon appears when username is not empty',
        (tester) async {
      await tester.pumpAndSettleHandiApp();
      expect(find.byIcon(Symbols.play_circle), findsNothing);

      await tester.enterTextAndSettle(find.usernameField, 'u');
      expect(find.byIcon(Symbols.play_circle), findsOneWidget);
    });

    testWidgets('Tapping eye icon toggles obscure password', (tester) async {
      await tester.pumpAndSettleHandiApp();

      await tester.enterTextAndSettle(find.passwordField, 'password');
      expect(tester.passwordField.obscureText, isTrue);

      await tester.tapAndSettle(find.byIcon(Symbols.visibility));
      expect(tester.passwordField.obscureText, isFalse);

      await tester.tapAndSettle(find.byIcon(Symbols.visibility));
      expect(tester.passwordField.obscureText, isTrue);
    });
  });

  group('Login', () {
    testWidgets('Can login with correct credentials', (tester) async {
      await tester.pumpAndSettleHandiApp();

      await tester.enterText(find.usernameField, FakeListenableClient.username);
      await tester.enterTextAndSettle(find.passwordField, 'pword');

      await tester.tapAndSettle(find.loginButton);
      expect(find.byType(LoggedInPage), findsOneWidget);
    });

    testWidgets('Can not login with wrong credentials', (tester) async {
      await tester.pumpAndSettleHandiApp();

      await tester.enterText(find.usernameField, FakeListenableClient.username);
      await tester.enterTextAndSettle(
        find.passwordField,
        FakeListenableClient.incorrectPassword,
      );
      await tester.tapAndSettle(find.loginButton);

      expect(find.byIcon(Symbols.error), findsOneWidget);
      expect(find.text(translate.verifyCredentials), findsOneWidget);
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });

  group('Error messages', () {
    Future<void> pumpLoginAndFillFields(WidgetTester tester) async {
      await pumpAndSettleLoginPage(tester);
      await tester.enterText(find.usernameField, 'username');
      await tester.enterTextAndSettle(find.passwordField, 'password');
      await tester.tapAndSettle(find.loginButton);
    }

    testWidgets('Invalid credentials', (tester) async {
      when(() => loginCubit.state).thenReturn(
        loginCubit.state.failure(cause: LoginFailureCause.credentials),
      );
      await pumpLoginAndFillFields(tester);

      expect(find.byIcon(Symbols.error), findsOneWidget);
      expect(find.text(translate.verifyCredentials), findsOneWidget);
    });

    testWidgets('No username', (tester) async {
      when(() => loginCubit.state).thenReturn(
        loginCubit.state.failure(cause: LoginFailureCause.noUsername),
      );
      await pumpLoginAndFillFields(tester);

      expect(find.byIcon(Symbols.error), findsOneWidget);
      expect(find.text(translate.verifyCredentials), findsOneWidget);
    });

    testWidgets('No password', (tester) async {
      when(() => loginCubit.state).thenReturn(
        loginCubit.state.failure(cause: LoginFailureCause.noPassword),
      );
      await pumpLoginAndFillFields(tester);

      expect(find.byIcon(Symbols.error), findsOneWidget);
      expect(find.text(translate.verifyCredentials), findsOneWidget);
    });

    testWidgets('Too many attempts', (tester) async {
      when(() => loginCubit.state).thenReturn(
        loginCubit.state.failure(cause: LoginFailureCause.tooManyAttempts),
      );
      await pumpLoginAndFillFields(tester);

      expect(find.byIcon(Symbols.lightbulb), findsOneWidget);
      expect(find.text(translate.tooManyAttempts), findsOneWidget);
    });

    testWidgets('No license', (tester) async {
      when(() => loginCubit.state).thenReturn(
        loginCubit.state.failure(cause: LoginFailureCause.noLicense),
      );
      await pumpLoginAndFillFields(tester);

      expect(find.byIcon(Symbols.error), findsOneWidget);
      expect(find.text(translate.noHandiLicence), findsOneWidget);
    });

    testWidgets('License expired', (tester) async {
      when(() => loginCubit.state).thenReturn(
        loginCubit.state.failure(cause: LoginFailureCause.licenseExpired),
      );
      await pumpLoginAndFillFields(tester);

      expect(find.byIcon(Symbols.error), findsOneWidget);
      expect(find.text(translate.lincenseExpired), findsOneWidget);
    });

    testWidgets('No license', (tester) async {
      when(() => loginCubit.state).thenReturn(
        loginCubit.state.failure(cause: LoginFailureCause.noConnection),
      );
      await pumpLoginAndFillFields(tester);

      expect(find.byIcon(Symbols.error), findsOneWidget);
      expect(find.text(translate.connectToInternet), findsOneWidget);
    });

    testWidgets('Not empty database', (tester) async {
      when(() => loginCubit.state).thenReturn(
        loginCubit.state.failure(cause: LoginFailureCause.notEmptyDatabase),
      );
      await pumpLoginAndFillFields(tester);

      expect(find.byIcon(Symbols.error), findsOneWidget);
      expect(find.text(translate.somethingWentWrong), findsOneWidget);
    });

    testWidgets('Unsupported user type', (tester) async {
      when(() => loginCubit.state).thenReturn(
        loginCubit.state.failure(cause: LoginFailureCause.unsupportedUserType),
      );
      await pumpLoginAndFillFields(tester);

      expect(find.byIcon(Symbols.error), findsOneWidget);
      expect(find.text(translate.unsupportedUserType), findsOneWidget);
    });
  });
}
