import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository_base/repository_base.dart';
import 'package:sqflite/sqflite.dart';

class MockBaseUrlDb extends Mock implements BaseUrlDb {}

class MockBaseClient extends Mock implements BaseClient, ListenableClient {}

class MockUserDb extends Mock implements UserDb {}

class MockLoginCubit extends Mock implements LoginCubit {}

class MockLoginDb extends Mock implements LoginDb {}

class MockDatabase extends Mock implements Database {}

class MockBatch extends Mock implements Batch {}

class MockUserRepository extends Mock implements UserRepository {}

class MockNotification extends Mock implements Notification {}

class MockFirebasePushService extends Mock implements FirebasePushService {}

class MockLicenseCubit extends MockCubit<LicenseState>
    implements LicenseCubit {}

class MockAuthenticationBloc
    extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

class Notification {
  void mockCancelAll() {}
}
