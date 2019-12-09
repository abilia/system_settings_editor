import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:seagull/db/activities_db.dart';
import 'package:seagull/db/sqflite.dart';
import 'package:seagull/db/user_db.dart';
import 'package:seagull/repositories.dart';
import 'package:seagull/repository/push.dart';

import 'bloc/push/push_bloc.dart';

class GetItInitializer {
  ActivityDb _activityDb;
  FirebasePushService _firebasePushService;
  PushBloc _pushBloc;
  UserDb _userDb;
  DatabaseRepository _databaseRepository;
  FactoryFunc<Stream<DateTime>> _tickerFactory;

  GetItInitializer withActivityDb(ActivityDb activityDb) {
    this._activityDb = activityDb;
    return this;
  }

  GetItInitializer withFireBasePushService(
      FirebasePushService firebasePushService) {
    this._firebasePushService = firebasePushService;
    return this;
  }

  GetItInitializer withPushBloc(PushBloc pushBloc) {
    this._pushBloc = pushBloc;
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

  init() async {
    GetIt.I.reset();
    GetIt.I.registerSingleton<BaseClient>(Client());
    GetIt.I.registerSingleton<FlutterSecureStorage>(FlutterSecureStorage());
    GetIt.I.registerSingleton<FirebasePushService>(
        _firebasePushService ?? FirebasePushService());
    GetIt.I.registerSingleton<PushBloc>(_pushBloc ?? PushBloc());
    GetIt.I.registerSingleton<ActivityDb>(_activityDb ?? ActivityDb());
    GetIt.I.registerSingleton<UserDb>(_userDb ?? UserDb());
    GetIt.I.registerSingleton<DatabaseRepository>(
        _databaseRepository ?? DatabaseRepository());
    GetIt.I.registerFactory<Stream<DateTime>>(
        _tickerFactory ?? () => Ticker.minute());
  }
}
