import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
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

class MockClient extends Mock implements BaseClient {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}
