import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/authentication/renew_token_cubit.dart';
import '../../mocks/mocks.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  const String fakeId = 'fakeId';
  const String renewToken = 'renewToken';
  const validResponseToken =
      TokenValid(token: 'token', endDate: 1231244, renewToken: renewToken);
  final mockedUserRepository = MockUserRepository();

  when(() => mockedUserRepository.requestToken(any(), ''))
      .thenAnswer((_) => Future.value());
  when(() => mockedUserRepository.requestToken(fakeId, renewToken)).thenAnswer(
      (_) => Future.value(jsonDecode(
          '{"token":"token", "endDate":1231244, "renewToken":"$renewToken"}')));
  registerFallbackValues();

  blocTest(
    'create cubit with no additional info',
    build: () => RenewTokenCubit(userRepository: mockedUserRepository),
    verify: (RenewTokenCubit bloc) => expect(
      bloc.state,
      const TokenRenewFailed(),
    ),
  );

  blocTest(
    'create cubit with additional info',
    build: () => RenewTokenCubit(
        userRepository: mockedUserRepository,
        clientId: fakeId,
        renewToken: renewToken),
    verify: (RenewTokenCubit bloc) => expect(bloc.state, validResponseToken),
  );

  test('supply clientId, no token', () async {
    final renewCubit = RenewTokenCubit(userRepository: mockedUserRepository);
    final expected = expectLater(
      renewCubit.stream,
      emitsInOrder(
        [
          const TokenRequested(),
          const TokenRenewFailed(),
        ],
      ),
    );
    renewCubit.requestToken(fakeId, '');
    await expected;
  });

  test('supply clientId, with token', () async {
    final renewCubit = RenewTokenCubit(userRepository: mockedUserRepository);
    final expected = expectLater(
      renewCubit.stream,
      emitsInOrder(
        [
          const TokenRequested(),
          validResponseToken,
        ],
      ),
    );
    renewCubit.requestToken(fakeId, renewToken);
    await expected;
  });
}
