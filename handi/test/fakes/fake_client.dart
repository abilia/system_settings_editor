import 'dart:convert';
import 'dart:io';

import 'package:auth/models/all.dart';
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
  final incorrect =
      'Basic ${base64Encode(utf8.encode('$username:$incorrectPassword'))}';
  final pathSegments = request.url.pathSegments.toSet();
  final authHeaders = request.headers[HttpHeaders.authorizationHeader];
  if (authHeaders == incorrect) {
    return Response(
        '{"timestamp":"${DateTime.now()}","status":401,"error":"Unauthorized","message":"Unable to authorize","path":"//api/v1/auth/client/me"}',
        401);
  }
  if (pathSegments.containsAll(<String>{'auth', 'client', 'me'})) {
    return Response('''
    {
      "token" : "$token",
      "endDate" : 1231244,
      "renewToken" : ""
    }''', 200);
  }
  if (pathSegments.containsAll(<String>{'license', 'portal', 'me'})) {
    return Response('''
    [
      {
        "id":125,
        "endTime":${11111111111111},
        "product":"${Product.handicalendar.name}"
      }
    ]
  ''', 200);
  }
  if (pathSegments.containsAll(<String>{'entity', 'me'})) {
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
