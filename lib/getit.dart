import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class GetItInitializer {
  ActivityDb _activityDb;
  FirebasePushService _firebasePushService;
  UserDb _userDb;
  TokenDb _tokenDb;
  DatabaseRepository _databaseRepository;
  FactoryFunc<Stream<DateTime>> _tickerFactory;
  NotificationStreamGetter _selectedNotificationStreamGetter;
  AlarmScheduler _alarmScheduler;
  BaseUrlDb _baseUrlDb;
  BaseClient _baseClient;

  GetItInitializer withActivityDb(ActivityDb activityDb) {
    this._activityDb = activityDb;
    return this;
  }

  GetItInitializer withFireBasePushService(
      FirebasePushService firebasePushService) {
    this._firebasePushService = firebasePushService;
    return this;
  }

  GetItInitializer withUserDb(UserDb userDb) {
    this._userDb = userDb;
    return this;
  }

  GetItInitializer withDatabaseRepository(
      DatabaseRepository databaseRepository) {
    this._databaseRepository = databaseRepository;
    return this;
  }

  GetItInitializer withTicker(FactoryFunc<Stream<DateTime>> ticker) {
    this._tickerFactory = ticker;
    return this;
  }

  GetItInitializer withNotificationStreamGetter(
      NotificationStreamGetter selectedNotificationStreamGetterFunction) {
    this._selectedNotificationStreamGetter =
        selectedNotificationStreamGetterFunction;
    return this;
  }

  GetItInitializer withAlarmScheduler(AlarmScheduler alarmScheduler) {
    this._alarmScheduler = alarmScheduler;
    return this;
  }

  GetItInitializer withBaseUrlDb(BaseUrlDb baseUrlDb) {
    this._baseUrlDb = baseUrlDb;
    return this;
  }

  GetItInitializer withHttpClient(BaseClient baseClient) {
    this._baseClient = baseClient;
    return this;
  }

  GetItInitializer withTokenDb(TokenDb tokenDb) {
    this._tokenDb = tokenDb;
    return this;
  }

  init() async {
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
        _alarmScheduler ?? scheduleAlarmNotifications);
    GetIt.I.registerFactory<Stream<DateTime>>(
        _tickerFactory ?? () => Ticker.minute());
    GetIt.I.registerSingleton<AlarmNavigator>(AlarmNavigator());
  }
}
