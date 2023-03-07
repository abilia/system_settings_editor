import 'package:handi/getitinitialize.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'fake_client.dart';
import 'fake_db.dart';
import 'fake_shared_preferences.dart';

Future initGetItFakes() async {
  final getit = GetItInitializer()
    ..sharedPreferences = await FakeSharedPreferences.getInstance()
    ..database = FakeDatabase()
    ..listenableClient = fakeClient
    ..packageInfo = PackageInfo(
      appName: '',
      buildNumber: '',
      packageName: '',
      version: '',
    );
  await getit.init();
}
