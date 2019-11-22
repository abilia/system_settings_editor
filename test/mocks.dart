import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/push/push_bloc.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/repositories.dart';
import 'package:seagull/repository/push.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockHttpClient extends Mock implements Client {}

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockActivityRepository extends Mock implements ActivityRepository {}

class MockPushBloc extends Mock implements PushBloc {}

class MockFirebasePushService extends Mock implements FirebasePushService {}

class MockClient extends Mock implements BaseClient {
  final String baseUrl;
  MockClient(this.baseUrl);

  whenEntityMeSuccess() {
    when(this.get('$baseUrl/api/v1/entity/me',
            headers: authHeader(Fakes.token)))
        .thenAnswer((_) => Future.value(Fakes.entityMeSuccessResponse));
  }

  whenActivities(List<Response> activityAnswers) {
    when(this.get('$baseUrl/api/v1/data/${Fakes.userId}/activities?revision=0',
            headers: authHeader(Fakes.token)))
        .thenAnswer((_) => Future.value(activityAnswers.removeAt(0)));
  }
}
