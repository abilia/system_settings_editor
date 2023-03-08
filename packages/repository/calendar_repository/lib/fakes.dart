import 'package:calendar_repository/calendar_repository.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';

@visibleForTesting
class MockCalendarRepository extends Mock implements CalendarRepository {}

@visibleForTesting
class FakesCalendarRepository extends Fake implements CalendarRepository {}
