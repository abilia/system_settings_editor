import 'package:collection/collection.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseRepository {
  DatabaseRepository._();
  static const activityTableName = 'calendar_activity';
  static const sortableTableName = 'sortable';
  static const userFileTableName = 'user_file';
  static const genericTableName = 'generic';
  static const timerTableName = 'timer';
  static const calendarTableName = 'calendar';

  static const tablesWithUserData = [
    activityTableName,
    sortableTableName,
    userFileTableName,
    genericTableName,
    timerTableName,
    calendarTableName
  ];

  static final initialScript = [
    '''
      create table $activityTableName (
        id text primary key not null,
        series_id text not null,
        title text,
        start_time int,
        end_time int,
        duration int,
        file_id text,
        category int,
        deleted int,
        full_day int,
        recurrent_type int,
        recurrent_data int,
        reminder_before text,
        icon text,
        info_item text,
        revision int,
        alarm_type int,
        checkable int default 0,
        signed_off_dates text,
        dirty int default 0,
        remove_after int default 0,
        secret int default 0,
        timezone text
      )
    ''',
    '''
      create table $sortableTableName (
        id text primary key not null,
        revision int,
        deleted int,
        type text,
        data text,
        is_group int,
        group_id text,
        sort_order text,
        visible int,
        dirty int
      )
''',
    '''
      create table $userFileTableName (
        id text primary key not null,
        revision int,
        deleted int,
        sha1 text,
        md5 text,
        path text,
        content_type text,
        file_size int,
        dirty int,
        file_loaded int default 0
      )
''',
    '''
      create table $genericTableName (
        id text primary key not null,
        revision int,
        deleted int,
        type text,
        identifier text,
        data text,
        dirty int
      )
'''
  ];

  static const String _createTimersTable = '''
    create table $timerTableName (
          id text primary key not null,
          title text,
          file_id text,
          paused int,
          start_time int,
          duration int,
          paused_at int
        )
  ''';
  static const String _createCalendarTable = '''
    create table $calendarTableName (
          id text primary key not null,
          type text,
          owner int,
          main int
        )
  ''';

  static final migrations = <String>[
    'alter table $activityTableName add column extras text',
    'alter table $sortableTableName add column fixed int',
    _createTimersTable,
    'alter table $activityTableName add column calendar_id text',
    _createCalendarTable,
    'alter table $activityTableName add column secret_exemptions text',
  ];

  static Future<Database> createSqfliteDb() async {
    final databasesPath = await getDatabasesPath();
    return await openDatabase(
      join(databasesPath, 'seagull.db'),
      version: migrations.length + 1,
      onCreate: executeInitialization,
      onUpgrade: executeMigration,
    );
  }

  static Future<Database> createInMemoryFfiDb() async {
    sqfliteFfiInit();
    return await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: migrations.length + 1,
        onCreate: executeInitialization,
        onUpgrade: executeMigration,
      ),
    );
  }

  static Future clearAll(Database db) {
    final batch = db.batch()
      ..delete(activityTableName)
      ..delete(sortableTableName)
      ..delete(userFileTableName)
      ..delete(timerTableName)
      ..delete(genericTableName)
      ..delete(calendarTableName);
    return batch.commit();
  }

  static Future<bool> isEmpty(Database db) async {
    final allTableSelectCount = await Future.wait(tablesWithUserData
        .map((table) => db.rawQuery('select count(*) from $table')));
    final allTableRows =
        allTableSelectCount.map(Sqflite.firstIntValue).whereNotNull().toList();
    return allTableRows.sum == 0;
  }

  static Future<void> executeInitialization(Database db, int version) async {
    for (final script in initialScript) {
      await db.execute(script);
    }
    for (final script in migrations) {
      await db.execute(script);
    }
  }

  static Future<void> executeMigration(
      Database db, int oldVersion, int newVersion) async {
    await internalMigration(db, oldVersion, newVersion, migrations);
  }

  static Future<void> internalMigration(Database db, int oldVersion,
      int newVersion, List<String> migrationScripts) async {
    migrationScripts
        .skip(oldVersion - 1)
        .forEach((script) async => await db.execute(script));
  }
}
