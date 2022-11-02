import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';

void main() {
  test('parse json', () {
    const response = '''
    {
      "previousRevision" : 100,
      "dataRevisionUpdates" : [ {
        "id" : "cc207923-2946-465d-be17-128fb19765cb",
        "newRevision" : 101
      } ],
      "failedUpdates" : [ {
        "id" : "99e777cb-f4d5-4899-9be2-d5dcc9f309d2",
        "newRevision" : 100
      } ]
    }
    ''';
    final asJson = json.decode(response);
    final data = DataUpdateResponse.fromJson(asJson);
    expect(data.previousRevision, 100);
    expect(data.succeeded.length, 1);
    final dataRevisionUpdate = data.succeeded.first;
    expect(dataRevisionUpdate.id, 'cc207923-2946-465d-be17-128fb19765cb');
    expect(dataRevisionUpdate.revision, 101);

    expect(data.failed.length, 1);
    final failedUpdate = data.failed.first;
    expect(failedUpdate.id, '99e777cb-f4d5-4899-9be2-d5dcc9f309d2');
    expect(failedUpdate.revision, 100);
  });
  test('parse json with no failedUpdates', () {
    const response = '''
    {
      "previousRevision" : 100,
      "dataRevisionUpdates" : [ {
        "id" : "cc207923-2946-465d-be17-128fb19765cb",
        "newRevision" : 101
      } ]
    }
    ''';
    final asJson = json.decode(response);
    final data = DataUpdateResponse.fromJson(asJson);
    expect(data.previousRevision, 100);
    expect(data.succeeded.length, 1);
    final dataRevisionUpdate = data.succeeded.first;
    expect(dataRevisionUpdate.id, 'cc207923-2946-465d-be17-128fb19765cb');
    expect(dataRevisionUpdate.revision, 101);

    expect(data.failed.length, 0);
  });

  test('Parse json with no successful', () {
    const response = '''
    {
      "previousRevision" : 100,
      "dataRevisionUpdates" : [],
      "failedUpdates" : [ {
        "id" : "99e777cb-f4d5-4899-9be2-d5dcc9f309d2",
        "newRevision" : 101
      } ]
    }
    ''';
    final asJson = json.decode(response);
    final data = DataUpdateResponse.fromJson(asJson);
    expect(data.previousRevision, 100);
    expect(data.succeeded.length, 0);
    expect(data.failed.length, 1);
  });
}
