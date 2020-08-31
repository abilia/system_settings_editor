import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/db/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  test('executeInitialization calls all scripts', () {
    final mockDb = MockDatabase();

    DatabaseRepository.executeInitialization(mockDb, 1);
    DatabaseRepository.initialScript.forEach((s) => verify(mockDb.execute(s)));
    DatabaseRepository.migrations.forEach((m) => verify(mockDb.execute(m)));
  });

  test('executeMigration do not call old scripts', () {
    final migrationScript1 = 'script1';
    final migrationScript2 = 'script2';
    final migrations = <String>[migrationScript1, migrationScript2];
    final mockDb = MockDatabase();
    DatabaseRepository.internalMigration(mockDb, 2, 3, migrations);
    verifyNever(mockDb.execute(migrationScript1));
    verify(mockDb.execute(migrationScript2));
  });
}
