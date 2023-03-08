import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:calendar_repository/calendar_repository.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository_base/repository_base.dart';
import 'package:sqflite/sqlite_api.dart';

@visibleForTesting
class MockBaseUrlDb extends Mock implements BaseUrlDb {}

@visibleForTesting
class MockBaseClient extends Mock implements BaseClient, ListenableClient {}

@visibleForTesting
class MockUserDb extends Mock implements UserDb {}

@visibleForTesting
class MockLoginDb extends Mock implements LoginDb {}

@visibleForTesting
class MockDatabase extends Mock implements Database {}

@visibleForTesting
class MockBatch extends Mock implements Batch {}

@visibleForTesting
class MockUserRepository extends Mock implements UserRepository {}

@visibleForTesting
class MockCalendarRepository extends Mock implements CalendarRepository {}

@visibleForTesting
class MockNotification extends Mock implements Notification {}

@visibleForTesting
class MockFirebasePushService extends Mock implements FirebasePushService {}

@visibleForTesting
class MockLicenseCubit extends MockCubit<LicenseState>
    implements LicenseCubit {}

@visibleForTesting
class MockAuthenticationBloc
    extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

@visibleForTesting
class Notification {
  void mockCancelAll() {}
}
