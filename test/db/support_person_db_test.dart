import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/support_person.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const testSupportPerson = SupportPerson(id: 0, name: 'Test', image: '');
  const testSupportPerson2 = SupportPerson(id: 1, name: 'Test 2', image: '');
  const supportUsers = [testSupportPerson, testSupportPerson2];

  late SupportPersonsDb supportPersonsDb;

  setUp(() async {
    supportPersonsDb = SupportPersonsDb(await SharedPreferences.getInstance());
  });

  test('Test insert list, get and compare', () async {
    await supportPersonsDb.insertAll(supportUsers);

    Iterable<SupportPerson> fromDb = supportPersonsDb.getAll();

    Function listEquals = const ListEquality().equals;

    expect(listEquals(supportUsers, fromDb.toList()), true);
  });

  tearDown(() async {
    (await SharedPreferences.getInstance()).remove('supportUsers');
  });
}
