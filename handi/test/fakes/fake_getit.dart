import 'dart:io';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:handi/getit_initializer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:seagull_fakes/all.dart';

import 'fake_client.dart';

Future<void> initGetItFakes() async => initGetItWith(
      listenableClient: fakeClient,
      sharedPreferences:
          await FakeSharedPreferences.getInstance(loggedIn: false),
      database: FakeDatabase(),
      directory: Directory('documents'),
      firebasePushService: FakeFirebasePushService(),
      syncDelays: SyncDelays.zero,
      sortableDb: FakeSortableDb(),
      userFileDb: FakeUserFileDb(),
      packageInfo: PackageInfo(
        appName: '',
        buildNumber: '',
        packageName: '',
        version: '',
      ),
    );
