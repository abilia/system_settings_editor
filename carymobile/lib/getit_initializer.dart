import 'package:abilia_sync/abilia_sync.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auth/auth.dart';
import 'package:calendar/all.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/background/notification.dart';
import 'package:carymessenger/main.dart';
import 'package:carymessenger/models/delays.dart';
import 'package:connectivity/connectivity_cubit.dart';
import 'package:connectivity/myabilia_connection.dart';
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
import 'package:text_to_speech/text_to_speech.dart';
import 'package:user_files/db/user_file_db.dart';

Future<void> initGetIt() async {
  final directories = Directories(
    applicationSupport: await getApplicationSupportDirectory(),
    documents: await getApplicationDocumentsDirectory(),
    temp: await getTemporaryDirectory(),
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  final supportId = await DeviceDb(sharedPreferences).getSupportId();
  await initGetItWith(
    sharedPreferences: sharedPreferences,
    database: await DatabaseRepository.createSqfliteDb(),
    directories: directories,
    notificationsPlugin: await initFlutterLocalNotificationsPlugin(),
    seagullLogger: SeagullLogger(
      documentsDirectory: directories.documents.path,
      supportId: supportId,
      app: appName,
    ),
  );
}

@visibleForTesting
Future<void> initGetItWith({
  required SharedPreferences sharedPreferences,
  required Database database,
  required Directories directories,
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  ListenableClient? listenableClient,
  PackageInfo? packageInfo,
  FirebasePushService? firebasePushService,
  ActivityDb? activityDb,
  SortableDb? sortableDb,
  GenericDb? genericDb,
  UserFileDb? userFileDb,
  Delays? delays,
  SeagullLogger? seagullLogger,
  TtsHandler? ttsHandler,
  VoiceDb? voiceDb,
  Connectivity? connectivity,
}) async {
  GetIt.I
    ..registerSingleton(directories)
    ..registerSingleton(sharedPreferences)
    ..registerSingleton(database)
    ..registerSingleton(BaseUrlDb(sharedPreferences))
    ..registerSingleton(LoginDb(sharedPreferences))
    ..registerSingleton(CalendarDb(database))
    ..registerSingleton(DeviceDb(sharedPreferences))
    ..registerSingleton(LicenseDb(sharedPreferences))
    ..registerSingleton(UserDb(sharedPreferences))
    ..registerSingleton(
      voiceDb ?? VoiceDb(sharedPreferences, ttsDefault: false),
    )
    ..registerSingleton(Ticker(initialTime: DateTime.now()))
    ..registerSingleton(MultipartRequestBuilder())
    ..registerSingleton(packageInfo ?? await PackageInfo.fromPlatform())
    ..registerSingleton(FileStorage.inDirectory(directories.documents.path))
    ..registerSingleton(activityDb ?? ActivityDb(database))
    ..registerSingleton(sortableDb ?? SortableDb(database))
    ..registerSingleton(genericDb ?? GenericDb(database))
    ..registerSingleton(userFileDb ?? UserFileDb(database))
    ..registerSingleton(LastSyncDb(sharedPreferences))
    ..registerSingleton(delays ?? const Delays())
    ..registerSingleton(seagullLogger ?? SeagullLogger.empty())
    ..registerSingleton(
      listenableClient ??
          ClientWithDefaultHeaders(
            loginDb: GetIt.I<LoginDb>(),
            deviceDb: GetIt.I<DeviceDb>(),
            name: appName,
            version: GetIt.I<PackageInfo>().version,
          ),
    )
    ..registerSingleton(firebasePushService ?? FirebasePushService())
    ..registerSingleton(notificationsPlugin)
    ..registerSingleton(connectivity ?? Connectivity())
    ..registerSingleton(
      MyAbiliaConnection(
        baseUrlDb: GetIt.I<BaseUrlDb>(),
        client: GetIt.I<ListenableClient>(),
      ),
    )
    ..registerSingleton<TtsHandler>(
      ttsHandler ??
          await AcapelaTtsHandler.implementation(
            voicesPath: directories.applicationSupport.path,
            voice: GetIt.I<VoiceDb>().voice,
            speechRate: GetIt.I<VoiceDb>().speechRate,
          ),
    )
    ..registerLazySingleton<AudioPlayer>(() => AudioPlayer());
}
