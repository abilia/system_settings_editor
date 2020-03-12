import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseRepository {
  static const CALENDAR_TABLE_NAME = 'calendar_activity';
  static const SORTABLE_TABLE_NAME = 'sortable';
  static const USER_FILE_TABLE_NAME = 'user_file';
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
        sha1 text,
        path text,
        content_type text,
        file_size int,
        dirty int
      )
    ''',
    '''
      CREATE TABLE $USER_FILE_TABLE_NAME (
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
  ];

  static Database _database;
  Future<Database> get database async => _database ??= await _open();

  Future<Database> _open() async {
    print('Open the sqflite');
    final databasesPath = await getDatabasesPath();
    return await openDatabase(
      join(databasesPath, 'seagull.db'),
      version: migrations.length + 1,
      onCreate: executeInitialization,
      onUpgrade: executeMigration,
    );
  }

  Future clearAll() async {
    final db = await database;
    final batch = db.batch();
    batch.delete(CALENDAR_TABLE_NAME);
    batch.delete(SORTABLE_TABLE_NAME);
    batch.delete(USER_FILE_TABLE_NAME);
    await batch.commit();
  }

  @visibleForTesting
  Future<void> executeInitialization(Database db, int version) async {
    initialScript.forEach((script) async => await db.execute(script));
    migrations.forEach((script) async => await db.execute(script));
  }

  @visibleForTesting
  Future<void> executeMigration(
      Database db, int oldVersion, int newVersion) async {
    await internalMigration(db, oldVersion, newVersion, migrations);
  }

  @visibleForTesting
  Future<void> internalMigration(Database db, int oldVersion, int newVersion,
      List<String> migrationScripts) async {
    migrationScripts
        .skip(oldVersion - 1)
        .forEach((script) async => await db.execute(script));
  }
}
