import 'package:auth/auth.dart';
import 'package:calendar_repository/calendar_db.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:handi/main.dart';

// TODO replace with real push token
class FakeFirebasePushService implements FirebasePushService {
  @override
  Future<String?> initPushToken() async => '';
}

class GetItInitializer {
  Database? _database;
  set database(Database database) => _database = database;

  SharedPreferences? _sharedPreferences;
  set sharedPreferences(SharedPreferences sharedPreferences) =>
      _sharedPreferences = sharedPreferences;

  PackageInfo? _packageInfo;
  set packageInfo(PackageInfo packageInfo) => _packageInfo = packageInfo;

  ListenableClient? _listenableClient;
  set listenableClient(ListenableClient listenableClient) =>
      _listenableClient = listenableClient;

  Future init() async {
    GetIt.I
      ..registerSingleton<SharedPreferences>(
        _sharedPreferences ?? await SharedPreferences.getInstance(),
      )
      ..registerSingleton(
        _database ?? await DatabaseRepository.createSqfliteDb(),
      )
      ..registerSingleton(BaseUrlDb(GetIt.I<SharedPreferences>()))
      ..registerSingleton(LoginDb(GetIt.I<SharedPreferences>()))
      ..registerSingleton(CalendarDb(GetIt.I<Database>()))
      ..registerSingleton(DeviceDb(GetIt.I<SharedPreferences>()))
      ..registerSingleton(LicenseDb(GetIt.I<SharedPreferences>()))
      ..registerSingleton(UserDb(GetIt.I<SharedPreferences>()))
      ..registerSingleton(Ticker(initialTime: DateTime.now()))
      ..registerSingleton(_packageInfo ?? await PackageInfo.fromPlatform())
      ..registerSingleton(
        _listenableClient ??
            ClientWithDefaultHeaders(
              loginDb: GetIt.I<LoginDb>(),
              deviceDb: GetIt.I<DeviceDb>(),
              name: appName,
              version: GetIt.I<PackageInfo>().version,
            ),
      )
      ..registerSingleton<FirebasePushService>(FakeFirebasePushService());
  }
}
