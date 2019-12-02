import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_migration/sqflite_migration.dart';

class DatabaseRepository {
  static final _initialScript = [
    '''
      create table calendar_activity (
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
        alarm_type int
      )
    ''',
  ];

  static final _migrations = <String>[];

  static final _config = MigrationConfig(
      initializationScript: _initialScript, migrationScripts: _migrations);

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await _open();
    return _database;
  }

  Future<Database> _open() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'seagull.db');
    await deleteDatabase(path);
    return await openDatabaseWithMigration(path, _config);
  }
}
