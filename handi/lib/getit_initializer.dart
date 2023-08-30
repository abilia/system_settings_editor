import 'dart:io';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:calendar/all.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:file_storage/file_storage.dart';
import 'package:flutter/material.dart';
import 'package:generics/db/generic_db.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/db/settings_db.dart';
import 'package:handi/main.dart';
import 'package:handi/models/delays.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:seagull_logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sortables/db/sortable_db.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:support_persons/support_persons.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:user_files/db/user_file_db.dart';

Future<void> initGetIt() async => initGetItWith(
      sharedPreferences: await SharedPreferences.getInstance(),
      database: await DatabaseRepository.createSqfliteDb(),
      directory: await getApplicationDocumentsDirectory(),
      ttsHandler: await FlutterTtsHandler.implementation(),
    );

@visibleForTesting
Future<void> initGetItWith({
  required SharedPreferences sharedPreferences,
  required Database database,
  required Directory directory,
  ListenableClient? listenableClient,
  TtsHandler? ttsHandler,
  PackageInfo? packageInfo,
  FirebasePushService? firebasePushService,
  ActivityDb? activityDb,
  SortableDb? sortableDb,
  GenericDb? genericDb,
  UserFileDb? userFileDb,
  LastSyncDb? lastSyncDb,
  Delays? delays,
  SeagullLogger? seagullLogger,
  SettingsDb? settingsDb,
  SupportPersonsDb? supportPersonsDb,
}) async {
  GetIt.I
    ..registerSingleton(sharedPreferences)
    ..registerSingleton(database)
    ..registerSingleton(BaseUrlDb(GetIt.I<SharedPreferences>()))
    ..registerSingleton(LoginDb(GetIt.I<SharedPreferences>()))
    ..registerSingleton(CalendarDb(GetIt.I<Database>()))
    ..registerSingleton(DeviceDb(GetIt.I<SharedPreferences>()))
    ..registerSingleton(LicenseDb(GetIt.I<SharedPreferences>()))
    ..registerSingleton(UserDb(GetIt.I<SharedPreferences>()))
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
    ..registerSingleton<TtsHandler>(ttsHandler ?? FlutterTtsHandler())
    ..registerSingleton<SettingsDb>(settingsDb ?? SettingsDb(sharedPreferences))
    ..registerSingleton<SupportPersonsDb>(
        supportPersonsDb ?? SupportPersonsDb(sharedPreferences))
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
        firebasePushService ?? FirebasePushService());
}
