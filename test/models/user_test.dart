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
    "image" : "image"
  }''';

    final asJson = json.decode(response);
    final user = User.fromJson(asJson);
    expect(user.id, -1);
    expect(user.type, 'testcase');
    expect(user.name, 'Testcase user');
    expect(user.username, 'testcase');
    expect(user.language, 'sv');
    expect(user.image, 'image');
    expect(
        user.props,
        containsAll(
            [-1, 'testcase', 'testcase', 'sv', 'Testcase user', 'image']));
  });

  test('from json with null', () {
    final response = '''{
    "id" : 121,
    "type" : "null",
    "name" : null,
    "username" : null,
    "language" : null,
    "image" : null
  }''';

    final asJson = json.decode(response);
    final user = User.fromJson(asJson);
    expect(user.id, 121);
    expect(user.type, 'null');
    expect(user.name, '');
    expect(user.username, '');
    expect(user.language, '');
    expect(user.image, '');
    expect(user.props, containsAll([121, 'null', '', '', '', '']));
  });

  test('from json then to json', () {
    final response = '''{
    "id" : -1,
    "type" : "testcase",
    "name" : "Testcase user",
    "username" : "testcase",
    "language" : "sv",
    "image" : ""
  }''';

    final asJson = json.decode(response);
    final user = User.fromJson(asJson);
    final toJsonAgain = user.toJson();
    expect(toJsonAgain, asJson);
  });
}
