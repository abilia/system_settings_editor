import 'dart:math';
import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/backend/all.dart';

class BackendSyncService {
  final ActivityDb activityDb;
  final ActivityApi activityApi;
  final int userId;

  BackendSyncService({
    @required this.activityDb,
    @required this.activityApi,
    @required this.userId,
  });

  Future<bool> runSync() async {
    print('Sync is running....');
    // Get all dirty activities
    final dirtyActivities = await activityDb.getDirtyActivitiesFromDb();
    if (dirtyActivities.isNotEmpty) {
      // Sync to backend
      try {
        final res =
            await activityApi.postActivities(dirtyActivities.toList(), userId);
        if (res.succeded.isNotEmpty) {
          // Update revision and dirty for all successful saves
          final toUpdate = res.succeded.map((s) {
            final a = dirtyActivities.firstWhere((a) => a.id == s.id);
            return a.copyWith(
              dirty: 0,
              revision: s.revision,
            ); // TODO get current dirty and subtract
          });
          await activityDb.insertActivities(toUpdate);
        }
        if (res.failed.isNotEmpty) {
          // If we have failed a fetch from backend needs to be performed
          final m = res.failed.map((f) => f.revision).reduce(min);
          await activityApi.fetchActivities(m, userId);
        }
      } catch (e) {
        print('Oh no could not save to backend please try again later');
        return false;
      }
    }
    return true;
  }
}
