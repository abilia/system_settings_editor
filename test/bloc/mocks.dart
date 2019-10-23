import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/repository/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockHttpClient extends Mock implements Client {}
