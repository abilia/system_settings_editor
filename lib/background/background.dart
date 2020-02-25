import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/backend/activity_api.dart';
import 'all.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print('Handling background message...');
  final baseUrl = await BaseUrlDb().getBaseUrl();
  final user = await UserDb().getUser();
  final token = await TokenDb().getToken();
  final activityDb = ActivityDb();
  final httpClient = Client();
  final activityApi = ActivityApi(
    baseUrl: baseUrl,
    httpClient: httpClient,
    authToken: token,
  );
  final activities = await ActivityRepository(
    baseUrl: baseUrl,
    client: httpClient,
    activityDb: activityDb,
    activityApi: activityApi,
    userId: user.id,
  ).loadActivities();
  await scheduleAlarmNotifications(activities, language: user.language);
}
