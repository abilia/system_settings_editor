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
          await handleSuccessfullSync(res.succeded, dirtyActivities);
        }
        if (res.failed.isNotEmpty) {
          // If we have failed a fetch from backend needs to be performed
          await handleFailedSync(res.failed);
        }
      } catch (e) {
        log.warning('Failed to synchronize with backend', e);
        return false;
      }
      return true;
    });
  }
}
