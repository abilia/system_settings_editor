import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seagull/db/support_persons_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/utils/all.dart';

Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  final documentDirectory = await getApplicationDocumentsDirectory();
  final preferences = await SharedPreferences.getInstance();

  final logger = SeagullLogger(
    documentsDir: documentDirectory.path,
    preferences: preferences,
  );
  final log = Logger('BackgroundMessageHandler');

  try {
    log.info('Handling background message...');
    await configureLocalTimeZone();
    final version =
        await PackageInfo.fromPlatform().then((value) => value.version);
    final loginDb = LoginDb(preferences);
    final user = UserDb(preferences).getUser();
    final token = LoginDb(preferences).getToken();
    if (user == null || token == null) {
      log.severe('No user or token: {token $token} {user $user}');
      return;
    }

    final client = ClientWithDefaultHeaders(version,
        loginDb: loginDb, deviceDb: DeviceDb(preferences));
    final database = await DatabaseRepository.createSqfliteDb();
    final baseUrlDb = BaseUrlDb(preferences);

    final activities = await ActivityRepository(
      baseUrlDb: baseUrlDb,
      client: client,
      activityDb: ActivityDb(database),
      userId: user.id,
    ).load();

    final fileStorage = FileStorage(documentDirectory.path);

    await UserFileRepository(
      baseUrlDb: baseUrlDb,
      client: client,
      userFileDb: UserFileDb(database),
      loginDb: loginDb,
      fileStorage: fileStorage,
      userId: user.id,
      multipartRequestBuilder: MultipartRequestBuilder(),
    ).load();

    final settingsDb = SettingsDb(preferences);

    final generics = await GenericRepository(
      baseUrlDb: baseUrlDb,
      client: client,
      genericDb: GenericDb(database),
      userId: user.id,
    ).load();

    final genericsMap = generics.toGenericKeyMap();
    final settings = MemoplannerSettings.fromSettingsMap(
        genericsMap.filterMemoplannerSettingsData());

    log.fine('finding alarms from ${activities.length} activities');

    final timers = await TimerDb(database).getRunningTimersFrom(DateTime.now());
    log.fine('active timers: ${timers.length}');

    await scheduleAlarmNotifications(
      activities,
      timers.toAlarm(),
      settingsDb.language,
      settingsDb.alwaysUse24HourFormat,
      settings.alarm,
      fileStorage,
    );

    await SortableRepository(
      baseUrlDb: baseUrlDb,
      client: client,
      sortableDb: SortableDb(database),
      userId: user.id,
    ).load();

    await SupportPersonsRepository(
      baseUrlDb: baseUrlDb,
      client: client,
      db: SupportPersonsDb(database),
      userId: user.id,
    ).load();
  } catch (e) {
    log.severe('Exception when running background handler', e);
  } finally {
    await logger.cancelLogging();
  }
}
