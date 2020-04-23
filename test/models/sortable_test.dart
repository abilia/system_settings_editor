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
    expect(s.visible, true);
    expect(dbS.dirty, 0);
    expect(dbS.revision, revision);
  });

  test('To dbMap and back', () {
    final dbMap = {
      "id": "id-111",
      "type": "type",
      "data": "dbdata",
      "group_id": "group_id",
      "sort_order": "sort_order",
      "deleted": 1,
      "is_group": 1,
      "visible": 1,
      "revision": 999,
      "dirty": 1,
    };
    final dbSortable = DbSortable.fromDbMap(dbMap);
    expect(dbSortable.dirty, 1);
    expect(dbSortable.revision, 999);
    final s = dbSortable.sortable;
    expect(s.id, "id-111");
    expect(s.data, "dbdata");
    expect(s.type, "type");
    expect(s.groupId, "group_id");
    expect(s.sortOrder, "sort_order");
    expect(s.isGroup, true);
    expect(s.visible, true);
    expect(s.deleted, true);

    final mapAgain = dbSortable.toMapForDb();
    expect(mapAgain, dbMap);
  });
}
