import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/repository/all.dart';
import 'all.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  try {
    print('Handling background message...');
    final baseUrl = await BaseUrlDb().getBaseUrl();
    final user = await UserDb().getUser();
    final language = await SettingsDb().getLanguage();
    final alwaysUse24HourFormat = await SettingsDb().getAlwaysUse24HourFormat();
    final token = await TokenDb().getToken();
    final activityDb = ActivityDb();
    final httpClient = Client();
    final activities = await ActivityRepository(
      baseUrl: baseUrl,
      client: httpClient,
      activityDb: activityDb,
      userId: user.id,
      authToken: token,
    ).load();
    await scheduleAlarmNotifications(activities, language: language, alwaysUse24HourFormat: alwaysUse24HourFormat);

    final sortableDb = SortableDb();
    await SortableRepository(
      baseUrl: baseUrl,
      client: httpClient,
      sortableDb: sortableDb,
      userId: user.id,
      authToken: token,
    ).load();
  } catch (e) {
    print('Exception when running background handler $e');
  }
}
