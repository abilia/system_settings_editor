import 'dart:convert';

import 'package:auth/http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

import '../fakes/all.dart';
import '../mocks/mocks.dart';
import '../test_helpers/register_fallback_values.dart';

void main() {
  final deviceDb = MockDeviceDb();
  final loginDb = MockLoginDb();
  final innerClient = MockBaseClient();
  final client = ClientWithDefaultHeaders(
    deviceDb: deviceDb,
    loginDb: loginDb,
    client: innerClient,
    version: 'version',
    name: 'name',
  );

  setUp(() {
    registerFallbackValues();
  });

  test('New login info is fetched and stored when getting 401', () async {
    // Arrange
    const oldToken = 'oldToken';
    const baseUrl = 'http://baseurl';
    const requestUrl = '$baseUrl/api/request';
    const renewUrl = '$baseUrl/open/v1/token/renew';
    const checkAccessUrl = '$baseUrl/api/v1/entity/me';
    const clientId = 'sdlkfj';
    when(
      () => innerClient.send(any()),
    ).thenAnswer(
        (_) => Future.value(StreamedResponse(Stream.fromIterable([]), 401)));
    when(
      () => innerClient.get(
        checkAccessUrl.toUri(),
        headers: authHeader(oldToken),
      ),
    ).thenAnswer((_) => Future.value(Response('', 401)));
    when(
      () => innerClient.get(requestUrl.toUri(), headers: authHeader(oldToken)),
    ).thenAnswer((_) => Future.value(Response('', 401)));
    const oldLoginInfo =
        LoginInfo(token: oldToken, endDate: 1, renewToken: 'renewToken');
    const newLoginInfo =
        LoginInfo(token: 'newToken', endDate: 2, renewToken: 'newRenew');

    when(
      () => innerClient.post(
        renewUrl.toUri(),
        body: jsonEncode(
          {
            'clientId': clientId,
            'renewToken': oldLoginInfo.renewToken,
          },
        ),
        headers: jsonHeader,
      ),
    ).thenAnswer(
        (_) => Future.value(Response(jsonEncode(newLoginInfo.toJson()), 200)));

    when(() => loginDb.getLoginInfo()).thenReturn(oldLoginInfo);
    when(() => loginDb.getToken()).thenReturn(oldToken);
    when(() => deviceDb.getClientId())
        .thenAnswer((_) => Future.value(clientId));

    //Act
    // Get something
    await client.get('$baseUrl/$requestUrl'.toUri());

    // Verify that new login info has been saved
    //Assert
    verify(() => loginDb.persistLoginInfo(newLoginInfo));
  });
}
