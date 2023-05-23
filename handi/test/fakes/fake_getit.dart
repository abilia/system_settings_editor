import 'package:handi/getit_initializer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:seagull_fakes/all.dart';

import 'fake_client.dart';
import 'fake_firebase_push_service.dart';

Future<void> initGetItFakes() async => initGetItWith(
      listenableClient: fakeClient,
      sharedPreferences:
          await FakeSharedPreferences.getInstance(loggedIn: false),
      database: FakeDatabase(),
      firebasePushService: FakeFirebasePushService(),
      packageInfo: PackageInfo(
        appName: '',
        buildNumber: '',
        packageName: '',
        version: '',
      ),
    );
