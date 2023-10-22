import 'dart:io';

import 'package:carymessenger/getit_initializer.dart';
import 'package:carymessenger/models/delays.dart';
import 'package:connectivity/connectivity_cubit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_fakes/all.dart';

import 'acapela_tts_handler.dart';
import 'fake_client.dart';
import 'fake_connectivity.dart';
import 'fake_db.dart';
import 'flutter_local_notifications_plugin.dart';

Future<void> initGetItFakes({
  Connectivity? connectivity,
  bool loggedIn = false,
}) async =>
    initGetItWith(
      listenableClient: fakeClient,
      sharedPreferences: await FakeSharedPreferences.getInstance(
        loggedIn: loggedIn,
      ),
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
      voiceDb: FakeVoiceDb(),
      connectivity: connectivity ?? FakeConnectivity(),
    );
