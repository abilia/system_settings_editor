import 'dart:math' as math;

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:synchronized/extension.dart';

class ActivityRepository extends DataRepository<Activity> {
  ActivityRepository({
    @required String baseUrl,
    @required BaseClient client,
    @required String authToken,
    @required int userId,
    @required ActivityDb activityDb,
  }) : super(
          client: client,
          baseUrl: baseUrl,
          path: 'activities',
          postApiVersion: 2,
          authToken: authToken,
          userId: userId,
          db: activityDb,
          fromJson: DbActivity.fromJson,
          log: Logger((ActivityRepository).toString()),
        );

  @override
  Future<bool> synchronize() async {
    return synchronized(() async {
      final dirtyActivities = await db.getAllDirty();
      if (dirtyActivities.isEmpty) return true;
      try {
        final res = await postData(dirtyActivities);
        if (res.succeded.isNotEmpty) {
          // Update revision and dirty for all successful saves
          await _handleSuccessfullSync(res.succeded, dirtyActivities);
        }
        if (res.failed.isNotEmpty) {
          // If we have failed a fetch from backend needs to be performed
          await _handleFailedSync(res.failed);
        }
      } catch (e) {
        log.warning('Failed to synchronize with backend', e);
        return false;
      }
      return true;
    });
  }

  Future _handleSuccessfullSync(Iterable<DataRevisionUpdates> succeeded,
      Iterable<DbModel<Activity>> dirtyActivities) async {
    final toUpdate = succeeded.map((success) async {
      final activityBeforeSync = dirtyActivities
          .firstWhere((activity) => activity.model.id == success.id);
      final currentActivity = await db.getById(success.id);
      final dirtyDiff = currentActivity.dirty - activityBeforeSync.dirty;
      return currentActivity.copyWith(
        revision: success.revision,
        dirty: math.max(dirtyDiff,
            0), // The activity might have been fetched from backend during the sync and reset with dirty = 0.
      );
    });
    await db.insert(await Future.wait(toUpdate));
  }

  Future _handleFailedSync(Iterable<DataRevisionUpdates> failed) async {
    final minRevision = failed.map((f) => f.revision).reduce(math.min);
    final latestRevision = await db.getLastRevision();
    final revision = math.min(minRevision, latestRevision);
    final fetchedActivities = await fetchData(revision);
    await db.insert(fetchedActivities);
  }
}
