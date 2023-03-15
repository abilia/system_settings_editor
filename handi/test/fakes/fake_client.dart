import 'package:auth/models/license.dart';
import 'package:auth/models/user.dart';
import 'package:http/http.dart';
import 'package:seagull_fakes/all.dart';

const int userId = 1234;
const user = User(id: userId, type: type, name: name);
const String token = 'token',
    name = 'Test case user',
    username = 'username',
    type = 'test case',
    incorrectPassword = 'wrong wrong wrong',
    supportUserName = 'supportUser';

ListenableMockClient fakeClient = ListenableMockClient((request) async {
  final pathSegments = request.url.pathSegments.toSet();
  if (pathSegments.containsAll(['auth', 'client', 'me'])) {
    return Response('''
    {
      "token" : "$token",
      "endDate" : 1231244,
      "renewToken" : ""
    }''', 200);
  }
  if (pathSegments.containsAll(['license', 'portal', 'me'])) {
    return Response('''
    [
      {
        "id":125,
        "endTime":${11111111111111},
        "product":"${LicenseType.handi.name}"
      }
    ]
  ''', 200);
  }
  if (pathSegments.containsAll(['entity', 'me'])) {
    return Response('''
    {
      "me" : {
        "id" : 1234,
        "type" : "$type",
        "name" : "$name",
        "username" : "$username",
        "language" : "sv",
        "image" : null
      }
    }''', 200);
  }
  return Response('', 404);
});
