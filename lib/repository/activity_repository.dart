import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

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
          fromJsonToDataModel: DbActivity.fromJson,
          log: Logger((ActivityRepository).toString()),
        );
}
