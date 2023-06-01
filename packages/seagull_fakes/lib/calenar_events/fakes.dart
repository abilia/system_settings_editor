import 'package:bloc_test/bloc_test.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:mocktail/mocktail.dart';

export 'activity_db_in_memory.dart';
export 'fake_activities.dart';

class FakeActivityRepository extends Fake implements ActivityRepository {
  @override
  Future<bool> synchronize() => Future.value(true);

  @override
  Future<bool> save(Iterable<Activity> data) => Future.value(true);

  @override
  Future<Iterable<Activity>> allBetween(DateTime start, DateTime end) =>
      Future.value([]);
}

class MockActivityRepository extends Mock implements ActivityRepository {}

class MockActivityDb extends Mock implements ActivityDb {}

class MockTimerCubit extends MockCubit<TimerState> implements TimerCubit {}

class MockTimerDb extends Mock implements TimerDb {}
