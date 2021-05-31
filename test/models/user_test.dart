// @dart=2.9

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';

void main() {
  test('from json', () {
    final response = '''{
    "id" : -1,
    "type" : "testcase",
    "name" : "Testcase user",
    "username" : "testcase",
    "language" : "sv",
    "image" : null
  }''';

    final asJson = json.decode(response);
    final user = User.fromJson(asJson);
    expect(user.id, -1);
    expect(user.type, 'testcase');
    expect(user.name, 'Testcase user');
    expect(user.username, 'testcase');
    expect(user.language, 'sv');
    expect(user.image, null);
    expect(user.props,
        containsAll([-1, 'testcase', 'testcase', 'sv', 'Testcase user', null]));
  });
  test('from json then to json', () {
    final response = '''{
    "id" : -1,
    "type" : "testcase",
    "name" : "Testcase user",
    "username" : "testcase",
    "language" : "sv",
    "image" : null
  }''';

    final asJson = json.decode(response);
    final user = User.fromJson(asJson);
    final toJsonAgain = user.toJson();
    expect(toJsonAgain, asJson);
  });
}
