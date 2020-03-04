import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/sortable.dart';

void main() {
  test('parse json test', () {
    final id = "f1069915-ac41-4d74-9449-b8842637b924";
    final revision = 12345;
    final type = "imagearchive";
    final data =
        "{\\\"name\\\":\\\"DVD\\\",\\\"file\\\":\\\"/images/Handi/Handi/DVD_2.gif\\\"}\\\"";
    final expectedData =
        "{\"name\":\"DVD\",\"file\":\"/images/Handi/Handi/DVD_2.gif\"}\"";
    final groupId = "a82c92c0-bee2-4689-9f5d-954de468d5ed";
    final sortOrder = "12309{}";
    final sortableJson = '''
    [
      {
        "id": "$id",
        "revision": $revision,
        "deleted": false,
        "type": "$type",
        "data": "$data",
        "group": false,
        "groupId": "$groupId",
        "sortOrder": "$sortOrder",
        "visible": true
      }
    ]
      ''';

    final sortables = (json.decode(sortableJson) as List)
        .map((e) => DbSortable.fromJson(e))
        .toList();

    expect(sortables.length, 1);
    final dbS = sortables.first;
    final s = dbS.sortable;
    expect(s.id, id);
    expect(s.deleted, false);
    expect(s.type, type);
    expect(s.data, expectedData);
    expect(s.isGroup, false);
    expect(s.groupId, groupId);
    expect(s.sortOrder, sortOrder);
    expect(s.isVisible, true);
    expect(dbS.dirty, 0);
    expect(dbS.revision, revision);
  });
}
