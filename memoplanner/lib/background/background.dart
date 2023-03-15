import 'dart:async';

import 'package:auth/http_client.dart';
import 'package:auth/licenses_extensions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:memoplanner/config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:memoplanner/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/storage/all.dart';
import 'package:memoplanner/utils/all.dart';

@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final documentDirectory = await getApplicationDocumentsDirectory();
  final preferences = await SharedPreferences.getInstance();

  final deviceDb = DeviceDb(preferences);
  final logger = SeagullLogger(
    documentsDirectory: documentDirectory.path,
    preferences: preferences,
    supportId: await deviceDb.getSupportId(),
  );
  final log = Logger('BackgroundMessageHandler');

  try {
    log.info('Handling background message...');
    final alarmId = message.stopAlarmSoundKey;
    if (alarmId != null) {
      notificationPlugin.cancel(alarmId);
      log.info('Handling alarm and canceling: $alarmId');
      return;
    }

    final now = DateTime.now();
    final licenses = LicenseDb(preferences).getLicenses();
    if (!licenses.anyValidLicense(now, LicenseType.memoplanner)) {
      log.warning('no valid license, among $licenses, will ignore push');
      return;
    }
    await configureLocalTimeZone();
    final version =
        await PackageInfo.fromPlatform().then((value) => value.version);
    final loginDb = LoginDb(preferences);
    final userDb = UserDb(preferences);
    final user = userDb.getUser();
    final token = loginDb.getToken();
    if (user == null || token == null) {
      log.severe('No user or token: {token $token} {user $user}');
      return;
    }

    final client = ClientWithDefaultHeaders(
      loginDb: loginDb,
      deviceDb: deviceDb,
      version: version,
      name: Config.flavor.name,
    );
    final database = await DatabaseRepository.createSqfliteDb();
    final baseUrlDb = BaseUrlDb(preferences);

    final activityRepository = ActivityRepository(
      baseUrlDb: baseUrlDb,
      client: client,
      activityDb: ActivityDb(database),
      userId: user.id,
    );
    await activityRepository.fetchIntoDatabase();
    final activities =
        await activityRepository.allAfter(now.subtract(maxReminder));

    final fileStorage = FileStorage.inDirectory(documentDirectory.path);

    final userFileRepository = UserFileRepository(
      baseUrlDb: baseUrlDb,
      client: client,
      userFileDb: UserFileDb(database),
      loginDb: loginDb,
      fileStorage: fileStorage,
      userId: user.id,
      multipartRequestBuilder: MultipartRequestBuilder(),
    );
    await userFileRepository.fetchIntoDatabase();
    await userFileRepository.downloadUserFiles();

    final settingsDb = SettingsDb(preferences);

    final genericRepository = GenericRepository(
      baseUrlDb: baseUrlDb,
      client: client,
      genericDb: GenericDb(database),
      userId: user.id,
    );
    await genericRepository.fetchIntoDatabase();
    final generics = await genericRepository.getAll();

    final settings = MemoplannerSettings.fromSettingsMap(
      generics.toGenericKeyMap().filterMemoplannerSettingsData(),
    );

    log.fine('finding alarms from ${activities.length} activities');

    final timers = await TimerDb(database).getRunningTimersFrom(now);
    log.fine('active timers: ${timers.length}');

    await scheduleNotifications(
      NotificationsSchedulerData(
        activities: activities,
        timers: timers.toAlarm(),
        language: settingsDb.language,
        alwaysUse24HourFormat: settingsDb.alwaysUse24HourFormat,
        settings: settings.alarm,
        fileStorage: fileStorage,
      ),
      log.log,
    );
  } catch (e) {
    log.severe('Exception when running background handler', e);
  } finally {
    await logger.cancelLogging();
  }
}
