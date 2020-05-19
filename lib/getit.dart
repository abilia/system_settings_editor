import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
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

  DatabaseRepository _databaseRepository;
  set databaseRepository(DatabaseRepository databaseRepository) =>
      _databaseRepository = databaseRepository;

  FactoryFunc<Stream<DateTime>> _tickerFactory;
  set ticker(FactoryFunc<Stream<DateTime>> ticker) => _tickerFactory = ticker;

  NotificationStreamGetter _selectedNotificationStreamGetter;
  set notificationStreamGetter(
          NotificationStreamGetter selectedNotificationStreamGetterFunction) =>
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

  FactoryFunc<DateTime> _startTime;
  set startTime(DateTime startTime) => _startTime = () => startTime;

  void init() {
    GetIt.I.reset();
    GetIt.I.registerSingleton<BaseClient>(_baseClient ?? Client());
    GetIt.I.registerSingleton<TokenDb>(_tokenDb ?? TokenDb());
    GetIt.I.registerSingleton<FirebasePushService>(
        _firebasePushService ?? FirebasePushService());
    GetIt.I.registerSingleton<ActivityDb>(_activityDb ?? ActivityDb());
    GetIt.I.registerSingleton<UserDb>(_userDb ?? UserDb());
    GetIt.I.registerSingleton<DatabaseRepository>(
        _databaseRepository ?? DatabaseRepository());
    GetIt.I.registerSingleton<BaseUrlDb>(_baseUrlDb ?? BaseUrlDb());
    GetIt.I.registerSingleton<NotificationStreamGetter>(
        _selectedNotificationStreamGetter ?? () => selectNotificationSubject);
    GetIt.I.registerSingleton<AlarmScheduler>(
        _alarmScheduler ?? scheduleAlarmNotificationsIsolated);
    GetIt.I.registerFactory<Stream<DateTime>>(
        _tickerFactory ?? () => Ticker.minute());
    GetIt.I.registerSingleton<AlarmNavigator>(AlarmNavigator());
    GetIt.I.registerSingleton<SortableDb>(_sortableDb ?? SortableDb());
    GetIt.I.registerSingleton<UserFileDb>(_userFileDb ?? UserFileDb());
    GetIt.I.registerSingleton<SettingsDb>(_settingsDb ?? SettingsDb(null));
    GetIt.I.registerSingleton<FileStorage>(_fileStorage ?? FileStorage(''));
    GetIt.I.registerSingleton<MultipartRequestBuilder>(
        _multipartRequestBuilder ?? MultipartRequestBuilder());
    GetIt.I.registerFactory<DateTime>(_startTime ?? () => DateTime.now());
  }
}
