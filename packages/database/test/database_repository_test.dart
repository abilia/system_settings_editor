import 'package:database/database_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test/test.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  test('executeInitialization calls all scripts', () async {
    final mockDb = MockDatabase();
    when(() => mockDb.execute(any(), any())).thenAnswer((_) => Future.value());

    await DatabaseRepository.executeInitialization(mockDb, 1);
    for (final s in DatabaseRepository.initialScript) {
      verify(() => mockDb.execute(s));
    }
    for (final m in DatabaseRepository.migrations) {
      verify(() => mockDb.execute(m));
    }
  });

  test('executeMigration do not call old scripts', () {
    const migrationScript1 = 'script1';
    const migrationScript2 = 'script2';
    final migrations = <String>[migrationScript1, migrationScript2];
    final mockDb = MockDatabase();
    when(() => mockDb.execute(any(), any())).thenAnswer((_) => Future.value());
    DatabaseRepository.internalMigration(mockDb, 2, 3, migrations);
    verifyNever(() => mockDb.execute(migrationScript1));
    verify(() => mockDb.execute(migrationScript2));
  });
}
