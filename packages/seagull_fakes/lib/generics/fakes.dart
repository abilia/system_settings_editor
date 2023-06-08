import 'package:generics/generics.dart';
import 'package:mocktail/mocktail.dart';

class MockGenericDb extends Mock implements GenericDb {}

class FakeGenericRepository extends Fake implements GenericRepository {
  @override
  Future<bool> synchronize() => Future.value(true);
}

class MockGenericRepository extends Mock implements GenericRepository {}
