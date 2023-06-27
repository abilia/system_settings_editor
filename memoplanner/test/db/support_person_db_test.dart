import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/all.dart';

void main() {
  const testSupportPerson = SupportPerson(id: 0, name: 'Test', image: '');
  const testSupportPerson2 = SupportPerson(id: 1, name: 'Test 2', image: '');
  final supportUsers = {testSupportPerson, testSupportPerson2};

  late SupportPersonsDb supportPersonsDb;

  setUp(() async {
    supportPersonsDb =
        SupportPersonsDb(await FakeSharedPreferences.getInstance());
  });

  test('Test insert list, get and compare', () async {
    await supportPersonsDb.insertAll(supportUsers);

    final fromDb = supportPersonsDb.getAll();

    final listEquals = const SetEquality().equals;

    expect(listEquals(supportUsers, fromDb), true);
  });

  tearDown(() async {
    (await SharedPreferences.getInstance()).remove('supportUsers');
  });
}
