import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/repositories.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockHttpClient extends Mock implements Client {}
class MockSecureStorage extends Mock implements FlutterSecureStorage {}
class MockActivityRepository extends Mock implements ActivityRepository {}
