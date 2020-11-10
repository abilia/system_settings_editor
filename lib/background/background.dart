import 'dart:async';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'all.dart';

// Don't forget to register new plugin used in background
// in android/app/src/main/kotlin/com/abilia/seagull/Application.kt
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  final documentDirectory = await getApplicationDocumentsDirectory();
  final preferences = await SharedPreferences.getInstance();

  final logger = SeagullLogger(
    documentsDir: documentDirectory.path,
    preferences: preferences,
  );
  final log = Logger('BackgroundMessageHandler');

  try {
    log.info('Handling background message...');
    message.forEach((key, value) => log.fine('$key: $value'));
    await configureLocalTimeZone();
    final baseUrl = BaseUrlDb(preferences).getBaseUrl();
    final client = Client();
    final user = UserDb(preferences).getUser();
    final token = TokenDb(preferences).getToken();
    final database = await DatabaseRepository.createSqfliteDb();

    final activities = await ActivityRepository(
      baseUrl: baseUrl,
      client: client,
      activityDb: ActivityDb(database),
      userId: user.id,
      authToken: token,
    ).load();

    final fileStorage = FileStorage(documentDirectory.path);

    await UserFileRepository(
      baseUrl: baseUrl,
      client: client,
      userFileDb: UserFileDb(database),
      fileStorage: fileStorage,
      userId: user.id,
      authToken: token,
      multipartRequestBuilder: MultipartRequestBuilder(),
    ).load();

    final settingsDb = SettingsDb(preferences);

    log.fine('finding alarms from ${activities.length} activities');

    await scheduleAlarmNotifications(
      activities,
      settingsDb.language,
      settingsDb.alwaysUse24HourFormat,
      fileStorage,
    );

    await SortableRepository(
      baseUrl: baseUrl,
      client: client,
      sortableDb: SortableDb(database),
      userId: user.id,
      authToken: token,
    ).load();
  } catch (e) {
    log.severe('Exception when running background handler', e);
  } finally {
    await logger.cancelLogging();
  }
}
