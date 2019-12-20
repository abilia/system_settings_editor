import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/repository/all.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockHttpClient extends Mock implements Client {}

class MockActivityRepository extends Mock implements ActivityRepository {}

class MockTokenDb extends Mock implements TokenDb {}

class MockPushBloc extends Mock implements PushBloc {}

class MockFirebasePushService extends Mock implements FirebasePushService {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockActivityDb extends Mock implements ActivityDb {}

class MockUserDb extends Mock implements UserDb {}

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

class MockDatabaseRepository extends Mock implements DatabaseRepository {}

class MockBaseUrlDb extends Mock implements BaseUrlDb {}

class MockClient extends Mock implements BaseClient {
  final String baseUrl;
  MockClient(this.baseUrl);

  whenEntityMeSuccess() {
    when(this
            .get('$baseUrl/api/v1/entity/me', headers: authHeader(Fakes.token)))
        .thenAnswer((_) => Future.value(Fakes.entityMeSuccessResponse));
  }

  whenActivities(List<Response> activityAnswers) {
    when(this.get('$baseUrl/api/v1/data/${Fakes.userId}/activities?revision=0',
            headers: authHeader(Fakes.token)))
        .thenAnswer((_) => Future.value(activityAnswers.removeAt(0)));
  }
}
