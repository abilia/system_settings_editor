import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/repository/all.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  final userDb = UserDb();
  final baseUrlDb = BaseUrlDb();
  final baseUrl = await baseUrlDb.getBaseUrl();
  final user = await userDb.getUser();
  final tokenDb = TokenDb();
  final token = await tokenDb.getToken();
  final activityRepository = ActivityRepository(
      baseUrl: baseUrl,
      client: Client(),
      activitiesDb: ActivityDb(),
      userId: user.id,
      authToken: token);
  final activities = await activityRepository.fetchActivities();
  print('Got activities: ${activities.length}');
}
