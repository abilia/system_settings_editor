import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/repository/default_http_client.dart';
import 'package:seagull/storage/file_storage.dart';
import 'package:seagull/utils/all.dart';

class GetItInitializer {
  ActivityDb _activityDb;
  set activityDb(ActivityDb activityDb) => _activityDb = activityDb;

  FirebasePushService _firebasePushService;
  set fireBasePushService(FirebasePushService firebasePushService) =>
      _firebasePushService = firebasePushService;

  UserDb _userDb;
  set userDb(UserDb userDb) => _userDb = userDb;

  TokenDb _tokenDb;
  set tokenDb(TokenDb tokenDb) => _tokenDb = tokenDb;

  LicenseDb _licenseDb;
  set licenseDb(LicenseDb licenseDb) => _licenseDb = licenseDb;

  Ticker _ticker;
  set ticker(Ticker ticker) => _ticker = ticker;

  AlarmScheduler _alarmScheduler;
  set alarmScheduler(AlarmScheduler alarmScheduler) =>
      _alarmScheduler = alarmScheduler;

  BaseUrlDb _baseUrlDb;
  set baseUrlDb(BaseUrlDb baseUrlDb) => _baseUrlDb = baseUrlDb;

  BaseClient _baseClient;
  set httpClient(BaseClient baseClient) => _baseClient = baseClient;

  SortableDb _sortableDb;
  set sortableDb(SortableDb sortableDb) => _sortableDb = sortableDb;

  GenericDb _genericDb;
  set genericDb(GenericDb genericDb) => _genericDb = genericDb;

  UserFileDb _userFileDb;
  set userFileDb(UserFileDb userFileDb) => _userFileDb = userFileDb;

  FileStorage _fileStorage;
  set fileStorage(FileStorage fileStorage) => _fileStorage = fileStorage;

  SettingsDb _settingsDb;
  set settingsDb(SettingsDb settingsDb) => _settingsDb = settingsDb;

  MultipartRequestBuilder _multipartRequestBuilder;
  set multipartRequestBuilder(
          MultipartRequestBuilder multipartRequestBuilder) =>
      _multipartRequestBuilder = multipartRequestBuilder;

  SyncDelays _syncDelay;
  set syncDelay(SyncDelays syncDelay) => _syncDelay = syncDelay;

  Database _database;
  set database(Database database) => _database = database;

  SeagullLogger _seagullLogger;
  set seagullLogger(SeagullLogger seagullLogger) =>
      _seagullLogger = seagullLogger;

  AlarmNavigator _alarmNavigator;
  set alarmNavigator(AlarmNavigator alarmNavigator) =>
      _alarmNavigator = alarmNavigator;

  FlutterTts _flutterTts;
  set flutterTts(FlutterTts flutterTts) => _flutterTts = flutterTts;

  void init() {
    final userDb = _userDb ?? UserDb();
    GetIt.I
      ..reset()
      ..registerSingleton<BaseClient>(_baseClient ?? ClientWithDefaultHeaders())
      ..registerSingleton<TokenDb>(_tokenDb ?? TokenDb())
      ..registerSingleton<LicenseDb>(_licenseDb ?? LicenseDb())
      ..registerSingleton<FirebasePushService>(
          _firebasePushService ?? FirebasePushService())
      ..registerSingleton<ActivityDb>(_activityDb ?? ActivityDb(_database))
      ..registerSingleton<UserDb>(userDb)
      ..registerSingleton<Database>(_database)
      ..registerSingleton<SeagullLogger>(
          _seagullLogger ?? SeagullLogger(userDb: userDb))
      ..registerSingleton<BaseUrlDb>(_baseUrlDb ?? BaseUrlDb())
      ..registerSingleton<AlarmScheduler>(
          _alarmScheduler ?? scheduleAlarmNotificationsIsolated)
      ..registerSingleton<Ticker>(_ticker ?? Ticker())
      ..registerSingleton<AlarmNavigator>(_alarmNavigator ?? AlarmNavigator())
      ..registerSingleton<SortableDb>(_sortableDb ?? SortableDb(_database))
      ..registerSingleton<GenericDb>(_genericDb ?? GenericDb(_database))
      ..registerSingleton<UserFileDb>(_userFileDb ?? UserFileDb(_database))
      ..registerSingleton<SettingsDb>(_settingsDb ?? SettingsDb(null))
      ..registerSingleton<FileStorage>(_fileStorage ?? FileStorage(''))
      ..registerSingleton<MultipartRequestBuilder>(
          _multipartRequestBuilder ?? MultipartRequestBuilder())
      ..registerSingleton<SyncDelays>(_syncDelay ?? const SyncDelays())
      ..registerSingleton<FlutterTts>(_flutterTts);
  }
}
