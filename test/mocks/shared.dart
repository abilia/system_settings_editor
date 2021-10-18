import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';

import 'package:mockito/annotations.dart';
import 'package:record/record.dart';

import 'package:seagull/db/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';

@GenerateMocks([
  // Repository
  ActivityRepository,
  UserRepository,
  SortableRepository,
  UserFileRepository,

  // Storage
  FileStorage,

  // Database
  Database,
  SettingsDb,
  ActivityDb,
  SortableDb,
  UserFileDb,
  GenericDb,
  UserDb,
  TokenDb,
  LicenseDb,

  // MISC
  FirebasePushService,
  MultipartRequestBuilder,
  Notification,
  Record,

  // Plugin
  FlutterLocalNotificationsPlugin,

  // Dart/Flutter
  BaseClient,
  ScrollController,
  ScrollPosition,
])
class Notification {
  Future mockCancelAll() => Future.value();
}
