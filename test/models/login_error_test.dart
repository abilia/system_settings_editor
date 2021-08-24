import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/login_error.dart';

void main() {
  test('Parse correct body information', () {
    final testBodyStringCorrect =
        "{\"status\":403,\"message\":\"Clients can only be registered with entities of type 'user'\",\"errorId\":217,\"errors\":[{\"code\":\"WHALE-0156\",\"message\":\"Clients can only be registered with entities of type 'user'\"}]}";
    final error = LoginError.fromJson(jsonDecode(testBodyStringCorrect));
    expect((error).errors.isNotEmpty, true);
  });

  test('Parse body with no errors', () {
    final testBodyStringNoErrors =
        "{\"status\":403,\"message\":\"Clients can only be registered with entities of type 'user'\",\"errorId\":218,\"errors\":[]}";
    final error = LoginError.fromJson(jsonDecode(testBodyStringNoErrors));
    expect((error).errors.isEmpty, true);
  });

  test('Parse empty body', () {
    final testBodyStringEmpty = '{}';
    final error = LoginError.fromJson(jsonDecode(testBodyStringEmpty));
    expect(error.status, -1);
  });
}
