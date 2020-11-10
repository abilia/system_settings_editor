import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
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
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  final documentDirectory = await getApplicationDocumentsDirectory();
  final logger = SeagullLogger(documentsDir: documentDirectory.path);
  final log = Logger('BackgroundMessageHandler');

  try {
    log.info('Handling background message...');
    await configureLocalTimeZone();
    final baseUrl = await BaseUrlDb().getBaseUrl();
    final client = Client();
    final user = await UserDb().getUser();
    final token = await TokenDb().getToken();
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

    final preferences = await SharedPreferences.getInstance();
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
