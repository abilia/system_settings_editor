import 'package:auth/fake/all.dart';
import 'package:handi/getit_initializer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:repository_base/fake/all.dart';

import 'fake_client.dart';

Future<void> initGetItFakes() async => initGetItWith(
      listenableClient: fakeClient,
      sharedPreferences:
          await FakeSharedPreferences.getInstance(loggedIn: false),
      database: FakeDatabase(),
      packageInfo: PackageInfo(
        appName: '',
        buildNumber: '',
        packageName: '',
        version: '',
      ),
    );
