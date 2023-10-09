import 'dart:io';

import 'package:carymessenger/db/settings_db.dart';
import 'package:carymessenger/getit_initializer.dart';
import 'package:carymessenger/models/delays.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_fakes/all.dart';

import 'acapela_tts_handler.dart';
import 'fake_client.dart';
import 'flutter_local_notifications_plugin.dart';

Future<void> initGetItFakes() async => initGetItWith(
      listenableClient: fakeClient,
      sharedPreferences:
          await FakeSharedPreferences.getInstance(loggedIn: false, extras: {
        SettingsDb.productionGuideDoneRecord: true,
      }),
      database: FakeDatabase(),
      directories: Directories(
        applicationSupport: Directory.systemTemp,
        documents: Directory.systemTemp,
        temp: Directory.systemTemp,
      ),
      firebasePushService: FakeFirebasePushService(),
      delays: Delays.zero,
      sortableDb: FakeSortableDb(),
      userFileDb: FakeUserFileDb(),
      packageInfo: PackageInfo(
        appName: '',
        buildNumber: '',
        packageName: '',
        version: '',
      ),
      notificationsPlugin: FakeFlutterLocalNotificationsPlugin(),
      ttsHandler: FakeAcapelaTtsHandler(),
    );
