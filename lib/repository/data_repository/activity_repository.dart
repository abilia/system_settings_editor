import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

class ActivityRepository extends DataRepository<Activity> {
  ActivityRepository({
    required BaseUrlDb baseUrlDb,
    required BaseClient client,
    required int userId,
    required ActivityDb activityDb,
  }) : super(
          client: client,
          baseUrlDb: baseUrlDb,
          path: 'activities',
          postApiVersion: 3,
          userId: userId,
          db: activityDb,
          fromJsonToDataModel: DbActivity.fromJson,
          log: Logger((ActivityRepository).toString()),
        );
}
