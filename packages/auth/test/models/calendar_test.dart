import 'dart:convert';

import 'package:test/test.dart';

import 'package:auth/models/calendar.dart';

void main() {
  test('from json to dbMap and back', () {
    const json = '{'
        '"id":"d13dda77-7129-4602-b869-182169093d44",'
        '"owner":200,'
        '"type":"MEMOPLANNER",'
        '"main":false'
        '}';
    final cal = Calendar.fromJson(jsonDecode(json));
    final dbMap = cal.toMapForDb();
    final calFromDb = Calendar.fromDbMap(dbMap);

    expect(cal.id, 'd13dda77-7129-4602-b869-182169093d44');
    expect(cal.owner, 200);
    expect(cal.type, 'MEMOPLANNER');
    expect(cal.main, false);

    expect(cal.id, calFromDb.id);
    expect(cal.owner, calFromDb.owner);
    expect(cal.type, calFromDb.type);
    expect(cal.main, calFromDb.main);
  });
}
