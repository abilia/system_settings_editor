import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/tts/tts_handler.dart';
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

  TimerDb? _timerDb;

  set timerDb(TimerDb timerDb) => _timerDb = timerDb;

  late FirebasePushService _firebasePushService = FirebasePushService();

  set fireBasePushService(FirebasePushService firebasePushService) =>
      _firebasePushService = firebasePushService;

  UserDb? _userDb;

  set userDb(UserDb userDb) => _userDb = userDb;

  LoginDb? _loginDb;

  set loginDb(LoginDb loginDb) => _loginDb = loginDb;

  LicenseDb? _licenseDb;

  set licenseDb(LicenseDb licenseDb) => _licenseDb = licenseDb;

  late Ticker _ticker = Ticker(initialTime: DateTime.now());

  set ticker(Ticker ticker) => _ticker = ticker;

  BaseUrlDb? _baseUrlDb;

  set baseUrlDb(BaseUrlDb baseUrlDb) => _baseUrlDb = baseUrlDb;

  DeviceDb? _deviceDb;

  set deviceDb(DeviceDb deviceDb) => _deviceDb = deviceDb;

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

  late SyncDelays _syncDelay = SyncDelays.zero;

  set syncDelay(SyncDelays syncDelay) => _syncDelay = syncDelay;

  late Database _database;

  set database(Database database) => _database = database;

  late SeagullLogger _seagullLogger = SeagullLogger.nothing();

  set seagullLogger(SeagullLogger seagullLogger) =>
      _seagullLogger = seagullLogger;

  late AlarmNavigator _alarmNavigator = AlarmNavigator();

  set alarmNavigator(AlarmNavigator alarmNavigator) =>
      _alarmNavigator = alarmNavigator;

  late PackageInfo _packageInfo =
      PackageInfo(appName: '', buildNumber: '', packageName: '', version: '');

  set packageInfo(PackageInfo packageInfo) => _packageInfo = packageInfo;

  late Battery _battery = Battery();

  set battery(Battery battery) => _battery = battery;

  late TtsInterface _ttsHandler = FlutterTtsHandler();

  set ttsHandler(TtsInterface ttsHandler) => _ttsHandler = ttsHandler;

  void init() => GetIt.I
    ..registerSingleton<BaseClient>(
        _baseClient ?? ClientWithDefaultHeaders(_packageInfo.version))
    ..registerSingleton<LoginDb>(_loginDb ?? LoginDb(_sharedPreferences))
    ..registerSingleton<LicenseDb>(_licenseDb ?? LicenseDb(_sharedPreferences))
    ..registerSingleton<FirebasePushService>(_firebasePushService)
    ..registerSingleton<ActivityDb>(_activityDb ?? ActivityDb(_database))
    ..registerSingleton<TimerDb>(_timerDb ?? TimerDb(_database))
    ..registerSingleton<UserDb>(_userDb ?? UserDb(_sharedPreferences))
    ..registerSingleton<Database>(_database)
    ..registerSingleton<SeagullLogger>(_seagullLogger)
    ..registerSingleton<BaseUrlDb>(_baseUrlDb ?? BaseUrlDb(_sharedPreferences))
    ..registerSingleton<DeviceDb>(_deviceDb ?? DeviceDb(_sharedPreferences))
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
    ..registerSingleton<PackageInfo>(_packageInfo)
    ..registerSingleton<Battery>(_battery)
    ..registerSingleton<TtsInterface>(_ttsHandler);
}
