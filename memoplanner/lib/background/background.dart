import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info/package_info.dart';
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

  final logger = SeagullLogger(
    documentsDirectory: documentDirectory.path,
    preferences: preferences,
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
    if (!licenses.anyValidLicense(now)) {
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

    final deviceDb = DeviceDb(preferences);
    final client = ClientWithDefaultHeaders(
      version,
      loginDb: loginDb,
      deviceDb: deviceDb,
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

    final fileStorage = FileStorage(documentDirectory.path);

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

    await scheduleAlarmNotifications(
      activities,
      timers.toAlarm(),
      settingsDb.language,
      settingsDb.alwaysUse24HourFormat,
      settings.alarm,
      fileStorage,
    );
  } catch (e) {
    log.severe('Exception when running background handler', e);
  } finally {
    await logger.cancelLogging();
  }
}