import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info/package_info.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/tts/tts_handler.dart';
import 'package:seagull/utils/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:get_it/get_it.dart';

class GetItInitializer {
  Directories? _directories;
  set directories(Directories directories) => _directories = directories;

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

  ListenableClient? _listenableClient;
  set client(ListenableClient listenableClient) =>
      _listenableClient = listenableClient;

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

  CalendarDb? _calendarDb;
  set calendarDb(CalendarDb calendarDb) => _calendarDb = calendarDb;

  VoiceDb? _voiceDb;
  set voiceDb(VoiceDb voiceDb) => _voiceDb = voiceDb;

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

  static const platformChannel = 'memoplanner/intent_actions';
  late ActionIntentStream _actionIntentStream =
      const EventChannel(platformChannel)
          .receiveBroadcastStream()
          .whereType<String>();
  set actionIntentStream(ActionIntentStream actionIntentStream) =>
      _actionIntentStream = actionIntentStream;

  SupportPersonsDb? _supportPersonsDb;
  set supportPersonsDb(SupportPersonsDb supportPersonsDb) =>
      _supportPersonsDb = supportPersonsDb;

  void init() {
    final loginDb = _loginDb ?? LoginDb(_sharedPreferences);
    final deviceDb = _deviceDb ?? DeviceDb(_sharedPreferences);
    GetIt.I
      ..registerSingleton<LoginDb>(loginDb)
      ..registerSingleton<DeviceDb>(deviceDb)
      ..registerSingleton<ListenableClient>(_listenableClient ??
          ClientWithDefaultHeaders(
            _packageInfo.version,
            loginDb: loginDb,
            deviceDb: deviceDb,
          ))
      ..registerSingleton<LicenseDb>(
          _licenseDb ?? LicenseDb(_sharedPreferences))
      ..registerSingleton<FirebasePushService>(_firebasePushService)
      ..registerSingleton<ActivityDb>(_activityDb ?? ActivityDb(_database))
      ..registerSingleton<TimerDb>(_timerDb ?? TimerDb(_database))
      ..registerSingleton<UserDb>(_userDb ?? UserDb(_sharedPreferences))
      ..registerSingleton<Database>(_database)
      ..registerSingleton<SeagullLogger>(_seagullLogger)
      ..registerSingleton<BaseUrlDb>(
          _baseUrlDb ?? BaseUrlDb(_sharedPreferences))
      ..registerSingleton<Ticker>(_ticker)
      ..registerSingleton<AlarmNavigator>(_alarmNavigator)
      ..registerSingleton<SortableDb>(_sortableDb ?? SortableDb(_database))
      ..registerSingleton<GenericDb>(_genericDb ?? GenericDb(_database))
      ..registerSingleton<UserFileDb>(_userFileDb ?? UserFileDb(_database))
      ..registerSingleton<SettingsDb>(
          _settingsDb ?? SettingsDb(_sharedPreferences))
      ..registerSingleton<CalendarDb>(_calendarDb ?? CalendarDb(_database))
      ..registerSingleton<FileStorage>(
          _fileStorage ?? FileStorage(_directories?.documents.path))
      ..registerSingleton<MultipartRequestBuilder>(_multipartRequestBuilder)
      ..registerSingleton<SyncDelays>(_syncDelay)
      ..registerSingleton<PackageInfo>(_packageInfo)
      ..registerSingleton<Battery>(_battery)
      ..registerSingleton<TtsInterface>(_ttsHandler)
      ..registerSingleton<VoiceDb>(_voiceDb ?? VoiceDb(_sharedPreferences))
      ..registerSingleton<ActionIntentStream>(_actionIntentStream)
      ..registerSingleton<SupportPersonsDb>(
          _supportPersonsDb ?? SupportPersonsDb(_sharedPreferences))
      ..registerSingleton<Directories>(
        _directories ??
            Directories(
              applicationSupport: Directory.systemTemp,
              documents: Directory.systemTemp,
            ),
      );
  }
}
