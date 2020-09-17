import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/repository/all.dart';
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

  Ticker _ticker;
  set ticker(Ticker ticker) => _ticker = ticker;

  ReplaySubject<String> _selectedNotificationStreamGetter;
  set notificationStreamGetter(
          ReplaySubject<String> selectedNotificationStreamGetterFunction) =>
      _selectedNotificationStreamGetter =
          selectedNotificationStreamGetterFunction;

  AlarmScheduler _alarmScheduler;
  set alarmScheduler(AlarmScheduler alarmScheduler) =>
      _alarmScheduler = alarmScheduler;

  BaseUrlDb _baseUrlDb;
  set baseUrlDb(BaseUrlDb baseUrlDb) => _baseUrlDb = baseUrlDb;

  BaseClient _baseClient;
  set httpClient(BaseClient baseClient) => _baseClient = baseClient;

  SortableDb _sortableDb;
  set sortableDb(SortableDb sortableDb) => _sortableDb = sortableDb;

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

  void init() {
    GetIt.I.reset();
    GetIt.I.registerSingleton<BaseClient>(_baseClient ?? Client());
    GetIt.I.registerSingleton<TokenDb>(_tokenDb ?? TokenDb());
    GetIt.I.registerSingleton<FirebasePushService>(
        _firebasePushService ?? FirebasePushService());
    GetIt.I.registerSingleton<ActivityDb>(_activityDb ?? ActivityDb(_database));
    final userDb = _userDb ?? UserDb();
    GetIt.I.registerSingleton<UserDb>(userDb);
    GetIt.I.registerSingleton<Database>(_database);
    GetIt.I.registerSingleton<SeagullLogger>(
        _seagullLogger ?? SeagullLogger(userDb));
    GetIt.I.registerSingleton<BaseUrlDb>(_baseUrlDb ?? BaseUrlDb());
    GetIt.I.registerSingleton<ReplaySubject<String>>(
        _selectedNotificationStreamGetter ?? selectNotificationSubject);
    GetIt.I.registerSingleton<AlarmScheduler>(
        _alarmScheduler ?? scheduleAlarmNotificationsIsolated);
    GetIt.I.registerSingleton<Ticker>(_ticker ?? Ticker());
    GetIt.I
        .registerSingleton<AlarmNavigator>(_alarmNavigator ?? AlarmNavigator());
    GetIt.I.registerSingleton<SortableDb>(_sortableDb ?? SortableDb(_database));
    GetIt.I.registerSingleton<UserFileDb>(_userFileDb ?? UserFileDb(_database));
    GetIt.I.registerSingleton<SettingsDb>(_settingsDb ?? SettingsDb(null));
    GetIt.I.registerSingleton<FileStorage>(_fileStorage ?? FileStorage(''));
    GetIt.I.registerSingleton<MultipartRequestBuilder>(
        _multipartRequestBuilder ?? MultipartRequestBuilder());
    GetIt.I.registerSingleton<SyncDelays>(_syncDelay ?? const SyncDelays());
  }
}
