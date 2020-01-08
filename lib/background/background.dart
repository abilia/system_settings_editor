import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/repository/all.dart';
import 'all.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  print('Handling background message...');
  final baseUrl = await BaseUrlDb().getBaseUrl();
  final user = await UserDb().getUser();
  final token = await TokenDb().getToken();
  final activities = await ActivityRepository(
          baseUrl: baseUrl,
          client: Client(),
          activitiesDb: ActivityDb(),
          userId: user.id,
          authToken: token)
      .loadActivities();
  await scheduleAlarmNotifications(activities, language: user.language);
}
