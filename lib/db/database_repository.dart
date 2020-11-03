import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:seagull/db/all.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final _log = Logger((DatabaseRepository).toString());

class DatabaseRepository {
  DatabaseRepository._();
  static const CALENDAR_TABLE_NAME = 'calendar_activity';
  static const SORTABLE_TABLE_NAME = 'sortable';
  static const USER_FILE_TABLE_NAME = 'user_file';
  static const GENERIC_TABLE_NAME = 'generic';
  @visibleForTesting
  static final initialScript = [
    '''
      create table $CALENDAR_TABLE_NAME (
        id text primary key not null,
        series_id text not null,
        title text,
        start_time int,
        end_time int,
        duration int ,
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
        signed_off_dates text
      )
    ''',
  ];
  @visibleForTesting
  static final migrations = <String>[
    '''
      ALTER TABLE $CALENDAR_TABLE_NAME ADD COLUMN dirty int default 0
    ''',
    '''
      ALTER TABLE $CALENDAR_TABLE_NAME ADD COLUMN remove_after int default 0
    ''',
    '''
      ALTER TABLE $CALENDAR_TABLE_NAME ADD COLUMN secret int default 0
    ''',
    '''
      CREATE TABLE $SORTABLE_TABLE_NAME (
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
      CREATE TABLE $USER_FILE_TABLE_NAME (
        id text primary key not null,
        revision int,
        deleted int,
        sha1 text,
        md5 text,
        path text,
        content_type text,
        file_size int,
        dirty int
      )
    ''',
    '''
      ALTER TABLE $USER_FILE_TABLE_NAME ADD COLUMN file_loaded int default 0
    ''',
    '''
      ALTER TABLE $CALENDAR_TABLE_NAME ADD COLUMN timezone text
    ''',
    '''
      CREATE TABLE $GENERIC_TABLE_NAME (
        id text primary key not null,
        revision int,
        deleted int,
        type text,
        identifier text,
        data text,
        dirty int
      )
    ''',
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

  @visibleForTesting
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

  static Future logAll(Database db) async {
    void logTable(List<Map<String, dynamic>> calendar) {
      if (calendar.isEmpty) return;
      _log.info(calendar.first.keys.join('\t\t'));
      calendar.forEach((element) {
        _log.info(element.values.join('\t'));
      });
    }

    final calendar = await db.rawQuery(
        'select id, title, file_id, revision, dirty, deleted from $CALENDAR_TABLE_NAME order by revision desc');
    _log.info('------------------- CALENDAR ---------------------');
    logTable(calendar);
    final userFile = await db.rawQuery(
        'select id, revision, deleted, path, content_type, file_loaded from $USER_FILE_TABLE_NAME order by revision desc');
    _log.info('------------------- USER FILES ---------------------');
    logTable(userFile);
    final sortables = await db.rawQuery(
        'select id, data, revision, dirty, deleted, is_group, type, group_id from $SORTABLE_TABLE_NAME order by revision desc');
    _log.info('------------------- SORTABLES ---------------------');
    logTable(sortables);
  }

  static Future clearAll(Database db) {
    final batch = db.batch()
      ..delete(CALENDAR_TABLE_NAME)
      ..delete(SORTABLE_TABLE_NAME)
      ..delete(USER_FILE_TABLE_NAME)
      ..delete(GENERIC_TABLE_NAME);
    return batch.commit();
  }

  @visibleForTesting
  static Future<void> executeInitialization(Database db, int version) async {
    initialScript.forEach((script) async => await db.execute(script));
    migrations.forEach((script) async => await db.execute(script));
  }

  @visibleForTesting
  static Future<void> executeMigration(
      Database db, int oldVersion, int newVersion) async {
    await internalMigration(db, oldVersion, newVersion, migrations);
  }

  @visibleForTesting
  static Future<void> internalMigration(Database db, int oldVersion,
      int newVersion, List<String> migrationScripts) async {
    migrationScripts
        .skip(oldVersion - 1)
        .forEach((script) async => await db.execute(script));
  }
}
