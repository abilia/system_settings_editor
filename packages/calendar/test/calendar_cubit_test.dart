import 'package:auth/models/all.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:calendar/all.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull_fakes/all.dart';

import 'package:test/test.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late MockCalendarRepository mockCalendarRepository;
  const userId = 1;
  const calendarId = 'calendarId';

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockCalendarRepository = MockCalendarRepository();
  });

  blocTest(
    'Load calendars',
    setUp: () {
      when(() => mockUserRepository.getUserFromDb()).thenAnswer(
          (_) => Future.value(const User(id: userId, type: '', name: '')));
      when(
        () => mockCalendarRepository.fetchAndSetCalendar(userId),
      ).thenAnswer((_) => Future.value(calendarId));
    },
    build: () => CalendarCubit(
        userRepository: mockUserRepository,
        calendarRepository: mockCalendarRepository),
    act: (CalendarCubit calendarCubit) => calendarCubit.loadCalendarId(),
    expect: () => [
      calendarId,
    ],
  );
}
