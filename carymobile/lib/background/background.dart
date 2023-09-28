import 'dart:async';

import 'package:auth/auth.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/firebase_options.dart';
import 'package:carymessenger/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_logging/seagull_logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utils/utils.dart';

@pragma('vm:entry-point')
Future<void> myBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final documentDirectory = await getApplicationDocumentsDirectory();
  final preferences = await SharedPreferences.getInstance();

  final deviceDb = DeviceDb(preferences);
  final log = Logger('BackgroundMessageHandler');
  final logger = SeagullLogger(
    documentsDirectory: documentDirectory.path,
    preferences: preferences,
    supportId: await deviceDb.getSupportId(),
    app: appName,
  );

  try {
    log.info('Handling background message...');

    final now = DateTime.now();
    final licenses = LicenseDb(preferences).getLicenses();
    if (!licenses.anyValidLicense(now)) {
      log.warning('no valid license, among $licenses, will ignore push');
      return;
    }

    await configureLocalTimeZone();

    final loginDb = LoginDb(preferences);
    final user = UserDb(preferences).getUser();
    final token = loginDb.getToken();

    if (user == null || token == null) {
      log.severe('No user or token: {token $token} {user $user}');
      return;
    }

    await ActivityRepository(
      baseUrlDb: BaseUrlDb(preferences),
      client: ClientWithDefaultHeaders(
        loginDb: loginDb,
        deviceDb: deviceDb,
        version:
            await PackageInfo.fromPlatform().then((value) => value.version),
        name: appName,
      ),
      activityDb: ActivityDb(await DatabaseRepository.createSqfliteDb()),
      userId: user.id,
    ).fetchIntoDatabase();
  } catch (e) {
    log.severe('Exception when running background handler', e);
  } finally {
    await logger.cancelLogging();
  }
}
