import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/authentication/renew_token_cubit.dart';
import '../../fakes/fake_client.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  final mockClient = Fakes.client();
  const String fakeId = 'fakeId';
  const String renewToken = 'renewToken';
  const validResponseToken =
      TokenValid(token: 'token', endDate: 1231244, renewToken: renewToken);

  registerFallbackValues();

  blocTest(
    'create cubit with no additional info',
    build: () => RenewTokenCubit(client: mockClient, baseUrl: ''),
    verify: (RenewTokenCubit bloc) => expect(
      bloc.state,
      const TokenRenewFailed(-1),
    ),
  );

  blocTest(
    'create cubit with additional info',
    build: () => RenewTokenCubit(
        client: mockClient,
        baseUrl: '',
        clientId: fakeId,
        renewToken: renewToken),
    verify: (RenewTokenCubit bloc) => expect(bloc.state, validResponseToken),
  );

  test('supply clientId, no token', () async {
    final renewCubit = RenewTokenCubit(client: mockClient, baseUrl: '');
    final expected = expectLater(
      renewCubit.stream,
      emitsInOrder(
        [
          const TokenRequested(),
          const TokenRenewFailed(401),
        ],
      ),
    );
    renewCubit.requestToken(fakeId, '');
    await expected;
  });

  test('supply clientId, with token', () async {
    final renewCubit = RenewTokenCubit(client: mockClient, baseUrl: '');
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
