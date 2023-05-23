import 'package:auth/auth.dart';
import 'package:calendar/all.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:handi/main.dart';
import 'package:handi/models/sync_delays.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

Future<void> initGetIt() => initGetItWith();

@visibleForTesting
Future<void> initGetItWith({
  ListenableClient? listenableClient,
  PackageInfo? packageInfo,
  SharedPreferences? sharedPreferences,
  FirebasePushService? firebasePushService,
  Database? database,
}) async {
  GetIt.I
    ..registerSingleton<SharedPreferences>(
      sharedPreferences ?? await SharedPreferences.getInstance(),
    )
    ..registerSingleton(
      database ?? await DatabaseRepository.createSqfliteDb(),
    )
    ..registerSingleton(BaseUrlDb(GetIt.I<SharedPreferences>()))
    ..registerSingleton(LoginDb(GetIt.I<SharedPreferences>()))
    ..registerSingleton(CalendarDb(GetIt.I<Database>()))
    ..registerSingleton(DeviceDb(GetIt.I<SharedPreferences>()))
    ..registerSingleton(LicenseDb(GetIt.I<SharedPreferences>()))
    ..registerSingleton(UserDb(GetIt.I<SharedPreferences>()))
    ..registerSingleton(Ticker(initialTime: DateTime.now()))
    ..registerSingleton(packageInfo ?? await PackageInfo.fromPlatform())
    ..registerSingleton(
      listenableClient ??
          ClientWithDefaultHeaders(
            loginDb: GetIt.I<LoginDb>(),
            deviceDb: GetIt.I<DeviceDb>(),
            name: appName,
            version: GetIt.I<PackageInfo>().version,
          ),
    )
    ..registerSingleton<SyncDelays>(SyncDelays.zero)
    ..registerSingleton<FirebasePushService>(
        firebasePushService ?? FirebasePushService());
}
