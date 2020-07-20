import 'dart:async';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'all.dart';

// Don't forgett to register new plugin used in background
// in android/app/src/main/kotlin/com/abilia/seagull/Application.kt
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  final log = Logger('BackgroundMessageHandler');
  final logSubscription = Logger.root.onRecord.listen((record) {
    print(
        'Background: ${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    if (record?.error != null) print(record.error);
    if (record?.stackTrace != null) print(record.stackTrace);
  });

  try {
    log.info('Handling background message...');
    message.forEach((key, value) => log.fine('$key: $value'));
    final baseUrl = await BaseUrlDb().getBaseUrl();
    final httpClient = Client();
    final user = await UserDb().getUser();
    final token = await TokenDb().getToken();

    final activities = await ActivityRepository(
      baseUrl: baseUrl,
      client: httpClient,
      activityDb: ActivityDb(),
      userId: user.id,
      authToken: token,
    ).load();

    final documentDirectory = await getApplicationDocumentsDirectory();
    final fileStorage = FileStorage(documentDirectory.path);

    await UserFileRepository(
      baseUrl: baseUrl,
      httpClient: httpClient,
      userFileDb: UserFileDb(),
      fileStorage: fileStorage,
      userId: user.id,
      authToken: token,
      multipartRequestBuilder: MultipartRequestBuilder(),
    ).load();

    final preferences = await SharedPreferences.getInstance();
    final settingsDb = SettingsDb(preferences);

    log.fine('finding alarms from ${activities.length} activities');

    await scheduleAlarmNotifications(
      activities,
      settingsDb.getLanguage(),
      settingsDb.getAlwaysUse24HourFormat(),
      fileStorage,
    );

    await SortableRepository(
      baseUrl: baseUrl,
      client: httpClient,
      sortableDb: SortableDb(),
      userId: user.id,
      authToken: token,
    ).load();
  } catch (e) {
    log.severe('Exception when running background handler', e);
  } finally {
    await logSubscription.cancel();
  }
}
