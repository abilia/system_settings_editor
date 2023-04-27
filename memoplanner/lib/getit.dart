import 'dart:io';

import 'package:auth/auth.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:calendar/all.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/storage/file_storage.dart';
import 'package:memoplanner/tts/tts_handler.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull_analytics/seagull_analytics.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sortables/db/sortable_db.dart';

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

  SessionsDb? _sessionsDb;
  set sessionsDb(SessionsDb sessionsDb) => _sessionsDb = sessionsDb;

  TermsOfUseDb? _termsOfUseDb;
  set termsOfUseDb(TermsOfUseDb termsOfUseDb) => _termsOfUseDb = termsOfUseDb;

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

  LastSyncDb? _lastSyncDb;
  set lastSyncDb(LastSyncDb lastSyncDb) => _lastSyncDb = lastSyncDb;

  SeagullAnalytics? _analytics;
  set analytics(SeagullAnalytics analytics) => _analytics = analytics;

  Connectivity? _connectivity;
  set connectivity(Connectivity connectivity) => _connectivity = connectivity;

  MyAbiliaConnection? _myAbiliaConnection;
  set myAbiliaConnection(MyAbiliaConnection myAbiliaConnection) =>
      _myAbiliaConnection = myAbiliaConnection;

  Device? _device;
  set device(Device device) => _device = device;

  void init() {
    final loginDb = _loginDb ?? LoginDb(_sharedPreferences);
    final deviceDb = _deviceDb ?? DeviceDb(_sharedPreferences);
    final baseUrlDb = _baseUrlDb ?? BaseUrlDb(_sharedPreferences);
    final client = _listenableClient ??
        ClientWithDefaultHeaders(
          loginDb: loginDb,
          deviceDb: deviceDb,
          version: _packageInfo.version,
          name: Config.flavor.name,
        );
    GetIt.I
      ..registerSingleton<LoginDb>(loginDb)
      ..registerSingleton<DeviceDb>(deviceDb)
      ..registerSingleton<ListenableClient>(client)
      ..registerSingleton<LicenseDb>(
          _licenseDb ?? LicenseDb(_sharedPreferences))
      ..registerSingleton<FirebasePushService>(_firebasePushService)
      ..registerSingleton<ActivityDb>(_activityDb ?? ActivityDb(_database))
      ..registerSingleton<TimerDb>(_timerDb ?? TimerDb(_database))
      ..registerSingleton<UserDb>(_userDb ?? UserDb(_sharedPreferences))
      ..registerSingleton<Database>(_database)
      ..registerSingleton<SeagullLogger>(_seagullLogger)
      ..registerSingleton<BaseUrlDb>(baseUrlDb)
      ..registerSingleton<Ticker>(_ticker)
      ..registerSingleton<AlarmNavigator>(_alarmNavigator)
      ..registerSingleton<SortableDb>(_sortableDb ?? SortableDb(_database))
      ..registerSingleton<GenericDb>(_genericDb ?? GenericDb(_database))
      ..registerSingleton<UserFileDb>(_userFileDb ?? UserFileDb(_database))
      ..registerSingleton<SettingsDb>(
          _settingsDb ?? SettingsDb(_sharedPreferences))
      ..registerSingleton<SessionsDb>(
          _sessionsDb ?? SessionsDb(_sharedPreferences))
      ..registerSingleton<TermsOfUseDb>(
          _termsOfUseDb ?? TermsOfUseDb(_sharedPreferences))
      ..registerSingleton<CalendarDb>(_calendarDb ?? CalendarDb(_database))
      ..registerSingleton<FileStorage>(
          _fileStorage ?? FileStorage.inDirectory(_directories?.documents.path))
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
              temp: Directory.systemTemp,
            ),
      )
      ..registerSingleton<LastSyncDb>(
          _lastSyncDb ?? LastSyncDb(_sharedPreferences))
      ..registerSingleton<SeagullAnalytics>(
          _analytics ?? SeagullAnalytics.empty())
      ..registerSingleton<Connectivity>(
        _connectivity ?? Connectivity(),
      )
      ..registerSingleton<Device>(
        _device ?? const Device(),
      )
      ..registerSingleton<MyAbiliaConnection>(
        _myAbiliaConnection ??
            MyAbiliaConnection(
              baseUrlDb: baseUrlDb,
              client: client,
            ),
      );
  }
}
