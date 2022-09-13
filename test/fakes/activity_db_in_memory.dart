import 'package:collection/collection.dart';
import 'package:logging/src/logger.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/meta_models.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/utils/all.dart';

class ActivityDbInMemory implements ActivityDb {
  final List<DbModel<Activity>> activities = [];

  void clear() {
    activities.clear();
  }

  void initWithActivity(Activity activity) {
    initWithActivities([activity]);
  }

  void initWithActivities(Iterable<Activity> toInsert) {
    activities.clear();
    activities.addAll(toInsert.map((a) => a.wrapWithDbModel()));
  }

  @override
  DbMapTo<Activity> get convertToDataModel => DbActivity.fromDbMap;

  @override
  Database get db => throw UnimplementedError();

  @override
  Future<Iterable<Activity>> getAll() async {
    return activities.map((e) => e.model);
  }

  @override
  Future<Iterable<Activity>> getAllAfter(DateTime time) async {
    return activities.map((e) => e.model).where((a) => !a.deleted);
  }

  @override
  Future<Iterable<Activity>> getAllBetween(DateTime start, DateTime end) async {
    return activities.map((e) => e.model).where((a) => !a.deleted);
  }

  @override
  Future<Iterable<DbModel<Activity>>> getAllDirty() async {
    return activities.where((e) => e.dirty > 0);
  }

  @override
  String get getAllDirtySql => throw UnimplementedError();

  @override
  Future<Iterable<Activity>> getAllNonDeleted() async {
    return activities.map((e) => e.model).where((a) => !a.deleted);
  }

  @override
  String get getAllNonDeletedSql => throw UnimplementedError();

  @override
  String get getAllSql => throw UnimplementedError();

  @override
  Future<DbModel<Activity>?> getById(String id) async {
    return activities.firstWhereOrNull((e) => e.model.id == id);
  }

  @override
  String get getByIdSql => throw UnimplementedError();

  @override
  Future<int> getLastRevision() async {
    return activities.fold<int>(
        0,
        (previousValue, e) =>
            e.revision > previousValue ? previousValue : e.revision);
  }

  @override
  Future<void> insert(Iterable<DbModel<Activity>> dataModels) async {
    activities.addAll(dataModels);
  }

  @override
  Future<bool> insertAndAddDirty(Iterable<Activity> data) async {
    final insertResult = data.map((model) async {
      final existing = await getById(model.id);
      final dirty = existing?.dirty ?? 0;
      final revision = existing?.revision ?? 0;
      if (existing != null) {
        activities.remove(existing);
      }
      insert([model.wrapWithDbModel(revision: revision, dirty: dirty)]);
    });
    await Future.wait(insertResult);
    return true;
  }

  @override
  Logger get log => throw UnimplementedError();

  @override
  String get maxRevisionSql => throw UnimplementedError();

  @override
  Iterable<DbModel<Activity>> rowsToDbModels(List<Map<String, Object?>> rows) =>
      rows
          .exceptionSafeMap(convertToDataModel,
              onException: log.logAndReturnNull)
          .whereNotNull();

  @override
  Iterable<Activity> rowsToModels(List<Map<String, Object?>> rows) =>
      rowsToDbModels(rows).map((data) => data.model);

  @override
  String get tableName => '';
}
