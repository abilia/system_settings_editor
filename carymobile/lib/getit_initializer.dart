import 'dart:io';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:calendar/all.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/background/notification.dart';
import 'package:carymessenger/db/settings_db.dart';
import 'package:carymessenger/main.dart';
import 'package:carymessenger/models/delays.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:generics/db/generic_db.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:seagull_logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sortables/db/sortable_db.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:user_files/db/user_file_db.dart';

Future<void> initGetIt() async {
  final directory = await getApplicationDocumentsDirectory();
  final sharedPreferences = await SharedPreferences.getInstance();
  final deviceDb = DeviceDb(sharedPreferences);
  final supportId = await deviceDb.getSupportId();
  await initGetItWith(
    sharedPreferences: sharedPreferences,
    database: await DatabaseRepository.createSqfliteDb(),
    directory: directory,
    deviceDb: deviceDb,
    notificationsPlugin: await initFlutterLocalNotificationsPlugin(),
    seagullLogger: SeagullLogger(
      documentsDirectory: directory.path,
      supportId: supportId,
      app: appName,
    ),
  );
}

@visibleForTesting
Future<void> initGetItWith({
  required SharedPreferences sharedPreferences,
  required Database database,
  required Directory directory,
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  ListenableClient? listenableClient,
  PackageInfo? packageInfo,
  FirebasePushService? firebasePushService,
  ActivityDb? activityDb,
  SortableDb? sortableDb,
  GenericDb? genericDb,
  UserFileDb? userFileDb,
  LastSyncDb? lastSyncDb,
  DeviceDb? deviceDb,
  Delays? delays,
  SeagullLogger? seagullLogger,
  SettingsDb? settingsDb,
}) async {
  GetIt.I
    ..registerSingleton(sharedPreferences)
    ..registerSingleton(database)
    ..registerSingleton(BaseUrlDb(sharedPreferences))
    ..registerSingleton(LoginDb(sharedPreferences))
    ..registerSingleton(CalendarDb(database))
    ..registerSingleton(deviceDb ?? DeviceDb(sharedPreferences))
    ..registerSingleton(LicenseDb(sharedPreferences))
    ..registerSingleton(UserDb(sharedPreferences))
    ..registerSingleton(Ticker(initialTime: DateTime.now()))
    ..registerSingleton(MultipartRequestBuilder())
    ..registerSingleton(packageInfo ?? await PackageInfo.fromPlatform())
    ..registerSingleton(FileStorage.inDirectory(directory.path))
    ..registerSingleton(activityDb ?? ActivityDb(database))
    ..registerSingleton(sortableDb ?? SortableDb(database))
    ..registerSingleton(genericDb ?? GenericDb(database))
    ..registerSingleton(userFileDb ?? UserFileDb(database))
    ..registerSingleton(lastSyncDb ?? LastSyncDb(sharedPreferences))
    ..registerSingleton(delays ?? const Delays())
    ..registerSingleton(seagullLogger ?? SeagullLogger.empty())
    ..registerSingleton<SettingsDb>(settingsDb ?? SettingsDb(sharedPreferences))
    ..registerSingleton(
      listenableClient ??
          ClientWithDefaultHeaders(
            loginDb: GetIt.I<LoginDb>(),
            deviceDb: GetIt.I<DeviceDb>(),
            name: appName,
            version: GetIt.I<PackageInfo>().version,
          ),
    )
    ..registerSingleton<FirebasePushService>(
        firebasePushService ?? FirebasePushService())
    ..registerSingleton(notificationsPlugin);
}
