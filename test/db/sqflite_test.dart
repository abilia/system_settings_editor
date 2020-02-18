import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/db/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  test('executeInitialization calls all scripts', () {
    final mockDb = MockDatabase();

    DatabaseRepository().executeInitialization(mockDb, 1);
    DatabaseRepository.initialScript.forEach((s) => verify(mockDb.execute(s)));
    DatabaseRepository.migrations.forEach((m) => verify(mockDb.execute(m)));
  });

  test('executeMigration calls all scripts new scripts', () {
    final mockDb = MockDatabase();
    DatabaseRepository().executeMigration(mockDb, 1, 1);
    DatabaseRepository.migrations.forEach((m) => verify(mockDb.execute(m)));
  });
}
