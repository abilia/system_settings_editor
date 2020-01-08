import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/repository/all.dart';
import 'all.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print('Handling background message...');
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
  final activities = await activityRepository.loadActivities(amount: 9999);
  print('Sceduling ${activities.length} activities with language: ${user.language}');
  await scheduleAlarmNotifications(activities, language: user.language);
}
