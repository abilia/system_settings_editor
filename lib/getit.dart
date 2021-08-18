import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/repository/default_http_client.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/utils/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetItInitializer {
  Directory? _documentsDirectory;
  set documentsDirectory(Directory documentsDirectory) =>
      _documentsDirectory = documentsDirectory;

  late SharedPreferences _sharedPreferences;
  set sharedPreferences(SharedPreferences sharedPreferences) =>
      _sharedPreferences = sharedPreferences;

  ActivityDb? _activityDb;
  set activityDb(ActivityDb activityDb) => _activityDb = activityDb;

  late FirebasePushService _firebasePushService = FirebasePushService();
  set fireBasePushService(FirebasePushService firebasePushService) =>
      _firebasePushService = firebasePushService;

  UserDb? _userDb;
  set userDb(UserDb userDb) => _userDb = userDb;

  TokenDb? _tokenDb;
  set tokenDb(TokenDb tokenDb) => _tokenDb = tokenDb;

  LicenseDb? _licenseDb;
  set licenseDb(LicenseDb licenseDb) => _licenseDb = licenseDb;

  late Ticker _ticker = Ticker();
  set ticker(Ticker ticker) => _ticker = ticker;

  late AlarmScheduler _alarmScheduler = scheduleAlarmNotificationsIsolated;
  set alarmScheduler(AlarmScheduler alarmScheduler) =>
      _alarmScheduler = alarmScheduler;

  BaseUrlDb? _baseUrlDb;
  set baseUrlDb(BaseUrlDb baseUrlDb) => _baseUrlDb = baseUrlDb;

  BaseClient? _baseClient;
  set client(BaseClient baseClient) => _baseClient = baseClient;

  SortableDb? _sortableDb;
  set sortableDb(SortableDb sortableDb) => _sortableDb = sortableDb;

  GenericDb? _genericDb;
  set genericDb(GenericDb genericDb) => _genericDb = genericDb;

  UserFileDb? _userFileDb;
  set userFileDb(UserFileDb userFileDb) => _userFileDb = userFileDb;

  FileStorage? _fileStorage;
  set fileStorage(FileStorage fileStorage) => _fileStorage = fileStorage;

  SettingsDb? _settingsDb;
  set settingsDb(SettingsDb settingsDb) => _settingsDb = settingsDb;

  late MultipartRequestBuilder _multipartRequestBuilder =
      MultipartRequestBuilder();
  set multipartRequestBuilder(
          MultipartRequestBuilder multipartRequestBuilder) =>
      _multipartRequestBuilder = multipartRequestBuilder;

  late SyncDelays _syncDelay = const SyncDelays();
  set syncDelay(SyncDelays syncDelay) => _syncDelay = syncDelay;

  late Database _database;
  set database(Database database) => _database = database;

  late SeagullLogger _seagullLogger = SeagullLogger(
    documentsDir: _documentsDirectory?.path ?? '',
    preferences: _sharedPreferences,
    loggingType: {},
  );
  set seagullLogger(SeagullLogger seagullLogger) =>
      _seagullLogger = seagullLogger;

  late AlarmNavigator _alarmNavigator = AlarmNavigator();
  set alarmNavigator(AlarmNavigator alarmNavigator) =>
      _alarmNavigator = alarmNavigator;

  late FlutterTts _flutterTts = FlutterTts();
  set flutterTts(FlutterTts flutterTts) => _flutterTts = flutterTts;

  late PackageInfo _packageInfo =
      PackageInfo(appName: '', buildNumber: '', packageName: '', version: '');
  set packageInfo(PackageInfo packageInfo) => _packageInfo = packageInfo;

  void init() => GetIt.I
    ..registerSingleton<BaseClient>(
        _baseClient ?? ClientWithDefaultHeaders(_packageInfo.version))
    ..registerSingleton<TokenDb>(_tokenDb ?? TokenDb(_sharedPreferences))
    ..registerSingleton<LicenseDb>(_licenseDb ?? LicenseDb(_sharedPreferences))
    ..registerSingleton<FirebasePushService>(_firebasePushService)
    ..registerSingleton<ActivityDb>(_activityDb ?? ActivityDb(_database))
    ..registerSingleton<UserDb>(_userDb ?? UserDb(_sharedPreferences))
    ..registerSingleton<Database>(_database)
    ..registerSingleton<SeagullLogger>(_seagullLogger)
    ..registerSingleton<BaseUrlDb>(_baseUrlDb ?? BaseUrlDb(_sharedPreferences))
    ..registerSingleton<AlarmScheduler>(_alarmScheduler)
    ..registerSingleton<Ticker>(_ticker)
    ..registerSingleton<AlarmNavigator>(_alarmNavigator)
    ..registerSingleton<SortableDb>(_sortableDb ?? SortableDb(_database))
    ..registerSingleton<GenericDb>(_genericDb ?? GenericDb(_database))
    ..registerSingleton<UserFileDb>(_userFileDb ?? UserFileDb(_database))
    ..registerSingleton<SettingsDb>(
      _settingsDb ?? SettingsDb(_sharedPreferences),
    )
    ..registerSingleton<FileStorage>(
        _fileStorage ?? FileStorage(_documentsDirectory?.path))
    ..registerSingleton<MultipartRequestBuilder>(_multipartRequestBuilder)
    ..registerSingleton<SyncDelays>(_syncDelay)
    ..registerSingleton<FlutterTts>(_flutterTts)
    ..registerSingleton<PackageInfo>(_packageInfo);
}
