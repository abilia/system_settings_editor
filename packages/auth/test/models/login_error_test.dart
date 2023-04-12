import 'dart:convert';

import 'package:auth/models/login_error.dart';
import 'package:test/test.dart';

void main() {
  test('Parse correct body information', () {
    const testBodyStringCorrect =
        "{\"status\":403,\"message\":\"Clients can only be registered with entities of type 'user'\",\"errorId\":217,\"errors\":[{\"code\":\"WHALE-0156\",\"message\":\"Clients can only be registered with entities of type 'user'\"}]}";
    final error = LoginError.fromJson(jsonDecode(testBodyStringCorrect));
    expect((error).errors.isNotEmpty, true);
  });

  test('Parse body with no errors', () {
    const testBodyStringNoErrors =
        "{\"status\":403,\"message\":\"Clients can only be registered with entities of type 'user'\",\"errorId\":218,\"errors\":[]}";
    final error = LoginError.fromJson(jsonDecode(testBodyStringNoErrors));
    expect((error).errors.isEmpty, true);
  });

  test('Parse empty body', () {
    const testBodyStringEmpty = '{}';
    final error = LoginError.fromJson(jsonDecode(testBodyStringEmpty));
    expect(error.status, -1);
  });
}
